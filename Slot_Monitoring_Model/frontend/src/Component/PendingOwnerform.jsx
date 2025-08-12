import { getApp } from "firebase/app";
import CarAnimation from "./CarAnimation";
import React, { useState, useEffect } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import { getFirestore, collection, addDoc, serverTimestamp, query, where, getDocs } from "firebase/firestore";
import { Box, Button, Container, TextField, Typography, Paper, Snackbar, Alert, CircularProgress, Dialog, DialogTitle, DialogContent, DialogActions } from "@mui/material";

// Tailwind animation keyframes
const carMoveKeyframes = `
@keyframes carMove {
  0% { left: -120px; }
  100% { left: 100vw; }
}
`;

export default function PendingOwnerForm() {
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
    // Inject keyframes for carMove animation
    const style = document.createElement("style");
    style.innerHTML = carMoveKeyframes;
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
      <div className="min-h-screen overflow-y-auto flex items-center justify-center bg-gradient-to-br from-blue-700 via-blue-500 to-blue-900">
        {/* Animated cars - sticky to bottom */}
        <div className="fixed left-0 bottom-0 w-full pointer-events-none z-10">
          <CarAnimation variant={1} />
        </div>

        {/* Overlay gradients */}
        <div className="absolute top-0 left-0 w-full h-full z-0 bg-gradient-to-br from-blue-700/80 via-blue-300/20 to-blue-900/80 blur-md"></div>
        <div className="absolute top-0 left-0 w-full h-full z-1 bg-gradient-to-br from-white/15 to-white/5"></div>

        <div className="relative z-20 w-full flex justify-center items-center my-24!">
          <div className="max-w-md w-full">
            <div className="bg-white rounded-2xl shadow-lg p-6!">
              <Typography variant="h5" fontWeight={600} gutterBottom>
                Upload Parking Video
              </Typography>
              <div className="flex flex-col gap-4">
                <TextField
                  label="Parking ID (PUID)"
                  value={puid}
                  InputProps={{ readOnly: true }}
                  className="mt-2!"
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
                  <div className="mt-4">
                    <Typography variant="subtitle1" gutterBottom>
                      Video Preview:
                    </Typography>
                    <video
                      src={videoPreview}
                      controls
                      className="w-full rounded-lg shadow-md"
                    />
                    <Button
                      variant="contained"
                      color="secondary"
                      className="rounded-lg! py-3!  "
                      sx={{ mt: 2, width: "100%" }}
                      onClick={processVideo}
                      disabled={processing || buttonDisabled}
                      startIcon={processing ? <CircularProgress size={20} color="inherit" /> : null}
                    >
                      {processing ? "Processing..." : buttonDisabled ? "Saved" : "Process Video"}
                    </Button>
                  </div>
                )}
              </div>
            </div>
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
          </div>
        </div>
      </div>
    </>
  );
}