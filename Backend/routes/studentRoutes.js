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

const MATCH_TIMEOUT_MS = 30000; // Increase timeout for Python matcher (30 seconds)
const USE_FAST_MATCH = process.env.FAST_MATCH === "true" || true; // Enable fast mode by default

// Helper: Calculate keyword match percentage using Hybrid Weighted Scoring
// Same scoring system as Find CV / employ system
const calculateKeywordMatch = (cvText, job) => {
  const cvLower = (cvText || "").toLowerCase();
  const skills = (job.requiredSkills || []).map((s) => (s || "").toLowerCase());

  let exactMatches = 0;
  const matchedSkills = [];
  const missingSkills = [];

  skills.forEach((skill) => {
    // Normalize and create all possible variants for the same skill
    const skillVariants = new Set();

    // Add original skill
    skillVariants.add(skill);

    // Handle .js framework names (node.js, express.js, react.js, etc.)
    if (skill.includes('.js')) {
      const base = skill.replace(/\.js$/i, '');
      skillVariants.add(base);                    // node.js -> node
      skillVariants.add(base + 'js');             // node.js -> nodejs
      skillVariants.add(base + ' js');            // node.js -> node js
    } else if (skill.match(/js$/i) && skill.length > 2) {
      const base = skill.replace(/js$/i, '');
      skillVariants.add(base + '.js');            // nodejs -> node.js
      skillVariants.add(base);                    // nodejs -> node
    }

    // Handle slash-separated skills (MongoDB/MySQL -> match if CV has MongoDB OR MySQL)
    if (skill.includes('/')) {
      const parts = skill.split('/');
      parts.forEach(part => skillVariants.add(part.trim()));
    }

    // Handle space-separated ONLY for known technical terms and compound phrases
    const isCompoundTechnicalSkill =
      skill.includes('api') ||              // REST API, REST APIs
      skill.includes('tcp') ||              // TCP/IP
      skill.includes('lan') ||              // LAN/WAN
      skill.includes('ci/cd') ||            // CI/CD
      skill.includes('html') ||             // HTML, HTML5
      skill.includes('css');                // CSS, CSS3

    if (skill.includes(' ') && isCompoundTechnicalSkill) {
      skill.split(' ').forEach(word => {
        if (word.length >= 2) skillVariants.add(word);
      });
      skillVariants.add(skill.replace(/\s+/g, ''));
    }

    // Check if CV contains any variant
    const found = Array.from(skillVariants).some(variant => {
      if (!variant || variant.length < 2) return false;

      const escaped = variant.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

      try {
        const exactRegex = new RegExp(`\\b${escaped}\\b`, 'i');
        if (exactRegex.test(cvLower)) return true;
      } catch (e) {
        if (cvLower.includes(variant)) return true;
      }

      if (variant.length <= 3) {
        return cvLower.includes(variant);
      }

      return false;
    });

    if (found) {
      exactMatches++;
      matchedSkills.push(skill);
    } else {
      missingSkills.push(skill);
    }
  });

  const totalSkills = skills.length;
  if (totalSkills === 0) return 0;

  // HYBRID WEIGHTED SCORING - Same as Find CV / employ system:
  // Final Score = (BERT Score × 0.5) + (Keyword Boost)
  // BERT Score = fixed at 55 for consistency across all systems
  // Keyword Boost = matched_skills × 10 points each
  const bertBaseScore = 55; // Fixed BERT score (same as Python matcher)
  const keywordBoost = exactMatches * 10;
  const hybridScore = (bertBaseScore * 0.5) + keywordBoost;
  const matchScore = Math.min(Math.round(hybridScore), 100);

  console.log(`📊 "${job.title}": ${exactMatches}/${totalSkills} skills → BERT=${bertBaseScore.toFixed(1)} Boost=${keywordBoost} Final=${matchScore}%`);
  if (matchedSkills.length > 0) console.log(`   ✓ Matched: ${matchedSkills.join(', ')}`);
  if (missingSkills.length > 0) console.log(`   ✗ Missing: ${missingSkills.join(', ')}`);

  return matchScore;
};

// Common tech skills to extract from job descriptions
const KNOWN_SKILLS = [
  // Programming Languages
  'javascript', 'python', 'java', 'c#', 'c++', 'php', 'ruby', 'go', 'rust', 'swift', 'kotlin', 'typescript',
  // Frontend
  'react', 'react.js', 'reactjs', 'angular', 'vue', 'vue.js', 'vuejs', 'html', 'css', 'sass', 'less', 'bootstrap', 'tailwind',
  // Backend
  'node', 'node.js', 'nodejs', 'express', 'express.js', 'expressjs', 'django', 'flask', 'spring', 'laravel', 'rails',
  // Databases
  'mongodb', 'mysql', 'postgresql', 'postgres', 'sql', 'redis', 'firebase', 'dynamodb', 'oracle', 'sqlite',
  // DevOps & Cloud
  'docker', 'kubernetes', 'aws', 'azure', 'gcp', 'jenkins', 'ci/cd', 'linux', 'git', 'github', 'gitlab',
  // APIs
  'rest', 'restful', 'graphql', 'api', 'apis', 'websocket', 'socket.io',
  // Other
  'jwt', 'oauth', 'authentication', 'authorization', 'security', 'testing', 'agile', 'scrum'
];

// Extract skills from job description if requiredSkills is empty or too few
const extractSkillsFromDescription = (job) => {
  const requiredSkills = job.requiredSkills || [];

  // Always extract from description and merge with required skills
  // This ensures consistency with Python matcher
  const description = (job.description || '').toLowerCase();
  const title = (job.title || '').toLowerCase();
  const combinedText = `${title} ${description}`;

  const extractedSkills = [];

  KNOWN_SKILLS.forEach(skill => {
    const escaped = skill.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    const regex = new RegExp(`\\b${escaped}\\b`, 'i');
    if (regex.test(combinedText)) {
      // Keep lowercase for consistency with Python matcher
      if (!extractedSkills.includes(skill)) {
        extractedSkills.push(skill);
      }
    }
  });

  // Merge with existing skills (if any)
  const allSkills = [...requiredSkills.map(s => s.toLowerCase())];
  extractedSkills.forEach(skill => {
    const skillLower = skill.toLowerCase();
    const exists = allSkills.some(s => s.toLowerCase() === skillLower);
    if (!exists) {
      allSkills.push(skill);
    }
  });

  if (extractedSkills.length > 0) {
    console.log(`🔍 Auto-extracted ${extractedSkills.length} skills for "${job.title}": ${extractedSkills.slice(0,10).join(', ')}${extractedSkills.length > 10 ? '...' : ''}`);
  }
  
  console.log(`📋 Total skills for matching "${job.title}": ${allSkills.length}`);

  return allSkills;
};

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
        foundSkills.add(m.charAt(0).toUpperCase() + m.slice(1).toLowerCase())
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
];

const upload = multer({
  storage: storage,
  limits: { fileSize: 100 * 1024 * 1024 }, // 100MB
  fileFilter: (req, file, cb) => {
    console.log("\n📄 FILE UPLOAD FILTER:");
    console.log("  fieldname:", file.fieldname);
    console.log("  originalname:", file.originalname);
    console.log("  mimetype:", file.mimetype);
    console.log("  size:", file.size);
    console.log("  allowed types:", allowedMimeTypes);

    if (allowedMimeTypes.includes(file.mimetype)) {
      console.log("✅ File accepted for upload");
      cb(null, true);
    } else {
      const error = `File type ${file.mimetype} not allowed`;
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
          requiredSkills: extractSkillsFromDescription(job)
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
      candidate?.cvCategory
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
        console.error("❌ Error code:", err.code);
        console.error("❌ Req headers:", req.headers);
        return res.status(400).json({
          success: false,
          message: err.message || "File upload failed",
          code: err.code,
        });
      }
      console.log("✅ File passed multer validation");
      next();
    });
  },
  async (req, res) => {
    try {
      console.log("\n=== CV UPLOAD DEBUG ===");
      console.log("📦 req.file exists:", !!req.file);
      console.log("👤 req.user:", req.user ? req.user.email : "NO USER");
      console.log("📝 req.headers:", req.headers);

      if (!req.file) {
        console.error("\u274c No file in request");
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
      console.log("🔍 Looking for candidate with user:", req.user._id);
      console.log("📌 Candidate found:", !!candidate);

      if (!candidate) {
        console.log("📝 Creating new candidate for user:", req.user._id);
        console.log("📝 User details:", {
          name: req.user.name,
          email: req.user.email,
          phone: req.user.phone,
        });
        try {
          candidate = await Candidate.create({
            user: req.user._id,
            name: req.user.name,
            email: req.user.email,
            phone: req.user.phone || "",
          });
          console.log("✅ New candidate created:", candidate._id);
        } catch (createError) {
          console.error("❌ Error creating candidate:", createError.message);
          console.error("❌ Error code:", createError.code);
          console.error("❌ Full error:", createError);
          // If duplicate email, try to find by email
          if (createError.code === 11000) {
            console.log("⚠️ Duplicate key error - searching by email");
            candidate = await Candidate.findOne({ email: req.user.email });
            if (candidate) {
              console.log(
                "📌 Found existing candidate by email, updating user reference"
              );
              candidate.user = req.user._id;
            } else {
              console.log("❌ Could not find candidate by email either!");
            }
          }
          if (!candidate) {
            throw createError;
          }
        }
      } else {
        console.log("📌 Using existing candidate:", candidate._id);
      }

      console.log("📄 About to update CV info");

      // Extract text from PDF for AI matching
      const filePath = path.join(
        __dirname,
        "../uploads/cvs",
        req.file.filename
      );
      let resumeText = await extractResumeText(filePath, req.file.mimetype);
      if (!resumeText.trim()) {
        console.log(
          "⚠️ No text extracted from CV (mimetype:",
          req.file.mimetype,
          ")"
        );
      } else {
        console.log("📝 Extracted text length:", resumeText.length, "chars");
      }

      const extractedSkills = extractSkillsFromText(resumeText);
      if (extractedSkills.length > 0) {
        console.log("🔧 Extracted skills:", extractedSkills);
      }

      // Classify CV using ML model
      let cvClassification = null;
      if (resumeText && resumeText.length > 50) {
        try {
          console.log("🤖 Calling CV Classification service...");
          const classifierResponse = await fetch("http://localhost:5001/classify", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ cv_text: resumeText }),
          });

          if (classifierResponse.ok) {
            cvClassification = await classifierResponse.json();
            console.log("✅ CV Classification result:", cvClassification);
          } else {
            console.log("⚠️ CV Classification service returned error:", classifierResponse.status);
          }
        } catch (classifyError) {
          console.log("⚠️ CV Classification service not available:", classifyError.message);
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

      // Save classification result
      if (cvClassification && cvClassification.success) {
        candidate.cvCategory = cvClassification.job_category;
        candidate.cvCategoryConfidence = cvClassification.confidence;
        candidate.cvTopCategories = cvClassification.top_3_predictions;
      }

      console.log("💾 Saving candidate with CV info and text...");
      await candidate.save();

      console.log("✅ Candidate CV updated:", {
        cvUrl: candidate.cvUrl,
        cvFileName: candidate.cvFileName,
        candidateId: candidate._id,
        resumeTextLength: resumeText.length,
        skillsCount: extractedSkills.length,
        cvCategory: candidate.cvCategory || "Not classified",
      });

      res.json({
        success: true,
        message: "CV uploaded successfully",
        cvUrl: `/uploads/cvs/${req.file.filename}`,
        cvFileName: req.file.originalname,
        cvUploadedAt: new Date(),
        textExtracted: resumeText.length > 0,
        skillsExtracted: extractedSkills.length,
        classification: cvClassification ? {
          category: cvClassification.job_category,
          confidence: cvClassification.confidence,
          top_3: cvClassification.top_3_predictions
        } : null,
      });
    } catch (error) {
      console.error("❌ Error uploading CV:", error);
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }
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
    if (fastMode) {
      console.log("⚡ Fast match mode enabled (keyword-only)");
    }

    // Get candidate data for CV text
    const candidate = await Candidate.findOne({ user: req.user._id });

    if (!candidate) {
      console.log("⚠️ No candidate profile found - returning all jobs with 0% match");
      // إرجاع كل الوظائف النشطة مع match score = 0
      const jobs = await Job.find({ status: "Active" })
        .sort({ createdAt: -1 })
        .populate("postedBy", "name email");

      const jobsWithZeroMatch = jobs.map((job) => ({
        id: job._id,
        title: job.title,
        company: job.company || "Company",
        companyLogo: job.companyLogo,
        description: job.description,
        location: job.location || "Remote",
        employmentType: job.jobType ? [job.jobType] : ["Full-time"],
        salary: job.salary?.min || 0,
        salaryPeriod: "/year",
        experienceYears: job.experienceRequired || 0,
        requiredSkills: job.requiredSkills || [],
        matchScore: 0,
        missingSkillsCount: 0,
        postedAt: job.createdAt,
        applicantsCount: job.applicants?.length || 0,
        customQuestions: job.customQuestions || [],
      }));

      return res.json({
        success: true,
        message: "Upload CV to get better job matches",
        data: jobsWithZeroMatch,
        hasCv: false,
      });
    }

    if (!candidate.resumeText || !candidate.resumeText.trim()) {
      // Try to rehydrate resume text from stored CV file if available
      if (candidate.cvUrl) {
        const storedPath = path.join(
          __dirname,
          "..",
          candidate.cvUrl.replace(/^\//, "")
        );

        if (fs.existsSync(storedPath)) {
          console.log("🔄 No resumeText found, re-extracting from", storedPath);
          const refreshedText = await extractResumeText(storedPath);
          if (refreshedText && refreshedText.trim()) {
            candidate.resumeText = refreshedText;
            await candidate.save();
            console.log(
              "✅ Resume text rehydrated (",
              refreshedText.length,
              "chars )"
            );
          } else {
            console.log("⚠️ Re-extraction produced no text");
          }
        } else {
          console.log("⚠️ Stored CV file not found at", storedPath);
        }
      }

      if (!candidate.resumeText || !candidate.resumeText.trim()) {
        console.log("⚠️ No CV text available - returning all jobs with 0% match");
        // إرجاع كل الوظائف النشطة مع match score = 0
        const jobs = await Job.find({ status: "Active" })
          .sort({ createdAt: -1 })
          .populate("postedBy", "name email");

        const jobsWithZeroMatch = jobs.map((job) => ({
          id: job._id,
          title: job.title,
          company: job.company || "Company",
          companyLogo: job.companyLogo,
          description: job.description,
          location: job.location || "Remote",
          employmentType: job.jobType ? [job.jobType] : ["Full-time"],
          salary: job.salary?.min || 0,
          salaryPeriod: "/year",
          experienceYears: job.experienceRequired || 0,
          requiredSkills: job.requiredSkills || [],
          matchScore: 0,
          missingSkillsCount: 0,
          postedAt: job.createdAt,
          applicantsCount: job.applicants?.length || 0,
          customQuestions: job.customQuestions || [],
        }));

        return res.json({
          success: true,
          message: "Upload a CV to get job matches",
          data: jobsWithZeroMatch,
          hasCv: Boolean(candidate.cvUrl),
        });
      }
    }

    console.log("📄 CV text length:", candidate.resumeText.length);

    // Get all active jobs
    const jobs = await Job.find({ status: "Active" })
      .sort({ createdAt: -1 })
      .populate("postedBy", "name email");

    if (jobs.length === 0) {
      console.log("⚠️ No active jobs found");
      return res.json({
        success: true,
        message: "No jobs available",
        data: [],
        hasCv: true,
      });
    }

    console.log("📊 Found", jobs.length, "active jobs");

    // Use Python BERT matcher for AI matching (unless fast mode is enabled)
    let matchedJobs = [];

    // Fast path: keyword-only, no Python, immediate
    if (fastMode) {
      const cvText = candidate.resumeText;
      matchedJobs = jobs.map((job) => {
        // Extract skills from description if not enough defined
        const enhancedJob = {
          ...job.toObject ? job.toObject() : job,
          requiredSkills: extractSkillsFromDescription(job)
        };

        const keywordMatch = calculateKeywordMatch(cvText, enhancedJob);
        return {
          id: job._id,
          title: job.title,
          company: job.company || "Company",
          companyLogo: job.companyLogo,
          description: job.description,
          location: job.location || "Remote",
          employmentType: job.jobType ? [job.jobType] : ["Full-time"],
          salary: job.salary?.min || 0,
          salaryPeriod: "/year",
          experienceYears: job.experienceRequired || 0,
          requiredSkills: enhancedJob.requiredSkills,
          matchScore: keywordMatch, // Direct score, no rounding
          missingSkillsCount: 0,
          postedAt: job.createdAt,
          applicantsCount: job.applicants?.length || 0,
          customQuestions: job.customQuestions || [],
        };
      });

      // Filter: عرض الوظائف التي لديها match score >= 60% فقط
      const beforeFilter = matchedJobs.length;
      matchedJobs = matchedJobs.filter((job) => job.matchScore >= 60);
      const afterFilter = matchedJobs.length;

      matchedJobs.sort((a, b) => b.matchScore - a.matchScore);
      console.log(
        `✅ Matching complete: ${beforeFilter} total jobs, ${afterFilter} jobs with ≥60% match`
      );
    } else {
      try {
        const { getPythonMatcher } = await import("../utils/pythonMatcher.js");
        const pythonMatcher = getPythonMatcher();

        // Start service if not running
        if (!pythonMatcher.isReady) {
          console.log("🚀 Starting Python matcher service...");
          await pythonMatcher.start();
        }

        const cvText = candidate.resumeText;
        // Build rich job descriptions - emphasize content over title
        const jobDescriptions = jobs.map((job) => {
          const title = job.title || "";
          const desc = job.description || "";
          const skills = (job.requiredSkills || []).join(", ");
          const location = job.location || "";
          const level = job.experienceLevel || "";

          // If description is short, boost it by repeating key info
          // This prevents short-title jobs from dominating
          if (desc.length < 100) {
            return `${title}. Required: ${skills}. Experience: ${level}. Location: ${location}.`;
          }

          // For full jobs, emphasize description content
          return `Job position: ${title}. ${desc} Required skills and qualifications: ${skills}. Experience level: ${level}. Work location: ${location}.`;
        });

        console.log("🔍 Running BERT matching (with timeout)...");
        console.log("📝 Sample job descriptions:");
        jobDescriptions.slice(0, 2).forEach((desc, i) => {
          console.log(`   [${i}] ${desc.substring(0, 80)}...`);
        });

        const matches = await withTimeout(
          pythonMatcher.match(cvText, jobDescriptions, jobs.length),
          MATCH_TIMEOUT_MS,
          "Python matcher timed out"
        );
        console.log("✅ Matching complete, got", matches.length, "results");

        // Map matches to jobs with quality-adjusted scores
        matchedJobs = jobs.map((job, idx) => {
          const matchData = matches.find((m) => m.job_index === idx);
          let bertScore = matchData
            ? Math.round(matchData.similarity_score)
            : 0;

          // Calculate keyword match (actual skills)
          const keywordMatch = calculateKeywordMatch(cvText, job);

          // Use keyword match as the primary score (skills are most important)
          let matchScore = keywordMatch;

          // Apply quality penalty for jobs with insufficient content
          const titleLength = (job.title || "").length;
          const descLength = (job.description || "").length;
          const hasSkills = (job.requiredSkills || []).length > 0;

          // Jobs with very short descriptions get penalized
          if (descLength < 100 || titleLength < 15 || !hasSkills) {
            const contentPenalty = Math.min(
              20,
              (100 - descLength) / 8 +
              (15 - titleLength) * 1.5 +
              (hasSkills ? 0 : 5)
            );
            matchScore = Math.max(0, matchScore - contentPenalty);
            if (contentPenalty > 8) {
              console.log(
                `   ⚠️ "${job.title}": Keywords=${Math.round(
                  keywordMatch
                )}% BERT=${bertScore}% Penalty=-${Math.round(
                  contentPenalty
                )}% Final=${matchScore}%`
              );
            }
          } else {
            console.log(
              `   ✅ "${job.title}": Keywords=${Math.round(
                keywordMatch
              )}% BERT=${bertScore}% Final=${matchScore}%`
            );
          }

          return {
            id: job._id,
            title: job.title,
            company: job.company || "Company",
            companyLogo: job.companyLogo,
            description: job.description,
            location: job.location || "Remote",
            employmentType: job.jobType ? [job.jobType] : ["Full-time"],
            salary: job.salary?.min || 0,
            salaryPeriod: "/year",
            experienceYears: job.experienceRequired || 0,
            requiredSkills: job.requiredSkills || [],
            matchScore: matchScore,
            missingSkillsCount: 0,
            postedAt: job.createdAt,
            applicantsCount: job.applicants?.length || 0,
          };
        });

        // Sort by match score descending
        matchedJobs.sort((a, b) => b.matchScore - a.matchScore);

        // Filter: show jobs with 60% match or higher
        const originalCount = matchedJobs.length;
        matchedJobs = matchedJobs.filter((job) => job.matchScore >= 60);
        console.log(
          `🎯 Filtered jobs: ${originalCount} → ${matchedJobs.length} (showing all matches)`
        );

        console.log("📊 Top 3 matches:");
        matchedJobs.slice(0, 3).forEach((j, i) => {
          console.log(`   ${i + 1}. ${j.title}: ${j.matchScore}%`);
        });
      } catch (matchError) {
        console.error("❌ Python matcher error:", matchError.message);
        // Fallback: return jobs with keyword-based scoring to avoid blocking
        const fallbackCvText = candidate.resumeText || "";
        matchedJobs = jobs.map((job) => {
          const keywordMatch = calculateKeywordMatch(fallbackCvText, job);
          return {
            id: job._id,
            title: job.title,
            company: job.company || "Company",
            companyLogo: job.companyLogo,
            description: job.description,
            location: job.location || "Remote",
            employmentType: job.jobType ? [job.jobType] : ["Full-time"],
            salary: job.salary?.min || 0,
            salaryPeriod: "/year",
            experienceYears: job.experienceRequired || 0,
            requiredSkills: job.requiredSkills || [],
            matchScore: Math.round(keywordMatch),
            missingSkillsCount: 0,
            postedAt: job.createdAt,
            applicantsCount: job.applicants?.length || 0,
          };
        });

        // Filter: show jobs with 60% match or higher
        const beforeFilter = matchedJobs.length;
        matchedJobs = matchedJobs.filter((job) => job.matchScore >= 60);
        matchedJobs.sort((a, b) => b.matchScore - a.matchScore);
        console.log(
          `⚠️ Fallback mode: ${beforeFilter} total jobs, ${matchedJobs.length} jobs with ≥60% match`
        );
      }
    }

    res.json({
      success: true,
      message: "Job matches found",
      data: matchedJobs,
      hasCv: true,
      totalJobs: matchedJobs.length,
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

    if (!message || !message.trim()) {
      return res.status(400).json({
        success: false,
        message: "Message is required",
      });
    }

    // Get candidate's CV text
    const candidate = await Candidate.findOne({ email: req.user.email });
    const cvText = candidate?.resumeText || "";

    // Call Groq API
    try {
      const Groq = (await import("groq-sdk")).default;
      const groq = new Groq({
        apiKey: process.env.GROQ_API_KEY,
      });

      const context = cvText
        ? `You are a professional career assistant chatbot.
The user has uploaded their CV. Use only the CV content to answer the user's question concisely and accurately.

CV Content:
${cvText}

If the question is not related to the CV or career, politely redirect to career topics.`
        : `You are a professional career assistant chatbot.
The user has not uploaded their CV yet. Provide general career advice and encourage them to upload their CV for personalized guidance.`;

      const completion = await groq.chat.completions.create({
        model: "llama-3.3-70b-versatile",
        messages: [
          { role: "system", content: context },
          { role: "user", content: message },
        ],
        temperature: 0.2,
        max_tokens: 1024,
      });

      const answer =
        completion.choices[0]?.message?.content?.trim() ||
        "I couldn't process that. Please try again.";

      res.json({
        success: true,
        answer: answer,
        hasCv: !!cvText,
      });
    } catch (apiError) {
      console.error("Groq API error:", apiError);
      // Fallback response
      res.json({
        success: true,
        answer:
          "I'm currently experiencing technical difficulties. Please try again later or contact support.",
        hasCv: !!cvText,
      });
    }
  } catch (error) {
    console.error("Chatbot error:", error);
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
    // TODO: Implement real notifications from database
    // For now return empty array that matches the expected format
    res.json({
      success: true,
      message: "Student notifications",
      data: [], // Return empty array directly to match Flutter expectations
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
