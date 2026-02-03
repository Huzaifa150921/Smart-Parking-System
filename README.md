# Smart Parking System 🚗🅿️

A **Smart Parking System** that integrates **Firebase authentication**, **real-time location tracking**, **license plate recognition**, **slot monitoring**, and **parking management**.  

This system helps users find nearby parking, reserve slots, make payments, and track vehicle entry/exit. Parking owners can manage multiple parking locations, view revenue, and monitor slot occupancy. Admins verify parking registrations and oversee the entire system.

---

## 📌 Features

### User Features
- **Firebase Authentication** – secure login/signup  
- **Real-Time Location** – shows user location on map  
- **Find Nearest Parking** – displays nearby parking lots  
- **Parking Reservation** – enter license plate, select slot, specify number of days  
- **Stripe Payment Integration** – pay for parking online  
- **Booking Management** – view active bookings, entry/exit time, slot details, parking owner info  
- **Slot Status** – view free, reserved, and occupied slots  
- **Notifications** – real-time updates on parking status, fines, or booking updates  
- **Reviews** – leave reviews for parking owners  
- **Profile Management** – update profile pic, name, email, password  

### Owner Features
- **Owner Registration** – provide parking details for verification  
- **Multi-Parking Management** – add multiple parking locations  
- **Revenue Tracking** – see parking revenue  
- **Entry/Exit Logs** – view vehicle logs  
- **Reviews** – see feedback from users  

### Admin Features
- **Admin Authentication** – secure admin login  
- **Verify Owners** – approve or reject parking owner registration requests  
- **Manage Parking** – oversee all parking activity and verifications  

### Parking Slot Monitoring
- **License Plate Recognition** – camera scans vehicle plate at entry  
- **Automated Entry Control** – only reserved vehicles can enter  
- **Slot Occupancy Tracking** – YOLO model monitors free/reserved/occupied slots  
- **Real-Time Updates** – app reflects slot status with color coding:
  - **Green** – free  
  - **Yellow** – reserved  
  - **Red** – occupied  

### Business Rules
- Refund allowed only if parking is canceled within **15 minutes**  
- Fine imposed if vehicle overstays reservation; user cannot exit until fine is paid  
- Users can reserve **one parking slot at a time**  

---

## 📂 Project Structure

├── Car-Number-Plates-Detection-main # License plate recognition code
├── ParkXpert # Main application
├── Slot_Monitoring_Model # YOLO slot monitoring model
├── Testing Videos # Sample test videos


---

## 🛠 Tech Stack
- **Frontend / Backend:** Python, Flask/Django, Firebase  
- **Machine Learning:** OpenCV, TensorFlow/PyTorch, YOLO  
- **Payments:** Stripe  
- **Database:** Firebase / Firestore  
- **Notifications:** Firebase Cloud Messaging  
- **Maps & Location:** Google Maps API  

---

## 🚀 Getting Started

```bash
git clone https://github.com/<your-username>/smart-parking-system.git
cd smart-parking-system
# Install dependencies as per instructions in each module
```
## 📜 License

This project is licensed under the MIT License – feel free to use and modify.

## ⭐ Support

If you like this project and find it helpful, please consider giving it a ⭐ on GitHub.
Your support motivates me to keep improving and adding new features 🙌
