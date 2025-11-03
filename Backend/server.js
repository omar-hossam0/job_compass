import express from "express";
import cors from "cors";
import cookieParser from "cookie-parser";
import dotenv from "dotenv";
import authRoutes from "./routes/authRoutes.js";
import jobRoutes from "./routes/jobRoutes.js";
import candidateRoutes from "./routes/candidateRoutes.js";
import companyRoutes from "./routes/companyRoutes.js";
import analyticsRoutes from "./routes/analyticsRoutes.js";
import notificationRoutes from "./routes/notificationRoutes.js";
import connectDB from "./config/database.js";
import { errorHandler, notFound } from "./middleware/errorMiddleware.js";

dotenv.config(); // تحميل متغيرات البيئة من ملف .env

// الاتصال بقاعدة البيانات
connectDB();

const app = express();

// Middleware أساسية
app.use(cors());
app.use(express.json());
app.use(cookieParser());

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/jobs", jobRoutes);
app.use("/api/candidates", candidateRoutes);
app.use("/api/company", companyRoutes);
app.use("/api/analytics", analyticsRoutes);
app.use("/api/notifications", notificationRoutes);

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
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
