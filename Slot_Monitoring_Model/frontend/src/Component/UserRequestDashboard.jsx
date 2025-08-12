import React, {
  createContext,
  useContext,
  useMemo,
  useState,
  useEffect,
} from "react";
import {
  AppBar,
  Toolbar,
  Typography,
  Tabs,
  Tab,
  Box,
  Paper,
  Grid,
  Button,
  Chip,
  IconButton,
  CssBaseline,
  Menu,
  MenuItem,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
} from "@mui/material";
import { createTheme, ThemeProvider } from "@mui/material/styles";
import {
  collection,
  onSnapshot,
  doc,
  getDoc,
  updateDoc,
} from "firebase/firestore";
import { firestore } from "../Firebase";
import { useNavigate } from "react-router-dom";

// React Icons
import {
  MdDashboard,
  MdPerson,
  MdLightMode,
  MdDarkMode,
  MdLogout,
  MdLock,
  MdPending,
  MdCheckCircle,
  MdCancel,
  MdDirectionsCar,
  MdVisibility,
  MdContentPasteOff,
} from "react-icons/md";
import { IoPersonCircleSharp } from "react-icons/io5";
import { FaParking } from "react-icons/fa";

import "./user-request-dashboard-bg.css";

// Theme context
const ColorModeContext = createContext({
  toggleColorMode: () => {},
  mode: "light",
});

function OwnerCards({ owners, onDetailClick, showDetailButton }) {
  const colorMode = useContext(ColorModeContext);

  if (owners.length === 0) {
    return (
      <Grid item xs={12}>
        <Box
          sx={{
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            justifyContent: "center",
            minHeight: "400px",
            textAlign: "center",
            position: "absolute",
            top: "50%",
            left: "50%",
            transform: "translate(-50%, -50%)",
            width: "100%",
            maxWidth: "500px",
          }}
        >
          <MdContentPasteOff
            size={80}
            color={colorMode.mode === "dark" ? "#64b5f6" : "#1976d2"}
          />
          <Typography
            variant="h5"
            sx={{
              mt: 3,
              color: colorMode.mode === "dark" ? "#fff" : "#1976d2",
              fontWeight: 700,
            }}
          >
            No Records Found
          </Typography>
          <Typography
            variant="p"
            sx={{
              mt: 2,
              color: colorMode.mode === "dark" ? "#ccc" : "#666",
              maxWidth: 450,
              fontWeight: 400,
            }}
          >
            There are currently no user requests in this category.
          </Typography>
        </Box>
      </Grid>
    );
  }

  return owners.map((owner) => (
    <Grid item xs={12} md={6} lg={4} key={owner.id}>
      <Paper
        elevation={8}
        sx={{
          p: 0,
          borderRadius: 3,
          background: colorMode.mode === "dark" ? "#1e1e1e" : "#ffffff",
          border: `2px solid ${colorMode.mode === "dark" ? "#333" : "#e0e0e0"}`,
          position: "relative",
          overflow: "visible",
          minWidth: 240,
          maxWidth: 320,
          mx: "auto",
          my: 3,
          transition: "transform 0.3s ease, box-shadow 0.3s ease",
          "&:hover": {
            transform: "translateY(-8px)",
            boxShadow:
              colorMode.mode === "dark"
                ? "0 12px 32px rgba(100, 181, 246, 0.3)"
                : "0 12px 32px rgba(25, 118, 210, 0.2)",
          },
          borderTop: `4px solid #2196f3`,
        }}
      >
        {/* Avatar circle */}
        <Box
          sx={{
            position: "absolute",
            top: -32,
            left: "50%",
            transform: "translateX(-50%)",
            width: 64,
            height: 64,
            borderRadius: "50%",
            background: "#2196f3",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            border: `4px solid ${
              colorMode.mode === "dark" ? "#1e1e1e" : "#fff"
            }`,
            zIndex: 2,
          }}
        >
          <MdPerson size={32} color="#fff" />
        </Box>

        <Box
          sx={{
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            gap: 1,
            p: 3,
            pt: 5.5,
          }}
        >
          <Typography
            variant="h6"
            sx={{
              fontWeight: 700,
              color: colorMode.mode === "dark" ? "#fff" : "#2196f3",
              fontSize: 20,
              mb: 0.5,
              textAlign: "center",
            }}
          >
            {owner.firstName || "Unnamed"}
          </Typography>

          <Box sx={{ display: "flex", alignItems: "center", gap: 1, mb: 1 }}>
            <FaParking
              size={16}
              color={colorMode.mode === "dark" ? "#64b5f6" : "#1976d2"}
            />
            <Typography
              sx={{
                color: colorMode.mode === "dark" ? "#ccc" : "#666",
                fontSize: 14,
                fontWeight: 500,
              }}
            >
              {owner.parkingName || "N/A"}
            </Typography>
          </Box>

          <Chip
            icon={
              owner.status === "approved" ? (
                <MdCheckCircle size={16} />
              ) : owner.status === "rejected" ? (
                <MdCancel size={16} />
              ) : (
                <MdPending size={16} />
              )
            }
            label={owner.status?.toUpperCase()}
            sx={{
              fontWeight: 600,
              fontSize: 12,
              px: 2,
              py: 0.5,
              color: "#fff",
              mb: 2,
              borderRadius: 2,
              background:
                owner.status === "approved"
                  ? "#4caf50"
                  : owner.status === "rejected"
                  ? "#f44336"
                  : "#ff9800",
            }}
          />

          {showDetailButton && (
            <Box mt={1} width="100%">
              <Button
                fullWidth
                variant="contained"
                startIcon={<MdVisibility />}
                sx={{
                  borderRadius: 2,
                  background: "#2196f3",
                  color: "#fff",
                  fontWeight: 600,
                  fontSize: 14,
                  textTransform: "none",
                  py: 1,
                  "&:hover": {
                    background: "#1976d2",
                  },
                }}
                onClick={() => onDetailClick(owner.id)}
              >
                View Details
              </Button>
            </Box>
          )}
        </Box>
      </Paper>
    </Grid>
  ));
}

function UserRequestDashboard() {
  const navigate = useNavigate();
  const colorMode = useContext(ColorModeContext);

  // Profile menu state
  const [anchorEl, setAnchorEl] = useState(null);
  const open = Boolean(anchorEl);

  const handleProfileClick = (event) => {
    setAnchorEl(event.currentTarget);
  };

  const handleProfileClose = () => {
    setAnchorEl(null);
  };

  const handleLogout = () => {
    localStorage.clear();
    sessionStorage.clear();
    window.location.replace("/");
    handleProfileClose();
  };

  // Change password modal state
  const [openChangePassword, setOpenChangePassword] = useState(false);
  const [oldPassword, setOldPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [error, setError] = useState("");

  const handleChangePassword = () => {
    setOpenChangePassword(true);
    handleProfileClose();
  };

  const handleCloseChangePassword = () => {
    setOpenChangePassword(false);
    setOldPassword("");
    setNewPassword("");
    setConfirmPassword("");
    setError("");
  };

  const handleSubmitChangePassword = async () => {
    if (!oldPassword || !newPassword || !confirmPassword) {
      setError("All fields are required.");
      return;
    }

    if (newPassword !== confirmPassword) {
      setError("New password and confirm password do not match.");
      return;
    }

    try {
      const adminRef = doc(firestore, "admin", "admin");
      const adminSnap = await getDoc(adminRef);

      if (!adminSnap.exists()) {
        setError("Admin record not found.");
        return;
      }

      const adminData = adminSnap.data();

      if (adminData.password !== oldPassword) {
        setError("Old password is incorrect.");
        return;
      }

      await updateDoc(adminRef, { password: newPassword });

      setOpenChangePassword(false);
      setOldPassword("");
      setNewPassword("");
      setConfirmPassword("");
      setError("");
      alert("Password changed successfully!");
    } catch (error) {
      console.error("Error changing password:", error);
      setError("Something went wrong. Please try again.");
    }
  };

  const [owners, setOwners] = useState([]);
  const [value, setValue] = useState(0);

  useEffect(() => {
    const unsub = onSnapshot(collection(firestore, "pending_owner"), (snap) => {
      setOwners(snap.docs.map((doc) => ({ id: doc.id, ...doc.data() })));
    });
    return () => unsub();
  }, []);

  const filteredOwners = (status) =>
    owners.filter(
      (o) =>
        o.status?.toLowerCase() === status &&
        (status !== "pending" || o.formSubmitted === true)
    );

  const backgroundColor = colorMode.mode === "dark" ? "#121212" : "#f5f5f5";

  return (
    <Box
      sx={{
        minHeight: "100vh",
        background: backgroundColor,
        transition: "background 0.3s",
        position: "relative",
      }}
    >
      <CssBaseline />
      {/* AppBar */}
      <AppBar
        position="static"
        sx={{
          background: colorMode.mode === "dark" ? "#1976d2" : "#2196f3",
          boxShadow: "none",
        }}
      >
        <Toolbar>
          <Box sx={{ display: "flex", alignItems: "center", flexGrow: 1 }}>
            <Box
              sx={{
                display: "flex",
                alignItems: "center",
                background: "#1565c0",
                px: 2,
                py: 1,
                borderRadius: 2,
                color: "#fff",
                fontWeight: 600,
                fontSize: 18,
                mr: 2,
              }}
            >
              <MdDashboard size={24} style={{ marginRight: 8 }} />
              User Dashboard
            </Box>
          </Box>

          <Button
            color="inherit"
            startIcon={<FaParking />}
            onClick={() => navigate("/parking-dashboard")}
            sx={{
              borderRadius: 2,
              background: "#1565c0",
              color: "#fff",
              fontWeight: 500,
              fontSize: 13,
              px: 2,
              py: 1,
              mr: 2,
              textTransform: "none",
              "&:hover": {
                background: "#0d47a1",
              },
            }}
          >
            Parking Dashboard
          </Button>

          <IconButton
            onClick={colorMode.toggleColorMode}
            color="inherit"
            sx={{ mr: 1 }}
          >
            {colorMode.mode === "dark" ? (
              <MdLightMode size={24} />
            ) : (
              <MdDarkMode size={24} />
            )}
          </IconButton>

          <IconButton
            color="inherit"
            onClick={handleProfileClick}
            aria-controls={open ? "profile-menu" : undefined}
            aria-haspopup="true"
            aria-expanded={open ? "true" : undefined}
          >
            <IoPersonCircleSharp size={32} />
          </IconButton>

          {/* Profile Menu */}
          <Menu
            id="profile-menu"
            anchorEl={anchorEl}
            open={open}
            onClose={handleProfileClose}
            anchorOrigin={{ vertical: "bottom", horizontal: "right" }}
            transformOrigin={{ vertical: "top", horizontal: "right" }}
          >
            <MenuItem
              onClick={handleChangePassword}
              sx={{ fontWeight: 500, fontSize: 14 }}
            >
              <MdLock size={18} style={{ marginRight: 8 }} />
              Change Password
            </MenuItem>
            <MenuItem
              onClick={handleLogout}
              sx={{ fontWeight: 500, fontSize: 14 }}
            >
              <MdLogout size={18} style={{ marginRight: 8 }} />
              Logout
            </MenuItem>
          </Menu>
        </Toolbar>
      </AppBar>
      {/* Change Password Dialog */}
      <Dialog
        open={openChangePassword}
        onClose={handleCloseChangePassword}
        maxWidth="xs"
        fullWidth
      >
        <DialogTitle
          sx={{
            fontWeight: 600,
            textAlign: "center",
            color: "#2196f3",
            background: colorMode.mode === "dark" ? "#1e1e1e" : "#f5f5f5",
          }}
        >
          <MdLock
            size={24}
            style={{ marginRight: 8, verticalAlign: "middle" }}
          />
          Change Password
        </DialogTitle>
        <DialogContent
          sx={{
            background: colorMode.mode === "dark" ? "#1e1e1e" : "#f5f5f5",
            p: 3,
          }}
        >
          <Box sx={{ display: "flex", flexDirection: "column", gap: 2, mt: 1 }}>
            <TextField
              label="Old Password"
              type="password"
              value={oldPassword}
              onChange={(e) => setOldPassword(e.target.value)}
              fullWidth
              variant="outlined"
              sx={{
                background: colorMode.mode === "dark" ? "#333" : "#fff",
                borderRadius: 1,
              }}
            />
            <TextField
              label="New Password"
              type="password"
              value={newPassword}
              onChange={(e) => setNewPassword(e.target.value)}
              fullWidth
              variant="outlined"
              sx={{
                background: colorMode.mode === "dark" ? "#333" : "#fff",
                borderRadius: 1,
              }}
            />
            <TextField
              label="Confirm Password"
              type="password"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              fullWidth
              variant="outlined"
              sx={{
                background: colorMode.mode === "dark" ? "#333" : "#fff",
                borderRadius: 1,
              }}
            />
            {error && (
              <Typography
                color="error"
                sx={{ fontSize: 14, fontWeight: 500, textAlign: "center" }}
              >
                {error}
              </Typography>
            )}
          </Box>
        </DialogContent>
        <DialogActions
          sx={{
            justifyContent: "center",
            pb: 2,
            background: colorMode.mode === "dark" ? "#1e1e1e" : "#f5f5f5",
          }}
        >
          <Button
            onClick={handleCloseChangePassword}
            variant="outlined"
            sx={{ borderRadius: 2, px: 3, fontWeight: 500 }}
          >
            Cancel
          </Button>
          <Button
            onClick={handleSubmitChangePassword}
            variant="contained"
            sx={{
              borderRadius: 2,
              px: 3,
              background: "#2196f3",
              fontWeight: 500,
              "&:hover": { background: "#1976d2" },
            }}
          >
            Change Password
          </Button>
        </DialogActions>
      </Dialog>
      {/* Tabs */}
      <Paper
        elevation={0}
        sx={{
          background: colorMode.mode === "dark" ? "#1e1e1e" : "#fff",
          borderBottom: `1px solid ${
            colorMode.mode === "dark" ? "#333" : "#e0e0e0"
          }`,
        }}
      >
        <Tabs
          value={value}
          onChange={(e, v) => setValue(v)}
          centered
          sx={{
            ".MuiTab-root": {
              color: colorMode.mode === "dark" ? "#ccc" : "#666",
              fontWeight: 600,
              fontSize: 16,
              mx: 1,
              minWidth: 120,
              textTransform: "none",
            },
            ".Mui-selected": {
              color: "#2196f3",
            },
            ".MuiTabs-indicator": {
              backgroundColor: "#2196f3",
              height: 3,
            },
          }}
        >
          <Tab
            label="Pending"
            icon={<MdPending size={20} />}
            iconPosition="start"
          />
          <Tab
            label="Approved"
            icon={<MdCheckCircle size={20} />}
            iconPosition="start"
          />
          <Tab
            label="Rejected"
            icon={<MdCancel size={20} />}
            iconPosition="start"
          />
        </Tabs>
      </Paper>
      {/* Content */}
      <Box
        p={3}
        sx={{ position: "relative", minHeight: "calc(100vh - 200px)" }}
      >
        <Grid container spacing={3}>
          <OwnerCards
            owners={
              value === 0
                ? filteredOwners("pending")
                : value === 1
                ? filteredOwners("approved")
                : filteredOwners("rejected")
            }
            onDetailClick={(id) => navigate(`/user/${id}`)}
            showDetailButton={value === 0}
          />
        </Grid>
      </Box>

      {/* Car Animation */}
      <Box
        sx={{
          position: "absolute",
          left: 0,
          bottom: 16,
          width: "100%",
          zIndex: 10,
          pointerEvents: "none",
          height: 60,
        }}
      >
        <style>{`
  @keyframes carMove {
    0% { left: 0; }
    100% { left: calc(100% - 120px); }
  }
  .car-animation {
    position: absolute;
    left: 0;
    bottom: 0;
    animation: carMove 6s linear infinite alternate;
  }
`}</style>
        <div className="car-animation">
          <svg
            width="120"
            height="60"
            viewBox="0 0 1280 640"
            preserveAspectRatio="xMidYMid meet"
            xmlns="http://www.w3.org/2000/svg"
          >
            <g
              transform="translate(0.000000,640.000000) scale(0.100000,-0.100000)"
              fill={colorMode.mode === "dark" ? "#64b5f6" : "#1976d2"}
              stroke="none"
            >
              <path
                d="M3565 5336 c-106 -30 -101 -26 -108 -111 -4 -42 -9 -80 -12 -85 -6
-10 -246 -105 -590 -234 -448 -167 -1052 -415 -1173 -483 -78 -43 -193 -91
-250 -104 -23 -5 -98 -14 -165 -19 -67 -6 -167 -19 -222 -30 -154 -31 -340
-49 -563 -57 l-203 -6 -43 -66 c-59 -91 -60 -95 -26 -130 37 -37 38 -65 3
-150 -25 -62 -27 -78 -31 -256 l-4 -190 -38 -32 c-91 -78 -133 -209 -134 -418
0 -194 11 -396 26 -482 13 -71 14 -74 72 -122 69 -58 130 -129 158 -184 64
-126 534 -211 1384 -250 l92 -4 -6 119 c-6 142 8 256 49 383 112 352 394 622
756 722 90 26 112 28 278 28 165 0 188 -2 278 -27 201 -56 361 -152 504 -302
140 -145 222 -293 274 -492 21 -79 24 -109 23 -279 -1 -127 -6 -214 -16 -263
l-15 -73 3006 7 c1653 4 3007 8 3009 9 1 1 -8 37 -20 81 -19 67 -22 105 -22
259 -1 166 1 187 27 279 117 421 467 736 885 797 119 17 325 7 432 -21 239
-63 453 -205 601 -399 70 -92 154 -267 185 -386 24 -88 27 -119 27 -260 1
-116 -4 -181 -16 -234 -10 -41 -16 -75 -15 -76 2 -1 62 2 133 6 266 16 458 45
525 79 48 24 97 81 127 146 l24 52 -16 157 c-15 152 -15 163 4 284 63 388 50
680 -35 802 -134 193 -526 336 -1429 519 -737 149 -1322 209 -2033 210 -228 0
-226 0 -347 85 -187 131 -1045 607 -1471 815 -383 187 -788 281 -1439 332
-208 17 -1106 16 -1400 0 -121 -7 -314 -19 -430 -27 -302 -22 -286 -22 -341
10 -140 81 -187 94 -269 71z m1885 -333 c6 -37 38 -238 71 -446 32 -209 66
-422 75 -474 9 -52 15 -96 13 -97 -11 -9 -1699 29 -1951 44 -206 13 -417 36
-485 54 -98 26 -198 119 -249 231 -35 75 -36 172 -5 255 17 45 30 61 68 86 83
54 135 80 253 127 341 136 858 230 1460 267 269 16 270 16 511 18 l227 2 12
-67z m630 47 c264 -18 777 -110 1029 -186 186 -56 445 -188 756 -387 211 -134
274 -181 250 -185 -75 -12 -133 -50 -162 -106 -19 -35 -21 -136 -4 -179 l11
-27 -907 2 -906 3 -59 160 c-110 302 -298 878 -298 916 0 6 95 2 290 -11z"
              />
              <path
                d="M2633 3125 c-223 -40 -410 -141 -568 -306 -132 -138 -213 -283 -262
-467 -22 -83 -26 -119 -26 -247 -1 -169 10 -236 65 -382 87 -230 271 -436 493
-551 85 -44 178 -78 271 -98 107 -23 312 -23 419 1 392 84 699 375 802 761 23
86 26 120 27 254 1 158 -5 199 -46 330 -98 310 -355 567 -668 669 -150 50
-354 64 -507 36z m350 -301 c249 -56 457 -247 543 -499 25 -72 28 -95 28 -220
1 -153 -15 -228 -74 -345 -94 -186 -283 -337 -485 -386 -96 -24 -268 -24 -360
0 -320 84 -544 355 -562 681 -20 359 209 673 558 765 94 24 253 26 352 4z"
              />
              <path
                d="M10700 3119 c-390 -84 -696 -376 -797 -759 -31 -117 -41 -292 -24
-411 33 -227 150 -453 318 -609 267 -250 643 -344 993 -249 117 32 283 118
380 196 487 396 518 1128 67 1560 -97 93 -166 140 -290 198 -137 64 -235 86
-407 91 -120 3 -162 0 -240 -17z m445 -313 c238 -81 409 -258 486 -506 30 -96
33 -289 5 -388 -110 -400 -513 -637 -911 -536 -149 38 -313 147 -402 267 -176
238 -203 533 -71 797 34 69 60 103 138 180 77 78 111 104 181 139 129 65 207
81 364 77 109 -3 143 -7 210 -30z"
              />
            </g>
          </svg>
        </div>
      </Box>
    </Box>
  );
}

// Theme provider wrapper
export default function ThemedApp() {
  const [mode, setMode] = useState("light");

  const colorMode = useMemo(
    () => ({
      toggleColorMode: () =>
        setMode((prevMode) => (prevMode === "light" ? "dark" : "light")),
      mode,
    }),
    [mode]
  );

  const theme = useMemo(
    () =>
      createTheme({
        palette: {
          mode,
          ...(mode === "light"
            ? {
                primary: { main: "#2196f3" },
                secondary: { main: "#64b5f6" },
                background: { default: "#f5f5f5", paper: "#ffffff" },
                text: { primary: "#333", secondary: "#666" },
                success: { main: "#4caf50" },
                warning: { main: "#ff9800" },
                error: { main: "#f44336" },
              }
            : {
                primary: { main: "#2196f3" },
                secondary: { main: "#64b5f6" },
                background: { default: "#121212", paper: "#1e1e1e" },
                text: { primary: "#fff", secondary: "#ccc" },
              }),
        },
        typography: {
          fontFamily: '"Roboto", "Helvetica", "Arial", sans-serif',
        },
        components: {
          MuiPaper: {
            styleOverrides: {
              root: {
                borderRadius: 8,
              },
            },
          },
          MuiButton: {
            styleOverrides: {
              root: {
                borderRadius: 8,
                textTransform: "none",
              },
            },
          },
        },
      }),
    [mode]
  );

  return (
    <ColorModeContext.Provider value={colorMode}>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        <UserRequestDashboard />
      </ThemeProvider>
    </ColorModeContext.Provider>
  );
}
