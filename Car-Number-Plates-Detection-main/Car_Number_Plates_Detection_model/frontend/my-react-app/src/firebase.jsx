import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyBVPj7V1qevVYySyHGdJw_wckOfALKvI5A",
  authDomain: "parkxpert-2731a.firebaseapp.com",
  projectId: "parkxpert-2731a",
  storageBucket: "parkxpert-2731a.appspot.com",
  messagingSenderId: "1087189910913",
  appId: "1:1087189910913:web:8960ca4d936dd467ef9480",
  measurementId: "G-35C9MR2BC3",
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

export { db };
