import express from "express";
import {
  getHRDashboard,
  getHRJobs,
  createJob,
  getJobById,
  updateJob,
  closeJob,
  getJobCandidates,
  getCandidateDetails,
  saveCandidate,
  unsaveCandidate,
  getSavedCandidates,
  getHRNotifications,
  getHRProfile,
  updateHRProfile,
} from "../controllers/hrController.js";
import { protect } from "../middleware/authMiddleware.js";
import { authorizeRoles } from "../middleware/roleMiddleware.js";

const router = express.Router();

// Protected routes - HR only
router.use(protect);
router.use(authorizeRoles("hr"));

// Dashboard
router.get("/dashboard", getHRDashboard);

// Jobs
router.get("/jobs", getHRJobs);
router.post("/jobs", createJob);
router.get("/jobs/:id", getJobById);
router.put("/jobs/:id", updateJob);
router.post("/jobs/:id/close", closeJob);

// Candidates
router.get("/jobs/:id/candidates", getJobCandidates);
router.get("/candidates/:id", getCandidateDetails);
router.post("/candidates/:id/save", saveCandidate);
router.delete("/candidates/:id/save", unsaveCandidate);
router.get("/saved-candidates", getSavedCandidates);

// Notifications
router.get("/notifications", getHRNotifications);

// Profile
router.get("/profile", getHRProfile);
router.put("/profile", updateHRProfile);

export default router;
