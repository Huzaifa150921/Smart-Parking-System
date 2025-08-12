import cv2
from ultralytics import YOLO
import numpy as np
import os
import easyocr
import re
import time

print("[PYTHON] Starting number_plate.py...")

# Load YOLO model
model_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "model", "best.pt")
model = YOLO(model_path)

# Set up camera
cap = cv2.VideoCapture(0)
cap.set(3, 640)
cap.set(4, 480)

def get_next_img_filename(folder):
    existing = [f for f in os.listdir(folder) if f.startswith("img") and f.endswith(".jpg")]
    nums = [int(f[3:-4]) for f in existing if f[3:-4].isdigit()]
    next_num = max(nums) + 1 if nums else 1
    return os.path.join(folder, f"img{next_num}.jpg")

reader = easyocr.Reader(['en'])
plate_text = ""
plate_found = False

while not plate_found:
    print("[PYTHON] Capturing frame from camera...")
    success, img = cap.read()
    if not success:
        print("[PYTHON] Failed to capture frame from camera.")
        break

    print("[PYTHON] Frame captured. Running model...")
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    results = model(img_rgb)

    img_roi = None
    for r in results:
        boxes = r.boxes.xyxy.cpu().numpy() if hasattr(r.boxes, 'xyxy') else []
        confs = r.boxes.conf.cpu().numpy() if hasattr(r.boxes, 'conf') else []
        for i, box in enumerate(boxes):
            x1, y1, x2, y2 = map(int, box)
            conf = confs[i] if i < len(confs) else 0
            cv2.rectangle(img, (x1, y1), (x2, y2), (0,255,0), 2)
            cv2.putText(img, f"Number Plate {conf:.2f}", (x1, y1-5), cv2.FONT_HERSHEY_COMPLEX_SMALL, 1, (255, 0, 255), 2)
            img_roi = img[y1:y2, x1:x2]
            if img_roi is not None and img_roi.size > 0:
                roi_gray = cv2.cvtColor(img_roi, cv2.COLOR_BGR2GRAY)
                roi_resized = cv2.resize(roi_gray, (roi_gray.shape[1]*2, roi_gray.shape[0]*2), interpolation=cv2.INTER_CUBIC)
                roi_bgr = cv2.cvtColor(roi_resized, cv2.COLOR_GRAY2BGR)
                cv2.imshow("ROI", roi_resized)

                plates_folder = "plates"
                if not os.path.exists(plates_folder):
                    os.makedirs(plates_folder)
                img_path = get_next_img_filename(plates_folder)
                cv2.imwrite(img_path, roi_bgr)
                print(f"Saved plate image: {img_path}")

                try:
                    output = reader.readtext(roi_bgr)
                    print(f"Raw OCR output for {img_path}: {output}")

                    plate_text = " ".join([item[1] for item in output]) if output else ""
                    plate_text = plate_text.replace('"', '').replace("'", "").strip()
                    plate_text = re.sub(r'[^A-Za-z0-9 ]+', '', plate_text)
                    plate_text = plate_text.upper()

                    match = re.match(r'^([A-Z]+)[\s-]*([0-9]+)$', plate_text)
                    if match:
                        plate_text = f"{match.group(1)}-{match.group(2)}"
                    else:
                        parts = plate_text.split()
                        if len(parts) >= 2:
                            plate_text = parts[0] + '-' + ''.join(parts[1:])

                    print(f"Detected Plate Number: {plate_text if plate_text else '[No text detected]'}")

                    # Save to text log
                    with open("plate_numbers.txt", "a", encoding="utf-8") as f:
                        f.write(f"{os.path.basename(img_path)}: {plate_text if plate_text else '[No text detected]'} | Raw OCR: {output}\n")

                    plate_found = True
                    break
                except Exception as e:
                    print(f"OCR error for {img_path}: {e}")
                    with open("plate_numbers.txt", "a", encoding="utf-8") as f:
                        f.write(f"{os.path.basename(img_path)}: [OCR error: {e}]\n")
                    plate_found = True
                    break

    cv2.imshow("Result", img)
    if plate_found:
        cv2.waitKey(1000)
        break
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Final return: print only plate_text (for API or subprocess capture)
if plate_found and plate_text:
    print(plate_text)
else:
    print("No plate detected")
