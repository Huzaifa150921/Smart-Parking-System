import React, { useState } from "react";

function App() {
  const [video, setVideo] = useState(null);
  const [pid, setPid] = useState("");
  const [videoId, setVideoId] = useState("");
  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(false);
  const [showVideo, setShowVideo] = useState(true);

  const handleUpload = async (e) => {
    e.preventDefault();
    if (!video || !pid) return;
    setLoading(true);
    const formData = new FormData();
    formData.append("video", video);
    formData.append("pid", pid);

    const res = await fetch("http://localhost:5000/uploads", {
      method: "POST",
      body: formData,
    });
    const data = await res.json();
    setVideoId(data.video_id);
    setLoading(false);
    setShowVideo(true);
  };

  const handleProcess = async () => {
    if (!videoId) return;
    setLoading(true);
    const res = await fetch("http://localhost:5000/process", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ video_id: videoId }),
    });
    const data = await res.json();
    setResult(data);
    setLoading(false);
    setShowVideo(false); // Hide video after processing
  };

  return (
    <div style={{ maxWidth: 500, margin: "auto", padding: 20 }}>
      <h2>Upload and Process Video</h2>
      <form onSubmit={handleUpload}>
        <input
          type="text"
          placeholder="PID"
          value={pid}
          onChange={(e) => setPid(e.target.value)}
          required
        />
        <br />
        <input
          type="file"
          accept="video/*"
          onChange={(e) => setVideo(e.target.files[0])}
          required
        />
        <br />
        <button type="submit" disabled={loading}>
          Upload Video
        </button>
      </form>
      {videoId && showVideo && (
        <div>
          <p>Video uploaded! ID: {videoId}</p>
          <video width="400" controls>
            <source
              src={video ? URL.createObjectURL(video) : ""}
              type={video ? video.type : "video/mp4"}
            />
            Your browser does not support the video tag.
          </video>
          <button onClick={handleProcess} disabled={loading}>
            Process Video
          </button>
        </div>
      )}
      {loading && <p>Loading...</p>}
      {result && (
        <div>
          <h3>Result:</h3>
          <p>Total Slots: {result.total_slots}</p>
          <p>Free Slots: {result.free_slots}</p>
          <p>Occupied Slots: {result.occupied_slots}</p>
          <pre>{JSON.stringify(result, null, 2)}</pre>
        </div>
      )}
    </div>
  );
}

export default App;
