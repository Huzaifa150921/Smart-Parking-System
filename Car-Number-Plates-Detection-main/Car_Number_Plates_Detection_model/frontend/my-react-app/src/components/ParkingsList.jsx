
//********** */
import React, { useEffect, useState } from "react";
import {
  collection,
  getDocs,
  query,
  where,
  updateDoc,
  doc,
  addDoc,
  Timestamp,
} from "firebase/firestore";
import { db } from "../firebase";
import { FaCamera } from "react-icons/fa";

const ParkingsList = () => {
  const [parkings, setParkings] = useState([]);
  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedParking, setSelectedParking] = useState(null);
  const [associatedBookings, setAssociatedBookings] = useState([]);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const parkingsSnapshot = await getDocs(collection(db, "parkings"));
        const parkingsData = parkingsSnapshot.docs.map((doc) => ({
          id: doc.id,
          ...doc.data(),
        }));
        setParkings(parkingsData);
        const bookingsSnapshot = await getDocs(collection(db, "bookings"));
        const bookingsData = bookingsSnapshot.docs.map((doc) => ({
          id: doc.id,
          ...doc.data(),
        }));
        setBookings(bookingsData);
      } catch (error) {
        console.error("Error fetching data:", error);
      }
      setLoading(false);
    };
    fetchData();
  }, []);

  const handleParkingClick = (parking) => {
    if (selectedParking?.id === parking.id) {
      setSelectedParking(null);
    } else {
      setSelectedParking(parking);
      const matchedBookings = bookings.filter(
        (booking) =>
          booking.parkingId === parking.puid && booking.status === "active"
      );
      setAssociatedBookings(matchedBookings);
    }
  };

  const handleCameraClick = async (parking) => {
    try {
      const response = await fetch("http://localhost:5000/detect_plate", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
      });
      const data = await response.json();
      let plate = data.plate_number || data.output || "No plate detected";
      plate = plate.trim().toUpperCase();
      alert(`Detected Plate Number: ${plate}`);

      const bookingsRef = collection(db, "bookings");
      const allBookingsSnapshot = await getDocs(
        query(bookingsRef, where("parkingId", "==", parking.puid))
      );
      const allBookings = allBookingsSnapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));

      const normalize = (str) => (str || "").replace(/[-\s]/g, "").trim().toUpperCase();
      const normalizedPlate = normalize(plate);
      let updated = false;
      let found = false;

      for (const booking of allBookings) {
        const bookingPlate = normalize(booking.plateNo);
        if (bookingPlate && bookingPlate === normalizedPlate) {
          found = true;

          if (
            (booking.startTime === null ||
              booking.startTime === "" ||
              booking.startTime === "null") &&
            booking.status === "active"
          ) {
            const bookingDocRef = doc(db, "bookings", booking.id);
            const formattedTime = Timestamp.now();

            await updateDoc(bookingDocRef, { startTime: formattedTime });
            updated = true;

            await addDoc(collection(db, "entry_logs"), {
              userId: booking.userId || "Unknown",
              parkingId: booking.parkingId || "Unknown",
              plateNo: booking.plateNo || "Unknown",
              startTime: formattedTime,
              parkingName: parking.parkingName || "Unknown",
              timestamp: Timestamp.now(),
            });

            try {
              const slotResultsRef = collection(db, "slot_monitoring_model_results");
              const slotPuidQuery = query(slotResultsRef, where("puid", "==", booking.parkingId));
              const slotPuidSnapshot = await getDocs(slotPuidQuery);

              for (const slotDoc of slotPuidSnapshot.docs) {
                const slotData = slotDoc.data();
                const slotsArray = slotData.slots || [];

                for (let i = 0; i < slotsArray.length; i++) {
                  const slot = slotsArray[i];
                  if (Number(booking.slotid) === Number(slot.slot_id)) {
                    if (slot.status === "free" || slot.status === "reserved") {
                      const updatedSlots = [...slotsArray];
                      updatedSlots[i] = { ...slot, status: "occupied" };

                      await updateDoc(doc(db, "slot_monitoring_model_results", slotDoc.id), {
                        slots: updatedSlots,
                      });
                    }
                    break;
                  }
                }
              }
            } catch (slotErr) {
              console.error("Error updating slot_monitoring_model_results:", slotErr);
            }
          } else if (booking.startTime !== null && booking.status === "active") {
            const created = booking.createdAt?.toDate?.();
            const durationDays = Number(booking.durationInDays || 0);
            const currentTime = new Date();

            if (created) {
              const allowedEndTime = new Date(created.getTime() + durationDays * 24 * 60 * 60 * 1000);

              const bookingDocRef = doc(db, "bookings", booking.id);

              if (currentTime <= allowedEndTime) {
                const endTime = Timestamp.now();

                await updateDoc(bookingDocRef, {
                  endTime: endTime,
                  status: "complete",
                });

                const slotResultsRef = collection(db, "slot_monitoring_model_results");
                const slotPuidQuery = query(slotResultsRef, where("puid", "==", booking.parkingId));
                const slotPuidSnapshot = await getDocs(slotPuidQuery);

                for (const slotDoc of slotPuidSnapshot.docs) {
                  const slotData = slotDoc.data();
                  const slotsArray = slotData.slots || [];

                  for (let i = 0; i < slotsArray.length; i++) {
                    const slot = slotsArray[i];
                    if (Number(booking.slotid) === Number(slot.slot_id)) {
                      if (slot.status === "occupied") {
                        const updatedSlots = [...slotsArray];
                        updatedSlots[i] = { ...slot, status: "free" };

                        await updateDoc(doc(db, "slot_monitoring_model_results", slotDoc.id), {
                          slots: updatedSlots,
                        });
                      }
                      break;
                    }
                  }
                }

                await addDoc(collection(db, "exit_logs"), {
                  userId: booking.userId || "Unknown",
                  parkingId: booking.parkingId || "Unknown",
                  plateNo: booking.plateNo || "Unknown",
                  endTime: endTime,
                  parkingName: parking.parkingName || "Unknown",
                  timestamp: Timestamp.now(),
                });

                updated = true;
              } else {
                const msExceeded = currentTime - allowedEndTime;
                const hoursExceeded = Math.ceil(msExceeded / (1000 * 60 * 60));
                const fine = 20 * hoursExceeded;

                const endTime = Timestamp.now();

                await updateDoc(bookingDocRef, {
                  endTime: endTime,
                  status: "complete",
                  fine: fine,
                  isFine: true,
                });

                const slotResultsRef = collection(db, "slot_monitoring_model_results");
                const slotPuidQuery = query(slotResultsRef, where("puid", "==", booking.parkingId));
                const slotPuidSnapshot = await getDocs(slotPuidQuery);

                for (const slotDoc of slotPuidSnapshot.docs) {
                  const slotData = slotDoc.data();
                  const slotsArray = slotData.slots || [];

                  for (let i = 0; i < slotsArray.length; i++) {
                    const slot = slotsArray[i];
                    if (Number(booking.slotid) === Number(slot.slot_id)) {
                      if (slot.status === "occupied") {
                        const updatedSlots = [...slotsArray];
                        updatedSlots[i] = { ...slot, status: "free" };

                        await updateDoc(doc(db, "slot_monitoring_model_results", slotDoc.id), {
                          slots: updatedSlots,
                        });
                      }
                      break;
                    }
                  }
                }

                await addDoc(collection(db, "exit_logs"), {
                  userId: booking.userId || "Unknown",
                  parkingId: booking.parkingId || "Unknown",
                  plateNo: booking.plateNo || "Unknown",
                  endTime: endTime,
                  parkingName: parking.parkingName || "Unknown",
                  timestamp: Timestamp.now(),
                });

                alert(`Fine generated: Rs. ${fine}`);
                updated = true;
              }
            } else {
              console.error("Missing 'createdAt' in booking:", booking);
            }
          }
        }
      }

      if (!found) alert("No matching booking found for this plate.");
      else if (updated) alert("Booking updated successfully.");
    } catch (error) {
      console.error("Error handling camera click:", error);
    }
  };

  if (loading) return <div>Loading...</div>;
  if (!parkings.length) return <div>No parkings found.</div>;

  return (
    <div style={{ backgroundColor: "#bceefdff", minHeight: "100vh", padding: "20px" }}>
      <div style={{ width: "100%", margin: "0 auto", textAlign: "center" }}>
        <h2 style={{ color: "#3291ebff" }}>All Parkings</h2>
        <ul style={{ listStyle: "none", padding: 0 }}>
          {parkings.map((parking) => (
            <li
              key={parking.id}
              style={{
                cursor: "pointer",
                marginBottom: "12px",
                padding: "10px",
                backgroundColor:
                  selectedParking?.id === parking.id ? "#3291ebff" : "#ffffff",
                border: "1px solid #ccc",
                borderRadius: "5px",
                display: "flex",
                justifyContent: "space-between",
                alignItems: "center",
              }}
            >
              <span onClick={() => handleParkingClick(parking)} style={{ flexGrow: 1, textAlign: "left" }}>
                {parking.parkingName || "Unnamed Parking"}
              </span>
              <span onClick={() => handleCameraClick(parking)} style={{ marginLeft: "12px" }}>
                <FaCamera style={{ color: "#090a0cff", fontSize: "1.3em" }} />
              </span>
            </li>
          ))}
        </ul>

        {selectedParking && (
          <div
            style={{
              marginTop: "20px",
              borderTop: "4px solid #3291ebff",
              backgroundColor: "#ffffff",
              padding: "20px",
              textAlign: "left",
              borderRadius: "10px",
              boxShadow: "0 4px 8px rgba(0,0,0,0.1)",
              animation: "slide-in 0.3s ease-out",
              width: "95vw",
              maxWidth: "95vw",
              marginLeft: "auto",
              marginRight: "auto",
              wordBreak: "break-word",
              overflowWrap: "break-word",
              boxSizing: "border-box",
            }}
          >
            <h3 style={{ color: "#3291ebff" }}>Parking Details</h3>
            <ul>
              <li><strong>puid:</strong> {selectedParking.puid || "N/A"}</li>
              <li><strong>Address:</strong> {selectedParking.parkingAddress || "N/A"}</li>
              <li><strong>Earning:</strong> {selectedParking.parkingEarning || "N/A"}</li>
              <li><strong>Price:</strong> {selectedParking.price || "N/A"}</li>
            </ul>

            <h3 style={{ marginTop: "20px", color: "#3291ebff" }}>Associated Bookings</h3>
            {associatedBookings.length ? (
              <ul>
                {associatedBookings.map((booking) => (
                  <li key={booking.id} style={{ marginBottom: "10px" }}>
                    <strong>bookingId:</strong> {booking.bookingId || "N/A"}<br />
                    <strong>Duration:</strong> {booking.durationInDays || "N/A"}<br />
                    <strong>Payment Status:</strong> {booking.paymentStatus || "N/A"}<br />
                    <strong>Plate No:</strong> {booking.plateNo || "N/A"}
                  </li>
                ))}
              </ul>
            ) : (
              <div>No bookings found for this parking.</div>
            )}

            <button
              onClick={() => setSelectedParking(null)}
              style={{
                marginTop: "15px",
                backgroundColor: "#3291ebff",
                color: "white",
                padding: "8px 16px",
                border: "none",
                borderRadius: "4px",
                cursor: "pointer",
              }}
            >
              Close
            </button>
          </div>
        )}
      </div>
    </div>
  );
};

export default ParkingsList;
