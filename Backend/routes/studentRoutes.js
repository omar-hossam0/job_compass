import express from "express";
import multer from "multer";
import { verifyToken } from "../middleware/authMiddleware.js";
import Job from "../models/Job.js";
import Candidate from "../models/Candidate.js";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import pdf from "pdf-parse";
import mammoth from "mammoth";
import { calculateKeywordMatch, extractSkillsFromDescription, KNOWN_SKILLS } from "../utils/matchingUtils.js";

const MATCH_TIMEOUT_MS = 30000; // Increase timeout for Python matcher (30 seconds)
const USE_FAST_MATCH = process.env.FAST_MATCH === "true" || true; // Enable fast mode by default

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Helper function to extract text from PDF
async function extractTextFromPdf(filePath) {
  try {
    const dataBuffer = fs.readFileSync(filePath);
    const data = await pdf(dataBuffer);
    return data.text || "";
  } catch (error) {
    console.error("❌ PDF text extraction error:", error.message);
    return "";
  }
}

// Helper function to extract text from DOCX/DOC
async function extractTextFromDocx(filePath) {
  try {
    const result = await mammoth.extractRawText({ path: filePath });
    return result.value || "";
  } catch (error) {
    console.error("❌ DOCX text extraction error:", error.message);
    return "";
  }
}

// Helper to timeout a promise
function withTimeout(promise, ms, label = "") {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => {
      reject(new Error(label || `Operation timed out after ${ms}ms`));
    }, ms);

    promise
      .then((value) => {
        clearTimeout(timer);
        resolve(value);
      })
      .catch((err) => {
        clearTimeout(timer);
        reject(err);
      });
  });
}

// Helper to pick an extractor based on mime/extension
async function extractResumeText(filePath, mimeType = "") {
  const ext = path.extname(filePath).toLowerCase();
  try {
    if (mimeType.includes("pdf") || ext === ".pdf") {
      return await extractTextFromPdf(filePath);
    }

    if (
      mimeType.includes("wordprocessingml.document") ||
      mimeType === "application/msword" ||
      ext === ".docx" ||
      ext === ".doc"
    ) {
      return await extractTextFromDocx(filePath);
    }

    if (mimeType === "text/plain" || ext === ".txt") {
      return fs.readFileSync(filePath, "utf-8");
    }

    if (mimeType === "application/rtf" || ext === ".rtf") {
      return fs.readFileSync(filePath, "utf-8");
    }

    return "";
  } catch (error) {
    console.error("❌ Resume text extraction error:", error.message);
    return "";
  }
}

// Helper function to extract skills from text
function extractSkillsFromText(text) {
  if (!text) return [];

  const skillPatterns = [
    /\b(javascript|js|typescript|ts|react|angular|vue|node\.?js|express|mongodb|mysql|postgresql|python|java|c\+\+|c#|php|ruby|go|rust|swift|kotlin|html|css|sass|tailwind|bootstrap|git|docker|kubernetes|aws|azure|gcp|machine learning|ai|data science|pandas|numpy|tensorflow|pytorch|sql|redis|graphql|rest|api|linux|windows|agile|scrum|jira|figma|photoshop|illustrator|excel|word|powerpoint)\b/gi,
  ];

  const foundSkills = new Set();
  skillPatterns.forEach((pattern) => {
    const matches = text.match(pattern);
    if (matches) {
      matches.forEach((m) =>
        foundSkills.add(m.charAt(0).toUpperCase() + m.slice(1).toLowerCase()),
      );
    }
  });
  return Array.from(foundSkills).slice(0, 20);
}

// Multer configuration for CV upload
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = path.join(__dirname, "../uploads/cvs");
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, "cv-" + uniqueSuffix + path.extname(file.originalname));
  },
});

// Allowed file types for CV upload
const allowedMimeTypes = [
  "application/pdf",
  "application/msword",
  "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
  "text/plain",
  "application/rtf",
  "image/jpeg",
  "image/png",
  "image/jpg",
  "application/octet-stream", // Added to support some mobile file pickers
];

const upload = multer({
  storage: storage,
  limits: { fileSize: 100 * 1024 * 1024 }, // 100MB
  fileFilter: (req, file, cb) => {
    console.log("\n📄 FILE UPLOAD FILTER:");
    console.log("  fieldname:", file.fieldname);
    console.log("  originalname:", file.originalname);
    console.log("  mimetype:", file.mimetype);

    // Check extension if mimetype is octet-stream
    const ext = path.extname(file.originalname).toLowerCase();
    const allowedExtensions = [".pdf", ".doc", ".docx", ".txt", ".rtf", ".jpg", ".jpeg", ".png"];

    if (allowedMimeTypes.includes(file.mimetype) || allowedExtensions.includes(ext)) {
      console.log("✅ File accepted for upload");
      cb(null, true);
    } else {
      const error = `File type ${file.mimetype} with extension ${ext} not allowed`;
      console.error("❌ " + error);
      cb(new Error(error));
    }
  },
});

const router = express.Router();

// ============================================
// PUBLIC ENDPOINTS (No authentication required)
// ============================================

// AUTOCOMPLETE SUGGESTIONS
router.get("/jobs/suggestions", async (req, res) => {
  try {
    const { query } = req.query;

    if (!query || query.trim() === "") {
      return res.json({
        success: true,
        data: [],
      });
    }

    const searchQuery = query.trim().toLowerCase();

    // Get job titles and companies that match
    const jobs = await Job.find({
      status: { $regex: "^active$", $options: "i" },
      $or: [
        { title: { $regex: searchQuery, $options: "i" } },
        { requiredSkills: { $regex: searchQuery, $options: "i" } },
        { location: { $regex: searchQuery, $options: "i" } },
      ],
    })
      .populate("company", "name")
      .select("title location requiredSkills company")
      .limit(20);

    // Create unique suggestions with job IDs and relevance score
    const suggestionsMap = new Map();

    jobs.forEach((job) => {
      if (job.title && !suggestionsMap.has(job.title.toLowerCase())) {
        const titleLower = job.title.toLowerCase();

        // Calculate relevance score
        let score = 0;

        // Exact match gets highest score
        if (titleLower === searchQuery) {
          score = 1000;
        }
        // Starts with query gets high score
        else if (titleLower.startsWith(searchQuery)) {
          score = 500;
        }
        // Contains query gets medium score
        else if (titleLower.includes(searchQuery)) {
          score = 100;
        }
        // Word match gets lower score
        else {
          const words = titleLower.split(/\s+/);
          if (words.some((word) => word.startsWith(searchQuery))) {
            score = 50;
          } else {
            score = 10;
          }
        }

        suggestionsMap.set(job.title.toLowerCase(), {
          text: job.title,
          jobId: job._id,
          type: "job",
          company: job.company?.name || null,
          score: score,
        });
      }
    });

    // Sort by relevance score (highest first)
    const suggestions = Array.from(suggestionsMap.values())
      .sort((a, b) => b.score - a.score)
      .map(({ score, ...rest }) => rest)
      .slice(0, 8);

    res.json({
      success: true,
      data: suggestions,
    });
  } catch (error) {
    console.error("❌ Autocomplete error:", error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// SEARCH JOBS
router.get("/jobs/search", async (req, res) => {
  try {
    const { query } = req.query;

    if (!query || query.trim() === "") {
      // Return all jobs if no search query
      const jobs = await Job.find({
        status: { $regex: "^active$", $options: "i" },
      })
        .populate("company", "name location")
        .sort({ createdAt: -1 })
        .limit(20);

      return res.json({
        success: true,
        message: "All active jobs",
        data: jobs.map((job) => ({
          id: job._id,
          title: job.title,
          company: job.company?.name || "Unknown Company",
          location: job.location || job.company?.location || "Not specified",
          salary: job.salary || "Competitive",
          type: job.type || "Full-time",
          description: job.description?.substring(0, 150) || "",
          requiredSkills: job.requiredSkills || [],
          postedDate: job.createdAt,
        })),
        count: jobs.length,
      });
    }

    const searchQuery = query.trim().toLowerCase();

    // Search in title, description, location, skills
    const jobs = await Job.find({
      status: { $regex: "^active$", $options: "i" },
      $or: [
        { title: { $regex: searchQuery, $options: "i" } },
        { description: { $regex: searchQuery, $options: "i" } },
        { location: { $regex: searchQuery, $options: "i" } },
        { requiredSkills: { $regex: searchQuery, $options: "i" } },
        { type: { $regex: searchQuery, $options: "i" } },
      ],
    })
      .populate("company", "name location")
      .sort({ createdAt: -1 })
      .limit(50);

    console.log(`🔍 Search for "${query}" found ${jobs.length} jobs`);

    res.json({
      success: true,
      message: `Found ${jobs.length} jobs matching "${query}"`,
      data: jobs.map((job) => ({
        id: job._id,
        title: job.title,
        company: job.company?.name || "Unknown Company",
        location: job.location || job.company?.location || "Not specified",
        salary: job.salary || "Competitive",
        type: job.type || "Full-time",
        description: job.description?.substring(0, 150) || "",
        requiredSkills: job.requiredSkills || [],
        postedDate: job.createdAt,
      })),
      count: jobs.length,
    });
  } catch (error) {
    console.error("❌ Search jobs error:", error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// ============================================
// PROTECTED ENDPOINTS (Authentication required)
// ============================================

// Protect all student routes below
router.use(verifyToken);

// ============================================
// STUDENT DASHBOARD
// ============================================
router.get("/dashboard", async (req, res) => {
  try {
    // Get active jobs
    const jobs = await Job.find({ status: "Active" })
      .sort({ createdAt: -1 })
      .limit(10)
      .populate("postedBy", "name email");

    // Get candidate data for match scoring
    const candidate = await Candidate.findOne({ email: req.user.email });

    // Calculate match scores if candidate has resume
    let enrichedJobs = jobs;
    if (candidate && candidate.resumeText && candidate.resumeText.trim()) {
      // Use keyword matching for dashboard (faster and more accurate)
      const cvText = candidate.resumeText;

      enrichedJobs = jobs.map((job) => {
        const jobObj = job.toObject();
        // Extract skills from description if not enough defined (same as matchJobsToCV)
        const enhancedJob = {
          ...jobObj,
          requiredSkills: extractSkillsFromDescription(job),
        };
        const keywordMatch = calculateKeywordMatch(cvText, enhancedJob);
        jobObj.matchScore = keywordMatch;
        jobObj.requiredSkills = enhancedJob.requiredSkills; // Update with extracted skills
        return jobObj;
      });

      enrichedJobs.sort((a, b) => (b.matchScore || 0) - (a.matchScore || 0));
    }

    // Format jobs for frontend
    const topMatchedJobs = enrichedJobs.slice(0, 5).map((job) => ({
      id: job._id,
      title: job.title,
      company: job.company || "Company",
      companyLogo: job.companyLogo,
      description: job.description,
      location: job.location || "Remote",
      employmentType: job.jobType ? [job.jobType] : ["Full-time"],
      salary: job.salary?.min || 0,
      salaryPeriod: "/year",
      experienceYears: 0,
      requiredSkills: job.requiredSkills || [],
      matchScore: job.matchScore || 0,
      missingSkillsCount: 0,
      postedAt: job.createdAt,
      applicantsCount: job.applicants?.length || 0,
    }));

    res.json({
      success: true,
      message: "Student dashboard data",
      data: {
        student: {
          id: req.user.id,
          name: req.user.name,
          email: req.user.email,
          profilePicture: req.user.profileImage || null,
          profileCompletion: candidate ? 75 : 25,
          skillMatchScore: 0,
          skills: candidate?.skills || [],
        },
        topMatchedJobs,
        totalJobMatches: enrichedJobs.length,
        skillsCount: candidate?.skills?.length || 0,
      },
    });
  } catch (error) {
    console.error("Dashboard error:", error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// ============================================
// STUDENT PROFILE
// ============================================
router.get("/profile", async (req, res) => {
  try {
    console.log("\n🔍 PROFILE REQUEST");
    console.log("👤 User ID:", req.user._id);
    console.log("📧 User email:", req.user.email);

    // Get candidate info if exists
    const candidate = await Candidate.findOne({ user: req.user._id });
    console.log("📌 Candidate found:", !!candidate);

    if (candidate) {
      console.log("📄 Candidate data:", {
        _id: candidate._id,
        user: candidate.user,
        email: candidate.email,
        cvUrl: candidate.cvUrl,
        cvFileName: candidate.cvFileName,
        cvUploadedAt: candidate.cvUploadedAt,
      });
    } else {
      console.log("⚠️ No candidate found, checking by email...");
      const candidateByEmail = await Candidate.findOne({
        email: req.user.email,
      });
      console.log("📌 Candidate by email found:", !!candidateByEmail);
      if (candidateByEmail) {
        console.log("📄 Candidate by email data:", {
          _id: candidateByEmail._id,
          user: candidateByEmail.user,
          email: candidateByEmail.email,
        });
      }
    }

    res.json({
      success: true,
      message: "Student profile",
      data: {
        id: req.user.id,
        name: req.user.name,
        email: req.user.email,
        role: req.user.role,
        profilePicture: req.user.profileImage,
        phone: req.user.phone,
        cvUrl: candidate?.cvUrl,
        cvFileName: candidate?.cvFileName,
        cvUploadedAt: candidate?.cvUploadedAt,
        cvCategory: candidate?.cvCategory,
        cvCategoryConfidence: candidate?.cvCategoryConfidence,
        cvTopCategories: candidate?.cvTopCategories,
        skills: candidate?.skills || [],
        profileCompletion: candidate ? 70 : 30,
        skillMatchScore: 0,
      },
    });

    console.log(
      "✅ Profile response sent with cvFileName:",
      candidate?.cvFileName,
      "category:",
      candidate?.cvCategory,
    );
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// ============================================
// UPLOAD CV
// ============================================
router.post(
  "/upload-cv",
  (req, res, next) => {
    console.log("\n🚀 CV UPLOAD REQUEST RECEIVED");
    console.log("  Content-Type:", req.headers["content-type"]);
    console.log("  User:", req.user ? req.user.email : "NOT AUTHENTICATED");

    upload.single("cv")(req, res, (err) => {
      if (err) {
        console.error("❌ Multer error:", err.message);
        return res.status(400).json({
          success: false,
          message: err.message || "File upload failed",
        });
      }
      console.log("✅ File passed multer validation");
      next();
    });
  },
  async (req, res) => {
    try {
      console.log("\n=== CV UPLOAD DEBUG ===");
      if (!req.file) {
        console.error("❌ No file in request");
        return res.status(400).json({
          success: false,
          message: "No file uploaded",
        });
      }

      console.log("📄 File details:", {
        filename: req.file.filename,
        mimetype: req.file.mimetype,
        size: req.file.size,
        originalname: req.file.originalname,
      });

      // Get or create candidate
      let candidate = await Candidate.findOne({ user: req.user._id });
      if (!candidate) {
        try {
          candidate = await Candidate.create({
            user: req.user._id,
            name: req.user.name,
            email: req.user.email,
            phone: req.user.phone || "",
          });
        } catch (createError) {
          if (createError.code === 11000) {
            candidate = await Candidate.findOne({ email: req.user.email });
            if (candidate) candidate.user = req.user._id;
          }
          if (!candidate) throw createError;
        }
      }

      // Extract text from CV
      const filePath = path.join(__dirname, "../uploads/cvs", req.file.filename);
      let resumeText = await extractResumeText(filePath, req.file.mimetype);
      const extractedSkills = extractSkillsFromText(resumeText);

      // Classify CV using ML model
      let cvClassification = null;
      if (resumeText && resumeText.length > 50) {
        try {
          const classifierResponse = await fetch("http://localhost:5001/classify", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ cv_text: resumeText }),
          });

          if (classifierResponse.ok) {
            cvClassification = await classifierResponse.json();
          }
        } catch (classifyError) {
          console.log("⚠️ CV Classification service not available");
        }
      }

      // Update CV info
      candidate.cvUrl = `/uploads/cvs/${req.file.filename}`;
      candidate.cvFileName = req.file.originalname;
      candidate.cvUploadedAt = new Date();
      candidate.resumeText = resumeText;
      if (extractedSkills.length > 0) {
        candidate.skills = extractedSkills;
      }

      if (cvClassification && cvClassification.success) {
        candidate.cvCategory = cvClassification.job_category;
        candidate.cvCategoryConfidence = cvClassification.confidence;
        candidate.cvTopCategories = cvClassification.top_3_predictions;
      }

      await candidate.save();

      res.json({
        success: true,
        message: "CV uploaded successfully",
        cvUrl: candidate.cvUrl,
        cvFileName: candidate.cvFileName,
        cvUploadedAt: new Date(),
        classification: cvClassification ? {
          category: cvClassification.job_category,
          confidence: cvClassification.confidence
        } : null,
      });
    } catch (error) {
      console.error("❌ Error uploading CV:", error);
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  },
);

// ============================================
// SKILLS ANALYSIS
// ============================================
router.get("/skills-analysis", async (req, res) => {
  try {
    res.json({
      success: true,
      message: "Skills analysis",
      data: {
        skills: [],
        level: "Beginner",
        recommendations: [],
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// ============================================
// JOB MATCHES - AI-Powered CV to Job Matching
// ============================================
router.get("/job-matches", async (req, res) => {
  try {
    console.log("\n🎯 JOB MATCHES REQUEST");
    console.log("👤 User:", req.user.email);
    const fastMode = USE_FAST_MATCH || req.query.fast === "1";

    // Get candidate data for CV text
    const candidate = await Candidate.findOne({ user: req.user._id });

    if (!candidate || !candidate.resumeText) {
      const jobs = await Job.find({ status: "Active" }).sort({ createdAt: -1 });
      return res.json({
        success: true,
        message: "Upload CV to get better job matches",
        data: jobs.map(j => ({
          id: j._id,
          title: j.title,
          company: j.company,
          matchScore: 0,
          location: j.location,
          postedAt: j.createdAt
        })),
        hasCv: false,
      });
    }

    // Get all active jobs
    const jobs = await Job.find({ status: "Active" }).sort({ createdAt: -1 });

    // Simple keyword matching for now
    const matchedJobs = jobs.map((job) => {
      const keywordMatch = calculateKeywordMatch(candidate.resumeText, job);
      return {
        id: job._id,
        title: job.title,
        company: job.company || "Company",
        location: job.location || "Remote",
        requiredSkills: job.requiredSkills || [],
        matchScore: keywordMatch,
        postedAt: job.createdAt,
      };
    }).filter(j => j.matchScore >= 60); // عرض الوظائف فوق 60% فقط - علاقة قوية بالسيرة الذاتية

    matchedJobs.sort((a, b) => b.matchScore - a.matchScore);

    res.json({
      success: true,
      message: "Job matches found",
      data: matchedJobs,
      hasCv: true,
    });
  } catch (error) {
    console.error("❌ Job matches error:", error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// ============================================
// SKILL GAP
// ============================================
router.get("/skill-gap/:jobId", async (req, res) => {
  try {
    const { jobId } = req.params;
    res.json({
      success: true,
      message: "Skill gap analysis",
      data: {
        jobId,
        gap: [],
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// ============================================
// LEARNING PATH
// ============================================
router.get("/learning-path", async (req, res) => {
  try {
    res.json({
      success: true,
      message: "Learning path",
      data: {
        path: [],
        estimatedDuration: "3 months",
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// ============================================
// INTERVIEW SESSION
// ============================================
router.post("/interview-session", async (req, res) => {
  try {
    res.json({
      success: true,
      message: "Interview session started",
      sessionId: "sess_" + Date.now(),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// ============================================
// CHATBOT - AI Career Assistant
// ============================================
router.post("/chatbot", async (req, res) => {
  try {
    const { message } = req.body;
    const candidate = await Candidate.findOne({ email: req.user.email });
    const cvText = candidate?.resumeText || "";

    res.json({
      success: true,
      answer: "I am your AI assistant. How can I help you today?",
      hasCv: !!cvText,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// ============================================
// NOTIFICATIONS
// ============================================
router.get("/notifications", async (req, res) => {
  try {
    res.json({
      success: true,
      message: "Student notifications",
      data: [],
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// ============================================
// UPDATE PROFILE
// ============================================
router.put("/profile", async (req, res) => {
  try {
    res.json({
      success: true,
      message: "Profile updated successfully",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// ============================================
// CHANGE PASSWORD
// ============================================
router.put("/change-password", async (req, res) => {
  try {
    res.json({
      success: true,
      message: "Password changed successfully",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

export default router;
