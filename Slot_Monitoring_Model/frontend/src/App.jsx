import React from "react";
import { BrowserRouter as Router, Routes, Route, Navigate } from "react-router-dom";
import Login from "./Component/login.jsx";
import UserRequestDashboard from "./Component/UserRequestDashboard";
import ParkingDashboard from "./Component/ParkingDashboard";
import UserDetailScreen from "./Component/UserDetailScreen";
import PendingOwnerForm from "./Component/PendingOwnerform";
import ParkingDetailScreen from "./Component/ParkingDetailscreen.jsx";
import PendingParkingForm from "./Component/PendingParkingForm.jsx";
import "./App.css";

// Auth check
const isAuthenticated = () => localStorage.getItem("isAuthenticated") === "true";

// PrivateRoute wrapper
const PrivateRoute = ({ children }) =>
  isAuthenticated() ? children : <Navigate to="/login" replace />;

function App() {
  return (
    <Router>
      <Routes>
        {/* Root path: redirect or show login */}
        <Route
          path="/"
          element={
            isAuthenticated() ? (
              <Navigate to="/dashboard" replace />
            ) : (
              <Login />
            )
          }
        />

        {/* Login route (in case accessed explicitly) */}
        <Route path="/login" element={<Login />} />

        {/* Protected Routes */}
        <Route
          path="/dashboard"
          element={
            <PrivateRoute>
              <UserRequestDashboard />
            </PrivateRoute>
          }
        />
        <Route
          path="/parking-dashboard"
          element={
            <PrivateRoute>
              <ParkingDashboard />
            </PrivateRoute>
          }
        />
        <Route
          path="/user/:uid"
          element={
            <PrivateRoute>
              <UserDetailScreen />
            </PrivateRoute>
          }
        />
        <Route
          path="/pendingOwnerform/:uid"
          element={
            <PrivateRoute>
              <PendingOwnerForm />
            </PrivateRoute>
          }
        />
        <Route
          path="/parking/:uid"
          element={
            <PrivateRoute>
              <ParkingDetailScreen />
            </PrivateRoute>
          }
        />
        <Route
          path="/pendingParkingform/:uid"
          element={
            <PrivateRoute>
              <PendingParkingForm />
            </PrivateRoute>
          }
        />

        {/* Fallback route */}
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Router>
  );
}

export default App;
