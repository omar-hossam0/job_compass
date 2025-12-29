import express from "express";
import multer from "multer";
import { verifyToken } from "../middleware/authMiddleware.js";
import Job from "../models/Job.js";
import Candidate from "../models/Candidate.js";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import pdf from "pdf-parse";

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

// Protect all student routes
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
            try {
                const { getPythonMatcher } = await import("../utils/pythonMatcher.js");
                const pythonMatcher = getPythonMatcher();

                const cvText = candidate.resumeText;
                const jobDescriptions = jobs.map((job) => job.description || "");

                const matches = await pythonMatcher.match(
                    cvText,
                    jobDescriptions,
                    jobs.length
                );

                enrichedJobs = jobs.map((job, idx) => {
                    const matchData = matches.find((m) => m.job_index === idx);
                    const jobObj = job.toObject();
                    // Python matcher returns similarity_score as percentage (0-100)
                    jobObj.matchScore = matchData
                        ? Math.round(matchData.similarity_score)
                        : 0;
                    return jobObj;
                });

                enrichedJobs.sort((a, b) => (b.matchScore || 0) - (a.matchScore || 0));
            } catch (matchError) {
                console.error("❌ Match scoring failed:", matchError.message);
            }
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
            const candidateByEmail = await Candidate.findOne({ email: req.user.email });
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
                skills: candidate?.skills || [],
                profileCompletion: candidate ? 70 : 30,
                skillMatchScore: 0,
            },
        });

        console.log("✅ Profile response sent with cvFileName:", candidate?.cvFileName);
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
                            console.log("📌 Found existing candidate by email, updating user reference");
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
            const filePath = path.join(__dirname, "../uploads/cvs", req.file.filename);
            let resumeText = "";
            let extractedSkills = [];

            if (req.file.mimetype === "application/pdf") {
                console.log("📝 Extracting text from PDF...");
                resumeText = await extractTextFromPdf(filePath);
                console.log("📝 Extracted text length:", resumeText.length, "chars");

                // Extract skills from text
                extractedSkills = extractSkillsFromText(resumeText);
                console.log("🔧 Extracted skills:", extractedSkills);
            } else if (req.file.mimetype === "text/plain") {
                // For .txt files, read directly
                resumeText = fs.readFileSync(filePath, "utf-8");
                extractedSkills = extractSkillsFromText(resumeText);
            }

            // Update CV info
            candidate.cvUrl = `/uploads/cvs/${req.file.filename}`;
            candidate.cvFileName = req.file.originalname;
            candidate.cvUploadedAt = new Date();
            candidate.resumeText = resumeText;
            if (extractedSkills.length > 0) {
                candidate.skills = extractedSkills;
            }

            console.log("💾 Saving candidate with CV info and text...");
            await candidate.save();

            console.log("✅ Candidate CV updated:", {
                cvUrl: candidate.cvUrl,
                cvFileName: candidate.cvFileName,
                candidateId: candidate._id,
                resumeTextLength: resumeText.length,
                skillsCount: extractedSkills.length,
            });

            res.json({
                success: true,
                message: "CV uploaded successfully",
                cvUrl: `/uploads/cvs/${req.file.filename}`,
                cvFileName: req.file.originalname,
                cvUploadedAt: new Date(),
                textExtracted: resumeText.length > 0,
                skillsExtracted: extractedSkills.length,
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

        // Get candidate data for CV text
        const candidate = await Candidate.findOne({ user: req.user._id });

        if (!candidate) {
            console.log("⚠️ No candidate profile found");
            return res.json({
                success: true,
                message: "No CV uploaded yet",
                data: [],
                hasCv: false,
            });
        }

        if (!candidate.resumeText || !candidate.resumeText.trim()) {
            console.log("⚠️ No CV text available");
            return res.json({
                success: true,
                message: "Upload a CV to get job matches",
                data: [],
                hasCv: false,
            });
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

        // Use Python BERT matcher for AI matching
        let matchedJobs = [];
        try {
            const { getPythonMatcher } = await import("../utils/pythonMatcher.js");
            const pythonMatcher = getPythonMatcher();

            // Start service if not running
            if (!pythonMatcher.isReady) {
                console.log("🚀 Starting Python matcher service...");
                await pythonMatcher.start();
            }

            const cvText = candidate.resumeText;
            const jobDescriptions = jobs.map((job) =>
                `${job.title}. ${job.description || ""}. Skills: ${(job.requiredSkills || []).join(", ")}`
            );

            console.log("🔍 Running BERT matching...");
            const matches = await pythonMatcher.match(cvText, jobDescriptions, jobs.length);
            console.log("✅ Matching complete, got", matches.length, "results");

            // Map matches to jobs with scores
            matchedJobs = jobs.map((job, idx) => {
                const matchData = matches.find((m) => m.job_index === idx);
                // Python matcher returns similarity_score as percentage (0-100), not decimal
                const matchScore = matchData
                    ? Math.round(matchData.similarity_score)
                    : 0;

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

            console.log("📊 Top 3 matches:");
            matchedJobs.slice(0, 3).forEach((j, i) => {
                console.log(`   ${i + 1}. ${j.title}: ${j.matchScore}%`);
            });

        } catch (matchError) {
            console.error("❌ Python matcher error:", matchError.message);
            // Fallback: return jobs without match scores
            matchedJobs = jobs.map((job) => ({
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
            }));
        }

        res.json({
            success: true,
            message: "Job matches retrieved",
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
        res.json({
            success: true,
            message: "Student notifications",
            data: {
                notifications: [],
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
