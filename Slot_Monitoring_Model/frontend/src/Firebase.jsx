// firebase.js

import { initializeApp } from "firebase/app";
import { getAnalytics, isSupported } from "firebase/analytics";
import { getFirestore } from "firebase/firestore";

// Your Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyBVPj7V1qevVYySyHGdJw_wckOfALKvI5A",
  authDomain: "parkxpert-2731a.firebaseapp.com",
  databaseURL: "https://parkxpert-2731a-default-rtdb.asia-southeast1.firebasedatabase.app",
  projectId: "parkxpert-2731a",
  storageBucket: "parkxpert-2731a.appspot.com",
  messagingSenderId: "1087189910913",
  appId: "1:1087189910913:web:8960ca4d936dd467ef9480",
  measurementId: "G-35C9MR2BC3",
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firestore
const firestore = getFirestore(app);

// Lazy-load analytics (optional usage)
let analyticsInstance = null;

const getAnalyticsInstance = async () => {
  if (!analyticsInstance) {
    const supported = await isSupported();
    if (supported) {
      analyticsInstance = getAnalytics(app);
    }
  }
  return analyticsInstance;
};

export { app, firestore, getAnalyticsInstance };
