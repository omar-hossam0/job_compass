import express from "express";
import {
  getAllCandidates,
  getCandidate,
  createCandidate,
  updateCandidate,
  deleteCandidate,
  searchCandidates,
  applyForJob,
  updateApplicationStatus,
  calculateMatch,
} from "../controllers/candidateController.js";
import { protect } from "../middleware/authMiddleware.js";
import { authorizeRoles } from "../middleware/roleMiddleware.js";
import {
  candidateValidation,
  applicationValidation,
  validate,
} from "../middleware/validationMiddleware.js";

const router = express.Router();

// All routes require authentication
router.use(protect);

router
  .route("/")
  .get(authorizeRoles("hr"), getAllCandidates)
  .post(candidateValidation, validate, createCandidate);

router.get("/search", authorizeRoles("hr"), searchCandidates);

router.post("/apply", applicationValidation, validate, applyForJob);

router.put(
  "/application/status",
  authorizeRoles("hr"),
  updateApplicationStatus
);

router.post("/match", authorizeRoles("hr"), calculateMatch);

router
  .route("/:id")
  .get(getCandidate)
  .put(candidateValidation, validate, updateCandidate)
  .delete(deleteCandidate);

export default router;
