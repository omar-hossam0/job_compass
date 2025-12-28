import express from "express";
import { verifyToken } from "../middleware/authMiddleware.js";
import Job from "../models/Job.js";
import Candidate from "../models/Candidate.js";

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
          jobObj.matchScore = matchData
            ? Math.round(matchData.similarity_score * 100)
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
    res.json({
      success: true,
      message: "Student profile",
      data: {
        id: req.user.id,
        name: req.user.name,
        email: req.user.email,
        role: req.user.role,
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
// UPLOAD CV
// ============================================
router.post("/upload-cv", async (req, res) => {
  try {
    res.json({
      success: true,
      message: "CV uploaded successfully",
      fileUrl: "/uploads/cv.pdf",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

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
// JOB MATCHES
// ============================================
router.get("/job-matches", async (req, res) => {
  try {
    res.json({
      success: true,
      message: "Job matches",
      data: {
        matches: [],
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
