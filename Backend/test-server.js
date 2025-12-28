import express from "express";
import cors from "cors";

const app = express();
app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  console.log("✅ Request received!");
  res.json({ message: "Test server works!" });
});

app.get("/api/test", (req, res) => {
  console.log("✅ API test request received!");
  res.json({ success: true, message: "API works!" });
});

const PORT = 5000;
const server = app.listen(PORT, "localhost", () => {
  console.log(`✅ Test server running on localhost:${PORT}`);
});

server.on("error", (err) => {
  console.error("❌ Server error:", err);
});
