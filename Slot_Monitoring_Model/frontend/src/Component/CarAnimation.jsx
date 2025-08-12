// CarAnimation component
export default function CarAnimation({ variant = 1 }) {
  if (variant === 1) {
    return (
      <svg
        className="absolute left-0"
        style={{
          bottom: "40px",
          width: "100px",
          height: "60px",
          opacity: 0.7,
          animation: "carMove 12s linear infinite",
        }}
        viewBox="0 0 100 60"
      >
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
    );
  }
  return (
    <svg
      className="absolute left-0"
      style={{
        bottom: "100px",
        width: "80px",
        height: "48px",
        opacity: 0.5,
        animation: "carMove 18s linear infinite",
        animationDelay: "6s",
      }}
      viewBox="0 0 80 48"
    >
      <rect x="10" y="18" width="60" height="16" rx="8" fill="#1565c0" stroke="#0d47a1" strokeWidth="2" />
      <rect x="18" y="21" width="15" height="7" rx="2" fill="#e3f2fd" />
      <rect x="47" y="21" width="15" height="7" rx="2" fill="#e3f2fd" />
      <rect x="25" y="13" width="30" height="7" rx="3" fill="#42a5f5" />
      <ellipse cx="13" cy="26" rx="2" ry="1.5" fill="#fffde7" />
      <ellipse cx="67" cy="26" rx="2" ry="1.5" fill="#fffde7" />
      <ellipse cx="22" cy="38" rx="5" ry="5" fill="#263238" stroke="#90caf9" strokeWidth="2" />
      <ellipse cx="58" cy="38" rx="5" ry="5" fill="#263238" stroke="#90caf9" strokeWidth="2" />
      <rect x="38" y="28" width="3" height="1.5" rx="0.75" fill="#90caf9" />
    </svg>
  );
}