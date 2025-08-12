import cv2
from ultralytics import YOLO
import numpy as np
import os
import easyocr
import re
import time

model = YOLO("model/best.pt")

cap = cv2.VideoCapture(0)
cap.set(3, 640) # width
cap.set(4, 480) # height

# Find the next available imgN.jpg filename
def get_next_img_filename(folder):
    existing = [f for f in os.listdir(folder) if f.startswith("img") and f.endswith(".jpg")]
    nums = [int(f[3:-4]) for f in existing if f[3:-4].isdigit()]
    next_num = max(nums) + 1 if nums else 1
    return os.path.join(folder, f"img{next_num}.jpg")


reader = easyocr.Reader(['en'])
last_plate_text = None
last_detection_time = 0
min_time_between_detections = 3  # seconds


# Only process the first detected plate, then exit
plate_found = False
while not plate_found:
    success, img = cap.read()
    if not success:
        break

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
                # Preprocess ROI: convert to grayscale and resize for better OCR
                roi_gray = cv2.cvtColor(img_roi, cv2.COLOR_BGR2GRAY)
                roi_resized = cv2.resize(roi_gray, (roi_gray.shape[1]*2, roi_gray.shape[0]*2), interpolation=cv2.INTER_CUBIC)
                roi_bgr = cv2.cvtColor(roi_resized, cv2.COLOR_GRAY2BGR)
                cv2.imshow("ROI", roi_resized)

                # Save the preprocessed ROI automatically (as BGR)
                plates_folder = "plates"
                if not os.path.exists(plates_folder):
                    os.makedirs(plates_folder)
                img_path = get_next_img_filename(plates_folder)
                cv2.imwrite(img_path, roi_bgr)
                print(f"Saved plate image: {img_path}")

                # Pass the preprocessed ROI directly to EasyOCR
                try:
                    output = reader.readtext(roi_bgr)
                    print(f"Raw OCR output for {img_path}: {output}")

                    plate_text = " ".join([item[1] for item in output]) if output else ""
                    plate_text = plate_text.replace('"', '').replace("'", "").strip()
                    plate_text = re.sub(r'[^A-Za-z0-9 ]+', '', plate_text)
                    plate_text = plate_text.upper()
                    # Insert hyphen between letters and digits (e.g., LEB-5786)
                    match = re.match(r'^([A-Z]+)[\s-]*([0-9]+)$', plate_text)
                    if match:
                        plate_text = f"{match.group(1)}-{match.group(2)}"
                    else:
                        # fallback: try to insert hyphen between first word and rest
                        parts = plate_text.split()
                        if len(parts) >= 2:
                            plate_text = parts[0] + '-' + ''.join(parts[1:])
                    print(f"Detected Plate Number: {plate_text if plate_text else '[No text detected]'}")

                    # Save the plate number, image filename, and raw OCR output to a text file
                    with open("plate_numbers.txt", "a", encoding="utf-8") as f:
                        f.write(f"{os.path.basename(img_path)}: {plate_text if plate_text else '[No text detected]'} | Raw OCR: {output}\n")
                    print(f"Saved new plate: {plate_text}")
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
        cv2.waitKey(1000)  # Show the result for a short time before closing
        break
    key = cv2.waitKey(1) & 0xFF
    if key == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()