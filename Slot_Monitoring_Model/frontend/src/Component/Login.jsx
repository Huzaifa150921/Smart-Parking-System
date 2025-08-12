// Component/login.jsx
import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import "./login.css";
import "./login-bg.css";
import { doc, getDoc } from "firebase/firestore";
import { firestore } from "../Firebase";

const Login = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const navigate = useNavigate();

  // Redirect if already logged in
  useEffect(() => {
    if (localStorage.getItem("isAuthenticated") === "true") {
      navigate("/dashboard", { replace: true });
    }
  }, [navigate]);

  const handleSubmit = async (e) => {
    e.preventDefault();

    try {
      const adminRef = doc(firestore, "admin", "admin");
      const adminSnap = await getDoc(adminRef);
      if (!adminSnap.exists()) {
        setError("Admin record not found");
        return;
      }
      const adminData = adminSnap.data();
      if (email === "admin" && password === adminData.password) {
        localStorage.setItem("isAuthenticated", "true");
        setError("");
        navigate("/dashboard");
      } else {
        setError("Invalid username or password");
      }
    } catch (err) {
      setError("Something went wrong. Please try again.");
    }
  };

  return (
    <div className="login-bg">
      <div className="container">
        <div className="heading">Sign In</div>
        <form className="form" onSubmit={handleSubmit}>
          <input
            required
            className="input"
            type="text"
            name="email"
            placeholder="Username"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
          <input
            required
            className="input"
            type="password"
            name="password"
            placeholder="Password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
          {error && (
            <div style={{ color: "red", textAlign: "center", marginBottom: "8px" }}>
              {error}
            </div>
          )}
          <input className="login-button" type="submit" value="Sign In" />
        </form>
      </div>
    </div>
  );
};

export default Login;
