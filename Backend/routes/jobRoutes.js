import express from "express";
import multer from "multer";
import path from "path";
import fs from "fs";
import { fileURLToPath } from "url";
import {
  getAllJobs,
  getJob,
  createJob,
  updateJob,
  deleteJob,
  searchJobs,
  getJobApplicants,
  applyToJob,
} from "../controllers/jobController.js";
import { protect } from "../middleware/authMiddleware.js";
import { authorizeRoles } from "../middleware/roleMiddleware.js";
import { jobValidation, validate } from "../middleware/validationMiddleware.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Storage for company logos
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = path.join(__dirname, "../uploads/logos");
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, "logo-" + uniqueSuffix + path.extname(file.originalname));
  },
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith("image/")) {
      cb(null, true);
    } else {
      cb(new Error("Only image files are allowed"));
    }
  },
});

const router = express.Router();

// All routes require authentication
router.use(protect);

// Routes that require HR role for creation, but GET is public for authenticated users
router
  .route("/")
  .get(getAllJobs) // Allow all authenticated users to view jobs
  .post(authorizeRoles("hr"), upload.single("companyLogo"), createJob); // Only HR can create

router.get("/search", authorizeRoles("hr"), searchJobs);

router
  .route("/:id")
  .get(getJob)
  .put(authorizeRoles("hr"), jobValidation, validate, updateJob)
  .delete(authorizeRoles("hr"), deleteJob);

// Apply to a job (employees only)
router.post("/:id/apply", authorizeRoles("employee", "user"), applyToJob);

router.get("/:id/applicants", authorizeRoles("hr"), getJobApplicants);

// Upload company logo (HR only)
router.post("/upload-logo", authorizeRoles("hr"), upload.single("logo"), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "No logo file uploaded",
      });
    }

    const logoUrl = `/uploads/logos/${req.file.filename}`;
    res.json({
      success: true,
      message: "Logo uploaded successfully",
      logoUrl: logoUrl,
    });
  } catch (error) {
    console.error("Logo upload error:", error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

export default router;
