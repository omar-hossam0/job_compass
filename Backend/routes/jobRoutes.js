import express from "express";
import {
  getAllJobs,
  getJob,
  createJob,
  updateJob,
  deleteJob,
  searchJobs,
  getJobApplicants,
} from "../controllers/jobController.js";
import { protect } from "../middleware/authMiddleware.js";
import { authorizeRoles } from "../middleware/roleMiddleware.js";
import { jobValidation, validate } from "../middleware/validationMiddleware.js";

const router = express.Router();

// All routes require authentication
router.use(protect);

// Routes that require HR role
router
  .route("/")
  .get(authorizeRoles("hr"), getAllJobs)
  .post(authorizeRoles("hr"), jobValidation, validate, createJob);

router.get("/search", authorizeRoles("hr"), searchJobs);

router
  .route("/:id")
  .get(getJob)
  .put(authorizeRoles("hr"), jobValidation, validate, updateJob)
  .delete(authorizeRoles("hr"), deleteJob);

router.get("/:id/applicants", authorizeRoles("hr"), getJobApplicants);

export default router;
