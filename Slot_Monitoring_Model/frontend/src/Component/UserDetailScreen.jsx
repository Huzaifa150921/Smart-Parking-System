import React, { useEffect, useState } from "react";
import {
  Box,
  Typography,
  Button,
  Avatar,
  Divider,
  Grid,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Paper,
  Card,
  CardMedia,
  CardContent,
} from "@mui/material";
import {
  doc,
  getDoc,
  updateDoc,
  collection,
  query,
  where,
  limit,
  getDocs,
} from "firebase/firestore";
import { firestore } from "../Firebase";
import { useParams, useNavigate } from "react-router-dom";
import Loader from "./Loader";

export default function UserDetailScreen() {
  const { uid } = useParams();
  const navigate = useNavigate();

  const [userData, setUserData] = useState(null);
  const [userInfo, setUserInfo] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [rejectDialogOpen, setRejectDialogOpen] = useState(false);
  const [rejectReason, setRejectReason] = useState("");
  const [approvalMessage, setApprovalMessage] = useState("");
  const [isApproveDisabled, setIsApproveDisabled] = useState(false);

  useEffect(() => {
    const fetchUserData = async () => {
      try {
        // Check if parking already exists
        const parkingQuery = query(
          collection(firestore, "parkings"),
          where("uid", "==", uid)
        );
        const parkingSnapshot = await getDocs(parkingQuery);
        if (!parkingSnapshot.empty) {
          console.log("Parking already exists:", parkingSnapshot.docs[0].id);
        }

        const pendingRef = doc(firestore, "pending_owner", uid);
        const userRef = doc(firestore, "users", uid);
        const [pendingSnap, userSnap] = await Promise.all([
          getDoc(pendingRef),
          getDoc(userRef),
        ]);

        if (!pendingSnap.exists()) {
          setError("No pending owner found.");
          return;
        }
        if (!userSnap.exists()) {
          setError("No user found.");
          return;
        }

        setUserData(pendingSnap.data());
        setUserInfo(userSnap.data());
      } catch (err) {
        setError("Error fetching user data.");
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    fetchUserData();
  }, [uid]);

  const handleApprove = async () => {
    try {
      setIsApproveDisabled(true);
      const pendingRef = doc(firestore, "pending_owner", uid);
      await updateDoc(pendingRef, { status: "approved" });
      setApprovalMessage("Approved. Waiting for parking creation...");

      let parkingDoc = null;
      const maxAttempts = 25;
      let attempts = 0;

      while (attempts < maxAttempts) {
        const q = query(
          collection(firestore, "parkings"),
          where("uid", "==", uid),
          limit(1)
        );
        const snapshot = await getDocs(q);

        if (!snapshot.empty) {
          parkingDoc = snapshot.docs[0];
          break;
        }

        attempts++;
        const wait = Math.min(1000 * Math.pow(1.3, attempts), 7000);
        await new Promise((res) => setTimeout(res, wait));
      }

      if (!parkingDoc) {
        alert("Parking creation timed out. Please check Firebase.");
        return;
      }

      const puid = parkingDoc.id;
      const parkingData = parkingDoc.data();
      console.log("✅ Parking Created:");
      console.log("PUID:", puid);
      console.log("Data:", parkingData);

      navigate(`/pendingOwnerform/${uid}`, { state: { puid } });
    } catch (err) {
      console.error("Error during approval:", err);
      alert("Approval failed.");
    }
  };

  if (loading) return <Loader />;

  if (error) {
    return (
      <Box
        sx={{
          height: "100vh",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          bgcolor: "#f0f2f5",
        }}
      >
        <Box textAlign="center">
          <Typography color="error" variant="h6">
            {error}
          </Typography>
          <Button onClick={() => navigate(-1)} sx={{ mt: 2 }} variant="outlined">
            Go Back
          </Button>
        </Box>
      </Box>
    );
  }

  const {
    firstName,
    lastName,
    parkingName,
    parkingAddress,
    profilePic,
    parkingImage,
  } = userData || {};
  const { email, phoneNumber } = userInfo || {};

  return (
    <Box
      sx={{
        height: "100vh",
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
        px: 2,
        position: "relative",
        '::before': {
          content: '""',
          position: "absolute",
          top: 0,
          left: 0,
          width: "100%",
          height: "100%",
          zIndex: 0,
          background: "linear-gradient(270deg, #007bff, #00c6ff, #aee2ff, #d0e5ff, #007bff)",
          backgroundSize: "600% 600%",
          animation: "gradientBG 8s ease infinite",
        },
      }}
    >
      <style>
        {`
        @keyframes gradientBG {
          0% {background-position:0% 50%}
          50% {background-position:100% 50%}
          100% {background-position:0% 50%}
        }
      `}
      </style>

      <Paper
        elevation={6}
        sx={{
          display: "flex",
          flexDirection: { xs: "column", md: "row" },
          width: "100%",
          maxWidth: 1100,
          height: "90vh",
          borderRadius: 3,
          overflow: "hidden",
          backgroundImage: "linear-gradient(135deg, #ffffff, #f3f9ff)",
          position: "relative",
          zIndex: 1,
        }}
      >
        {/* Left Side */}
        <Box sx={{ flex: 1, p: 4, overflowY: "auto" }}>
          <Box textAlign="center" mb={3}>
            <Avatar
              src={profilePic ? `data:image/jpeg;base64,${profilePic}` : ""}
              sx={{
                width: 100,
                height: 100,
                mx: "auto",
                mb: 1,
                fontSize: 40,
                bgcolor: profilePic ? "transparent" : "primary.main",
              }}
            >
              {!profilePic && firstName?.[0]}
            </Avatar>
            <Typography variant="h5" fontWeight={600}>
              {firstName} {lastName}
            </Typography>
          </Box>

          <Divider sx={{ my: 3 }} />

          <Grid container spacing={2}>
            {[
              { label: "Email", value: email },
              { label: "Phone Number", value: phoneNumber },
              { label: "Parking Name", value: parkingName },
              { label: "Parking Address", value: parkingAddress },
            ].map((item, i) => (
              <Grid item xs={12} key={i}>
                <Typography variant="subtitle2" color="text.secondary">
                  {item.label}
                </Typography>
                <Typography variant="body1" fontWeight={500}>
                  {item.value || "N/A"}
                </Typography>
              </Grid>
            ))}
          </Grid>

          <Box mt={4}>
            <Grid container spacing={2} justifyContent="center">
              <Grid item>
                <Button
                  id="approve-btn"
                  variant="contained"
                  color="success"
                  sx={{ px: 4 }}
                  onClick={handleApprove}
                  disabled={isApproveDisabled}
                >
                  Approve
                </Button>
              </Grid>
              <Grid item>
                <Button
                  variant="contained"
                  color="error"
                  sx={{ px: 4 }}
                  onClick={() => setRejectDialogOpen(true)}
                >
                  Reject
                </Button>
              </Grid>
            </Grid>

            {approvalMessage && (
              <Typography
                variant="body2"
                color="success.main"
                textAlign="center"
                mt={2}
                fontWeight={500}
              >
                {approvalMessage}
              </Typography>
            )}

            <Box mt={3} textAlign="center">
              <Button variant="outlined" onClick={() => navigate(-1)}>
                Back to Dashboard
              </Button>
            </Box>
          </Box>
        </Box>

        {/* Right Side */}
        {parkingImage && (
          <Box
            sx={{
              flex: 1,
              backgroundColor: "#e8f1ff",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              p: 4,
            }}
          >
            <Card
              sx={{
                width: "100%",
                boxShadow: 4,
                borderRadius: 3,
                background: "linear-gradient(145deg, #ffffff, #e3efff)",
              }}
            >
              <CardContent>
                <Typography variant="h6" fontWeight={600} textAlign="center">
                  Parking Image
                </Typography>
              </CardContent>
              <CardMedia
                component="img"
                image={`data:image/jpeg;base64,${parkingImage}`}
                alt="Parking"
                sx={{
                  height: 400,
                  objectFit: "cover",
                  borderRadius: "0 0 12px 12px",
                }}
              />
            </Card>
          </Box>
        )}
      </Paper>

      {/* Reject Dialog */}
      <Dialog open={rejectDialogOpen} onClose={() => setRejectDialogOpen(false)}>
        <DialogTitle>Rejection Reason</DialogTitle>
        <DialogContent>
          <TextField
            autoFocus
            fullWidth
            multiline
            minRows={3}
            label="Reason"
            variant="outlined"
            value={rejectReason}
            onChange={(e) => setRejectReason(e.target.value)}
            sx={{ mt: 1 }}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setRejectDialogOpen(false)}>Cancel</Button>
          <Button
            variant="contained"
            color="error"
            disabled={!rejectReason.trim()}
            onClick={async () => {
              try {
                const pendingRef = doc(firestore, "pending_owner", uid);
                await updateDoc(pendingRef, {
                  reason: rejectReason.trim(),
                  status: "rejected",
                });
                navigate("/pendingOwnerform");
              } catch (err) {
                console.error("Failed to save rejection reason:", err);
              }
            }}
          >
            Confirm
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}
