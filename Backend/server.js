import express from "express";
import cors from "cors";
import cookieParser from "cookie-parser";
import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";
import authRoutes from "./routes/authRoutes.js";
import jobRoutes from "./routes/jobRoutes.js";
import candidateRoutes from "./routes/candidateRoutes.js";
import companyRoutes from "./routes/companyRoutes.js";
import analyticsRoutes from "./routes/analyticsRoutes.js";
import notificationRoutes from "./routes/notificationRoutes.js";
import resumeRoutes from "./routes/resumeRoutes.js";
import mlRoutes from "./routes/mlRoutes.js";
import hrRoutes from "./routes/hrRoutes.js";
import studentRoutes from "./routes/studentRoutes.js";
import chatRoutes from "./routes/chatRoutes.js";
import connectDB from "./config/database.js";
import { errorHandler, notFound } from "./middleware/errorMiddleware.js";

dotenv.config(); // تحميل متغيرات البيئة من ملف .env

// الاتصال بقاعدة البيانات
connectDB();

const app = express();

// Derive __dirname in ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Middleware أساسية
app.use(cors());
// Increase body size limits to allow larger base64 logo uploads from frontend
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));
app.use(cookieParser());

// Serve uploaded files
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/jobs", jobRoutes);
app.use("/api/candidates", candidateRoutes);
app.use("/api/company", companyRoutes);
app.use("/api/analytics", analyticsRoutes);
app.use("/api/notifications", notificationRoutes);
app.use("/api/resumes", resumeRoutes);
app.use("/api/ml", mlRoutes);
app.use("/api/hr", hrRoutes);
app.use("/api/student", studentRoutes);
app.use("/api/chat", chatRoutes);

// In production, serve the React built static files
if (process.env.NODE_ENV === "production") {
  const distPath = path.join(__dirname, "../my-react-app/dist");
  app.use(express.static(distPath));
  // SPA fallback for client-side routing (after API routes, before errors)
  app.get("*", (req, res) => {
    // Prevent overriding API responses
    if (req.path.startsWith("/api"))
      return res.status(404).json({ message: "Not Found" });
    res.sendFile(path.join(distPath, "index.html"));
  });
}

// Home Route
app.get("/", (req, res) => {
  res.json({
    message: "✅ HR Dashboard Backend - Server is running!",
    availableEndpoints: {
      authentication: {
        register: "POST /api/auth/register",
        login: "POST /api/auth/login",
        getProfile: "GET /api/auth/me",
        updateProfile: "PUT /api/auth/me",
        updatePassword: "PATCH /api/auth/me/password",
        deleteAccount: "DELETE /api/auth/me",
      },
      users: {
        getAllUsers: "GET /api/auth/users",
        getUser: "GET /api/auth/users/:id",
        updateUser: "PUT /api/auth/users/:id",
        deleteUser: "DELETE /api/auth/users/:id",
      },
      jobs: {
        getAllJobs: "GET /api/jobs",
        getJob: "GET /api/jobs/:id",
        createJob: "POST /api/jobs",
        updateJob: "PUT /api/jobs/:id",
        deleteJob: "DELETE /api/jobs/:id",
        searchJobs: "GET /api/jobs/search",
        getJobApplicants: "GET /api/jobs/:id/applicants",
      },
      candidates: {
        getAllCandidates: "GET /api/candidates",
        getCandidate: "GET /api/candidates/:id",
        createCandidate: "POST /api/candidates",
        updateCandidate: "PUT /api/candidates/:id",
        deleteCandidate: "DELETE /api/candidates/:id",
        searchCandidates: "GET /api/candidates/search",
        applyForJob: "POST /api/candidates/apply",
        updateApplicationStatus: "PUT /api/candidates/application/status",
        calculateMatch: "POST /api/candidates/match",
      },
      company: {
        getCompany: "GET /api/company",
        createCompany: "POST /api/company",
        updateCompany: "PUT /api/company",
        deleteCompany: "DELETE /api/company",
        getAllCompanies: "GET /api/company/all",
      },
      analytics: {
        getDashboard: "GET /api/analytics/dashboard",
        getHistory: "GET /api/analytics/history",
        saveSnapshot: "POST /api/analytics",
      },
      notifications: {
        getAll: "GET /api/notifications",
        getUnreadCount: "GET /api/notifications/unread-count",
        create: "POST /api/notifications",
        markAsRead: "PUT /api/notifications/:id",
        markAllAsRead: "PUT /api/notifications/mark-all-read",
        delete: "DELETE /api/notifications/:id",
        deleteAll: "DELETE /api/notifications",
      },
    },
  });
});

// Error handlers (must be after all routes)
app.use(notFound);
app.use(errorHandler);

const PORT = process.env.PORT || 5000;
// Use localhost for development (avoids firewall issues)
const HOST = process.env.HOST || "localhost";
const server = app.listen(PORT, HOST, () => {
  console.log(`✅ Server running on ${HOST}:${PORT}`);
  console.log(`✅ Local access: http://localhost:${PORT}`);
  if (HOST === "0.0.0.0") {
    console.log(`✅ Network access: http://192.168.1.7:${PORT}`);
  }
  console.log('💡 Python BERT matcher will start on first job-matches request');
});

// Handle server errors
server.on("error", (error) => {
  console.error("❌ Server error:", error);
  if (error.code === "EADDRINUSE") {
    console.error(`❌ Port ${PORT} is already in use!`);
    process.exit(1);
  }
});

// Increase timeout for ML operations (120 seconds)
server.timeout = 120000;
