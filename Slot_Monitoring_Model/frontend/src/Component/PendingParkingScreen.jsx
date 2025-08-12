import React, { useEffect, useState } from "react";
import {
  Box,
  Button,
  Container,
  TextField,
  Typography,
  Paper,
} from "@mui/material";
import { useParams } from "react-router-dom";
import { doc, getDoc } from "firebase/firestore";
import { firestore } from "../Firebase";

export default function PendingParkingForm() {
  const { pid } = useParams();
  const [parkingName, setParkingName] = useState("");
  const [address, setAddress] = useState("");
  const [videoFile, setVideoFile] = useState(null);
  const [videoPreview, setVideoPreview] = useState(null);

  useEffect(() => {
    const fetchParkingDetails = async () => {
      try {
        const parkingRef = doc(firestore, "pending_parking", pid);
        const snap = await getDoc(parkingRef);
        if (snap.exists()) {
          const data = snap.data();
          setParkingName(data.parkingName || "");
          setAddress(data.address || "");
        }
      } catch (error) {
        console.error("Error fetching parking info:", error);
      }
    };

    if (pid) fetchParkingDetails();
  }, [pid]);

  useEffect(() => {
    if (videoFile) {
      const url = URL.createObjectURL(videoFile);
      setVideoPreview(url);
      return () => URL.revokeObjectURL(url);
    } else {
      setVideoPreview(null);
    }
  }, [videoFile]);

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!videoFile) {
      alert("Please upload a video file.");
      return;
    }
    console.log("Submitting video for:", {
      pid,
      parkingName,
      address,
      videoFile,
    });
    // TODO: Upload video to Firebase
  };

  return (
    <Box
      sx={{
        minHeight: "100vh",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        background: "linear-gradient(to right, #e3f2fd, #ffffff)",
        px: 2,
      }}
    >
      <Container maxWidth="sm">
        <Paper elevation={3} sx={{ p: 4, borderRadius: 2 }}>
          <Typography variant="h5" fontWeight={600} gutterBottom>
            Submit Parking Video
          </Typography>
          <Box component="form" onSubmit={handleSubmit} sx={{ mt: 2 }}>
            <TextField
              label="Parking Name"
              value={parkingName}
              fullWidth
              margin="normal"
              InputProps={{ readOnly: true }}
            />
            <TextField
              label="Address"
              value={address}
              fullWidth
              margin="normal"
              InputProps={{ readOnly: true }}
            />
            <Button
              variant="outlined"
              component="label"
              fullWidth
              sx={{ mt: 2 }}
            >
              {videoFile ? videoFile.name : "Upload Video"}
              <input
                type="file"
                accept="video/*"
                hidden
                onChange={(e) => setVideoFile(e.target.files[0])}
              />
            </Button>

            {videoPreview && (
              <Box sx={{ mt: 2 }}>
                <Typography variant="subtitle1" gutterBottom>
                  Video Preview:
                </Typography>
                <video
                  src={videoPreview}
                  controls
                  style={{ width: "100%", borderRadius: 8 }}
                />
              </Box>
            )}

            <Button
              type="submit"
              variant="contained"
              fullWidth
              sx={{ mt: 3 }}
            >
              Submit
            </Button>
          </Box>
        </Paper>
      </Container>
    </Box>
  );
}
