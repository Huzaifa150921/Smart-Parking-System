import React, { useState, useEffect } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import Box from "@mui/material/Box";
import Button from "@mui/material/Button";
import Container from "@mui/material/Container";
import TextField from "@mui/material/TextField";
import Typography from "@mui/material/Typography";
import Paper from "@mui/material/Paper";
import Snackbar from "@mui/material/Snackbar";
import Alert from "@mui/material/Alert";
import CircularProgress from "@mui/material/CircularProgress";
import Dialog from "@mui/material/Dialog";
import DialogTitle from "@mui/material/DialogTitle";
import DialogContent from "@mui/material/DialogContent";
import DialogActions from "@mui/material/DialogActions";
import { getFirestore, collection, addDoc, serverTimestamp, query, where, getDocs } from "firebase/firestore";
import { getApp } from "firebase/app";

export default function PendingParkingForm() {
  const location = useLocation();
  const navigate = useNavigate();
  const passedPuid = location.state?.puid || "";

  const [puid] = useState(passedPuid);
  const [videoFile, setVideoFile] = useState(null);
  const [videoPreview, setVideoPreview] = useState(null);
  const [processing, setProcessing] = useState(false);
  const [saveSuccess, setSaveSuccess] = useState(false);
  const [saveError, setSaveError] = useState("");
  const [buttonDisabled, setButtonDisabled] = useState(false);
  const [showDialog, setShowDialog] = useState(false);

  useEffect(() => {
    const style = document.createElement("style");
    style.innerHTML = `
      @keyframes carMove {
        0% { left: -120px; }
        100% { left: 100vw; }
      }
      .parking-bg-car {
        position: absolute;
        bottom: 40px;
        width: 100px;
        height: 60px;
        z-index: 1;
        opacity: 0.7;
        animation: carMove 12s linear infinite;
      }
      .parking-bg-car2 {
        position: absolute;
        bottom: 100px;
        width: 80px;
        height: 48px;
        z-index: 1;
        opacity: 0.5;
        animation: carMove 18s linear infinite;
        animation-delay: 6s;
      }
      @keyframes gradientBG {
        0% {background-position:0% 50%;}
        25% {background-position:50% 100%;}
        50% {background-position:100% 50%;}
        75% {background-position:50% 0%;}
        100% {background-position:0% 50%;}
      }
    `;
    document.head.appendChild(style);
    return () => {
      document.head.removeChild(style);
    };
  }, []);

  useEffect(() => {
    if (videoFile) {
      const url = URL.createObjectURL(videoFile);
      setVideoPreview(url);
      return () => URL.revokeObjectURL(url);
    } else {
      setVideoPreview(null);
    }
  }, [videoFile]);

  const processVideo = async () => {
    if (!videoFile) {
      alert("Please upload a video file.");
      return;
    }
    setProcessing(true);
    setSaveError("");
    try {
      const db = getFirestore(getApp());
      const q = query(collection(db, "slot_monitoring_model_results"), where("puid", "==", puid));
      const querySnapshot = await getDocs(q);
      if (!querySnapshot.empty) {
        setSaveError("Parking slot details already exist in Firebase for this PUID.");
        setButtonDisabled(true);
        setProcessing(false);
        return;
      }
      const formData = new FormData();
      formData.append("video", videoFile);
      formData.append("puid", puid);
      const uploadRes = await fetch("/api/uploads", {
        method: "POST",
        body: formData,
      });
      if (!uploadRes.ok) throw new Error("Video upload failed");
      const processRes = await fetch(`/api/process?puid=${encodeURIComponent(puid)}`);
      if (!processRes.ok) throw new Error("Video processing failed");
      const result = await processRes.json();
      try {
        await addDoc(collection(db, "slot_monitoring_model_results"), {
          puid,
          total: result.total,
          free: result.free,
          occupied: result.occupied,
          slots: result.slots,
          createdAt: serverTimestamp(),
        });
        setSaveSuccess(true);
        setButtonDisabled(true);
        setShowDialog(true);
      } catch (firebaseErr) {
        setSaveError("Parking creation failed: " + (firebaseErr.message || firebaseErr.toString()));
        setButtonDisabled(false);
        setProcessing(false);
        return;
      }
    } catch (err) {
      setSaveError(err.message || "Failed to process video");
    } finally {
      setProcessing(false);
    }
  };

  return (
    <>
      <Box
        sx={{
          minHeight: "100vh",
          width: "100vw",
          position: "fixed",
          top: 0,
          left: 0,
          zIndex: 0,
          '::before': {
            content: '""',
            position: "absolute",
            top: 0,
            left: 0,
            width: "100%",
            height: "100%",
            zIndex: 0,
            opacity: 1,
            background: "linear-gradient(120deg, #1976d2 0%, #2196f3 25%, #64b5f6 50%, #0d47a1 75%, #1976d2 100%)",
            backgroundSize: "400% 400%",
            animation: "gradientBG 18s ease-in-out infinite",
            filter: "blur(8px)",
          },
          '::after': {
            content: '""',
            position: "absolute",
            top: 0,
            left: 0,
            width: "100%",
            height: "100%",
            zIndex: 1,
            background: "linear-gradient(120deg, rgba(255,255,255,0.15) 0%, rgba(255,255,255,0.05) 100%)",
          },
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
        }}
      >
        {/* Animated cars */}
        <svg className="parking-bg-car" viewBox="0 0 100 60">
          <rect x="15" y="25" width="70" height="20" rx="10" fill="#1976d2" stroke="#0d47a1" strokeWidth="2" />
          <rect x="25" y="28" width="20" height="10" rx="3" fill="#bbdefb" />
          <rect x="55" y="28" width="20" height="10" rx="3" fill="#bbdefb" />
          <rect x="30" y="20" width="40" height="10" rx="5" fill="#2196f3" />
          <ellipse cx="18" cy="35" rx="3" ry="2" fill="#fffde7" />
          <ellipse cx="82" cy="35" rx="3" ry="2" fill="#fffde7" />
          <ellipse cx="30" cy="50" rx="7" ry="7" fill="#263238" stroke="#90caf9" strokeWidth="2" />
          <ellipse cx="70" cy="50" rx="7" ry="7" fill="#263238" stroke="#90caf9" strokeWidth="2" />
          <rect x="48" y="37" width="4" height="2" rx="1" fill="#90caf9" />
        </svg>

        <Container maxWidth="sm" sx={{ mt: 6, position: "relative", zIndex: 2 }}>
          <Paper elevation={4} sx={{ p: 4, borderRadius: 3 }}>
            <Typography variant="h5" fontWeight={600} gutterBottom>
              Upload Parking Video
            </Typography>

            <Box sx={{ display: "flex", flexDirection: "column", gap: 2 }}>
              <TextField
                label="Parking ID (PUID)"
                value={puid}
                InputProps={{ readOnly: true }}
              />

              <Button variant="outlined" component="label" sx={{ textTransform: "none" }}>
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
                    style={{ width: "100%", borderRadius: 8, boxShadow: "0 2px 8px rgba(0,0,0,0.15)" }}
                  />
                  <Button
                    variant="contained"
                    color="secondary"
                    sx={{ mt: 2, width: "100%" }}
                    onClick={processVideo}
                    disabled={processing || buttonDisabled}
                    startIcon={processing ? <CircularProgress size={20} color="inherit" /> : null}
                  >
                    {processing ? "Processing..." : buttonDisabled ? "Saved" : "Process Video"}
                  </Button>
                </Box>
              )}
            </Box>
          </Paper>
          <Snackbar open={saveSuccess} autoHideDuration={4000} onClose={() => setSaveSuccess(false)} anchorOrigin={{ vertical: 'top', horizontal: 'center' }}>
            <Alert onClose={() => setSaveSuccess(false)} severity="success" sx={{ width: '100%' }}>
              Slot monitoring results saved to Firestore!
            </Alert>
          </Snackbar>
          <Snackbar open={!!saveError} autoHideDuration={5000} onClose={() => setSaveError("")} anchorOrigin={{ vertical: 'top', horizontal: 'center' }}>
            <Alert onClose={() => setSaveError("")} severity="error" sx={{ width: '100%' }}>
              {saveError}
            </Alert>
          </Snackbar>
          <Dialog open={showDialog} onClose={() => setShowDialog(false)}>
            <DialogTitle>Success</DialogTitle>
            <DialogContent>
              Parking slot monitoring results have been saved successfully.
            </DialogContent>
            <DialogActions>
              <Button onClick={() => { setShowDialog(false); navigate("/dashboard"); }} color="primary" autoFocus>
                OK
              </Button>
            </DialogActions>
          </Dialog>
        </Container>
      </Box>
    </>
  );
}
