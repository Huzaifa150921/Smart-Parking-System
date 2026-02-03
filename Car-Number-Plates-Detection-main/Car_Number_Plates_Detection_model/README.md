# Car Number Plates Detection 🚗🔢

A **Computer Vision project** that detects and recognizes vehicle license plates using **Python**, **OpenCV**, and **OCR** techniques.  
This project is ideal for **automated parking systems**, **traffic monitoring**, or any application that needs **vehicle identification**.

---

## 📌 Features

- **Automatic License Plate Detection** – detects license plates in images and videos using OpenCV  
- **Optical Character Recognition (OCR)** – extracts text from detected license plates  
- **Video & Image Support** – works on both static images and real-time video feeds  
- **Bounding Box Visualization** – highlights detected license plates for easy verification  
- **Easy Integration** – can be integrated with parking or traffic management systems  

---

## 🛠 Tech Stack

- **Python** – core programming language  
- **OpenCV** – image/video processing and plate detection  
- **NumPy** – numerical operations on images  
- **PyTesseract / OCR** – for text extraction from plates  
- **Machine Learning / Deep Learning** (optional for advanced plate detection)  

---



## 🚀 Getting Started

### Prerequisites

- Python 3.8+  
- OpenCV (`pip install opencv-python`)  
- PyTesseract (`pip install pytesseract`)  
- NumPy (`pip install numpy`)  

---

### Installation

```bash
git clone https://github.com/<your-username>/Car-Number-Plates-Detection.git
cd Car-Number-Plates-Detection-main
pip install -r requirements.txt
```
### Usage

Run on Image
python detect_plate_image.py --image path_to_image.jpg

Run on Video
python detect_plate_video.py --video path_to_video.mp4
The system will detect license plates and show a bounding box with extracted plate text.
---


### 💡 Applications

- Smart Parking Systems  
- Vehicle Entry/Exit Logs  
- Toll Booth Automation  
- Traffic Violation Detection  



### ⭐ Support
---
If you find this project useful, please ⭐ star the repository on GitHub. Your support helps me maintain and improve the project.
---
