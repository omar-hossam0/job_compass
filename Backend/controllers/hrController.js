import Job from "../models/Job.js";
import Candidate from "../models/Candidate.js";
import Company from "../models/Company.js";
import Notification from "../models/Notification.js";
import User from "../models/User.js";
import Application from "../models/Application.js";
import SavedCandidate from "../models/SavedCandidate.js";
import mongoose from "mongoose";
import path from "path";
import { fileURLToPath } from "url";
import { spawn } from "child_process";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const MATCH_CVS_SCRIPT = path.join(
  __dirname,
  "..",
  "scripts",
  "match_cvs_to_job.py"
);

const clampPercentage = (value) => {
  const num = Number(value);
  if (!Number.isFinite(num)) return 0;
  if (num < 0) return 0;
  if (num > 100) return 100;
  return Math.round(num * 100) / 100;
};

const buildJobMatchingContext = (job) => {
  if (!job) {
    return { jobText: "", jobSkills: [] };
  }

  const jobObj = job.toObject ? job.toObject() : job;

  const jobSkills = Array.isArray(jobObj.requiredSkills)
    ? jobObj.requiredSkills.filter(Boolean)
    : [];

  const parts = [
    jobObj.title || "",
    jobObj.description || "",
    jobSkills.length ? `Required skills: ${jobSkills.join(", ")}` : "",
    jobObj.experienceLevel ? `Experience level: ${jobObj.experienceLevel}` : "",
    jobObj.location ? `Location: ${jobObj.location}` : "",
  ].filter((part) => part && part.toString().trim().length > 0);

  return {
    jobText: parts.join("\n\n").trim(),
    jobSkills,
  };
};

const runCvMatcher = async (jobText, cvTexts, topK) => {
  if (!jobText || !Array.isArray(cvTexts) || cvTexts.length === 0) {
    return null;
  }

  const cappedTopK = Math.max(1, Math.min(topK || cvTexts.length, cvTexts.length));

  return await new Promise((resolve, reject) => {
    const python = spawn("python", [MATCH_CVS_SCRIPT], {
      stdio: ["pipe", "pipe", "pipe"],
      shell: false,
      env: { ...process.env, PYTHONIOENCODING: "utf-8" },
    });

    const inputData = {
      job_description: jobText,
      cv_texts: cvTexts,
      top_k: cappedTopK,
    };

    let outputData = "";
    let errorData = "";

    python.stdin.write(JSON.stringify(inputData));
    python.stdin.end();

    python.stdout.on("data", (data) => {
      outputData += data.toString();
    });

    python.stderr.on("data", (data) => {
      errorData += data.toString();
      console.log("🐍 Python matcher:", data.toString().trim());
    });

    const timeout = setTimeout(() => {
      python.kill();
      reject(new Error("Python matcher timeout (60s)"));
    }, 60000);

    python.on("close", (code) => {
      clearTimeout(timeout);

      if (code !== 0) {
        reject(
          new Error(
            `Python matcher exited with code ${code}: ${errorData || "no stderr"}`
          )
        );
        return;
      }

      try {
        const parsed = JSON.parse(outputData || "{}");
        if (parsed.success === false) {
          reject(new Error(parsed.error || "Python matcher failed"));
        } else {
          resolve(parsed);
        }
      } catch (err) {
        reject(err);
      }
    });

    python.on("error", (error) => {
      clearTimeout(timeout);
      reject(new Error(`Failed to start Python matcher: ${error.message}`));
    });
  });
};

const generateMatchExplanation = (matchingSkills, jobSkills, score) => {
  if (matchingSkills.length && jobSkills.length) {
    const listedSkills = matchingSkills.slice(0, 5).join(", ");
    let explanation = `Matches ${matchingSkills.length} of ${jobSkills.length} required skills`;
    if (listedSkills) {
      explanation += `: ${listedSkills}`;
      if (matchingSkills.length > 5) {
        explanation += " (+ more)";
      }
    }
    return `${explanation}.`;
  }

  if (score >= 60) {
    return "Strong semantic similarity between the CV and job description.";
  }

  if (score > 0) {
    return "Partial semantic overlap detected between the CV and job description.";
  }

  return "Match score unavailable. Ensure CV and job data are provided.";
};

// Get HR Dashboard Data
export const getHRDashboard = async (req, res) => {
  try {
    // Get company info
    let company = await Company.findOne({ ownerId: req.user.id });

    if (!company) {
      // Auto-create a default company profile
      company = await Company.create({
        name: req.user.name || "My Company",
        industry: "Technology",
        location: "Location Not Set",
        ownerId: req.user.id,
        description: "Please update your company profile",
      });
    }

    // Get statistics
    const activeJobsCount = await Job.countDocuments({
      companyId: company._id,
      status: "Active",
    });

    const totalCandidatesCount = await Candidate.countDocuments();

    // Get recent jobs
    const recentJobs = await Job.find({ companyId: company._id })
      .sort({ createdAt: -1 })
      .limit(5)
      .select("title status applicants createdAt");

    res.json({
      success: true,
      data: {
        companyName: company.name,
        activeJobsCount,
        totalCandidatesCount,
        recentJobs: recentJobs.map((job) => ({
          id: job._id,
          title: job.title,
          status: job.status,
          applicantsCount: job.applicants?.length || 0,
          postedDate: job.createdAt,
        })),
      },
    });
  } catch (error) {
    console.error("HR Dashboard Error:", error);
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// Get all jobs for HR
export const getHRJobs = async (req, res) => {
  try {
    console.log("\n📋 GET HR JOBS REQUEST");
    console.log("👤 User ID:", req.user.id);

    // Find jobs posted by this user
    const jobs = await Job.find({ postedBy: req.user.id })
      .sort({ createdAt: -1 })
      .select(
        "title description requiredSkills experienceLevel salary location status applicants createdAt customQuestions companyLogo"
      );

    console.log(`📊 Found ${jobs.length} jobs for user ${req.user.email}`);

    res.json({
      success: true,
      data: jobs.map((job) => ({
        id: job._id,
        title: job.title,
        description: job.description,
        requiredSkills: job.requiredSkills,
        experienceLevel: job.experienceLevel,
        salary: job.salary,
        location: job.location,
        status: job.status,
        applicantsCount: job.applicants?.length || 0,
        postedDate: job.createdAt,
        customQuestions: job.customQuestions || [],
        companyLogo: job.companyLogo,
      })),
    });
  } catch (error) {
    console.error("Get HR Jobs Error:", error);
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// Create new job
export const createJob = async (req, res) => {
  try {
    let company = await Company.findOne({ ownerId: req.user.id });

    if (!company) {
      // Auto-create a default company profile
      company = await Company.create({
        name: req.user.name || "My Company",
        industry: "Technology",
        location: "Location Not Set",
        ownerId: req.user.id,
        description: "Please update your company profile",
      });
    }

    const {
      title,
      description,
      requiredSkills,
      experienceLevel,
      customQuestions,
      salary,
      location,
      jobType,
    } = req.body;

    console.log("📋 createJob in hrController - Received customQuestions:", customQuestions);
    console.log("📋 createJob in hrController - Type:", typeof customQuestions);

    // Parse customQuestions if it's a string
    let questionsArray = customQuestions || [];
    if (typeof customQuestions === "string") {
      try {
        questionsArray = JSON.parse(customQuestions);
      } catch (e) {
        questionsArray = [];
      }
    }

    console.log("📋 createJob in hrController - Parsed questionsArray:", questionsArray);

    const job = await Job.create({
      title,
      description,
      requiredSkills: Array.isArray(requiredSkills)
        ? requiredSkills
        : requiredSkills.split(",").map((s) => s.trim()),
      experienceLevel,
      companyId: company._id,
      postedBy: req.user.id,
      status: "Active",
      department: req.body.department || "General",
      location: location || company.location,
      salary: salary,
      jobType: jobType,
      customQuestions: questionsArray,
    });

    console.log("✅ Job created with customQuestions:", job.customQuestions);

    res.status(201).json({
      success: true,
      data: {
        id: job._id,
        title: job.title,
        description: job.description,
        requiredSkills: job.requiredSkills,
        experienceLevel: job.experienceLevel,
        status: job.status,
        customQuestions: job.customQuestions,
      },
    });
  } catch (error) {
    console.error("Create Job Error:", error);
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// Get job by ID
export const getJobById = async (req, res) => {
  try {
    console.log("\n📋 GET JOB BY ID");
    console.log("👤 User:", req.user.email);
    console.log("🆔 Job ID:", req.params.id);

    // Find job posted by this user
    const job = await Job.findOne({
      _id: req.params.id,
      postedBy: req.user.id,
    });

    if (!job) {
      console.log("❌ Job not found or not owned by user");
      return res.status(404).json({
        success: false,
        message: "Job not found",
      });
    }

    console.log("✅ Job found:", job.title);
    console.log("📊 Applicants:", job.applicants?.length || 0);

    res.json({
      success: true,
      data: {
        id: job._id,
        title: job.title,
        description: job.description,
        requiredSkills: job.requiredSkills,
        experienceLevel: job.experienceLevel,
        salary: job.salary,
        location: job.location,
        status: job.status,
        applicantsCount: job.applicants?.length || 0,
        postedDate: job.createdAt,
        department: job.department,
        customQuestions: job.customQuestions || [],
        companyLogo: job.companyLogo,
      },
    });
  } catch (error) {
    console.error("Get Job Error:", error);
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// Update job
export const updateJob = async (req, res) => {
  try {
    const company = await Company.findOne({ ownerId: req.user.id });

    if (!company) {
      return res.status(404).json({
        success: false,
        message: "Company profile not found",
      });
    }

    const job = await Job.findOneAndUpdate(
      { _id: req.params.id, companyId: company._id },
      { ...req.body },
      { new: true, runValidators: true }
    );

    if (!job) {
      return res.status(404).json({
        success: false,
        message: "Job not found",
      });
    }

    res.json({
      success: true,
      data: job,
    });
  } catch (error) {
    console.error("Update Job Error:", error);
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// Close job
export const closeJob = async (req, res) => {
  try {
    const company = await Company.findOne({ ownerId: req.user.id });

    if (!company) {
      return res.status(404).json({
        success: false,
        message: "Company profile not found",
      });
    }

    const job = await Job.findOneAndUpdate(
      { _id: req.params.id, companyId: company._id },
      { status: "Closed" },
      { new: true }
    );

    if (!job) {
      return res.status(404).json({
        success: false,
        message: "Job not found",
      });
    }

    res.json({
      success: true,
      message: "Job closed successfully",
      data: job,
    });
  } catch (error) {
    console.error("Close Job Error:", error);
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// Get candidates for a job
export const getJobCandidates = async (req, res) => {
  try {
    console.log("Getting candidates for job:", req.params.id);
    console.log("User ID:", req.user.id);

    const job = await Job.findOne({
      _id: req.params.id,
      postedBy: req.user.id,
    });

    console.log("Job found:", job ? "Yes" : "No");

    if (!job) {
      return res.status(404).json({
        success: false,
        message: "Job not found",
      });
    }

    // Import Application model
    const Application = (await import("../models/Application.js")).default;

    // Find all applications for this job
    const applications = await Application.find({ jobId: req.params.id })
      .populate("candidateId", "name email photo skills resumeUrl applications resumeText")
      .sort({ appliedAt: -1 });

    console.log("Applications found:", applications.length);

    const { jobText, jobSkills } = buildJobMatchingContext(job);

    const candidateEntries = applications
      .map((application) => {
        const candidateDoc = application.candidateId;
        if (!candidateDoc) {
          return null;
        }

        const candidateObj = candidateDoc.toObject ? candidateDoc.toObject() : candidateDoc;
        const candidateId =
          candidateObj._id?.toString?.() ||
          candidateDoc._id?.toString?.() ||
          (typeof candidateDoc === "string" ? candidateDoc : null);

        if (!candidateId) {
          return null;
        }

        const candidateSkills = Array.isArray(candidateObj.skills)
          ? candidateObj.skills.filter(Boolean)
          : [];

        const resumeText =
          typeof candidateObj.resumeText === "string"
            ? candidateObj.resumeText
            : "";

        return {
          application,
          candidateObj,
          candidateId,
          candidateSkills,
          resumeText,
        };
      })
      .filter((entry) => entry !== null);

    const resumeEntries = candidateEntries
      .filter((entry) => entry.resumeText && entry.resumeText.trim().length >= 10)
      .map((entry) => ({
        candidateId: entry.candidateId,
        resumeText: entry.resumeText,
      }));

    const cvTexts = resumeEntries.map((entry) => entry.resumeText);
    const resumeIndexToCandidateId = resumeEntries.map((entry) => entry.candidateId);

    const pythonScores = new Map();

    if (jobText && cvTexts.length > 0) {
      try {
        const pythonResult = await runCvMatcher(jobText, cvTexts, cvTexts.length);

        if (pythonResult?.matches?.length) {
          pythonResult.matches.forEach((match) => {
            const idx =
              match.job_index !== undefined ? match.job_index : match.cv_index;
            const candidateId = resumeIndexToCandidateId[idx];

            if (!candidateId) {
              return;
            }

            const normalized = clampPercentage(match.similarity_score);
            pythonScores.set(candidateId, normalized);
          });
        }
      } catch (err) {
        console.error("❌ Python matcher (candidate list) failed:", err.message);
      }
    }

    const candidatesWithMatch = candidateEntries
      .map((entry) => {
        const { application, candidateObj, candidateId, candidateSkills } = entry;

        const matchingSkills = candidateSkills.filter((skill) =>
          jobSkills.some((jobSkill) => {
            if (!jobSkill || !skill) return false;
            return (
              jobSkill.toLowerCase().includes(skill.toLowerCase()) ||
              skill.toLowerCase().includes(jobSkill.toLowerCase())
            );
          })
        );

        const fallbackScore = jobSkills.length
          ? Math.round((matchingSkills.length / jobSkills.length) * 100)
          : 0;

        const pythonScore = pythonScores.has(candidateId)
          ? pythonScores.get(candidateId)
          : null;

        const finalScore = clampPercentage(
          pythonScore !== null && pythonScore !== undefined ? pythonScore : fallbackScore
        );

        const matchExplanation = generateMatchExplanation(
          matchingSkills,
          jobSkills,
          finalScore
        );

        const basicInfo = application.basicInfo || {};

        return {
          id: candidateId,
          name: basicInfo.fullName || candidateObj.name || "",
          email: candidateObj.email || "",
          phone: basicInfo.phoneNumber || "",
          region: basicInfo.region || "",
          address: basicInfo.address || "",
          expectedSalary: basicInfo.expectedSalary || null,
          photo: candidateObj.photo || "",
          extractedSkills: candidateSkills.slice(0, 5),
          matchPercentage: finalScore,
          matchExplanation,
          appliedAt: application.appliedAt,
          applicationStatus: application.status,
          applicationId: application._id,
          customAnswers: application.customAnswers || [],
        };
      })
      .filter((candidate) => candidate !== null);

    candidatesWithMatch.sort(
      (a, b) => (b.matchPercentage || 0) - (a.matchPercentage || 0)
    );

    res.json({
      success: true,
      data: {
        job: {
          id: job._id,
          title: job.title,
          description: job.description,
          customQuestions: job.customQuestions || [],
        },
        candidates: candidatesWithMatch,
      },
    });
  } catch (error) {
    console.error("Get Job Candidates Error:", error);
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// Get candidate details
export const getCandidateDetails = async (req, res) => {
  try {
    const candidateId = req.params.id;
    const jobId = req.query.jobId; // Optional: to get application-specific data

    const candidate = await Candidate.findById(candidateId);

    if (!candidate) {
      return res.status(404).json({
        success: false,
        message: "Candidate not found",
      });
    }

    // Get the user info for more details
    const user = await User.findById(candidate.user);

    // Get application data if jobId is provided
    let applicationData = null;
    if (jobId) {
      applicationData = await Application.findOne({
        candidateId: candidateId,
        jobId: jobId,
      });
    } else {
      // Get the most recent application
      applicationData = await Application.findOne({
        candidateId: candidateId,
      }).sort({ appliedAt: -1 });
    }

    let effectiveJobId = jobId || null;
    if (!effectiveJobId && applicationData?.jobId) {
      try {
        effectiveJobId = applicationData.jobId.toString();
      } catch (e) {
        effectiveJobId = applicationData.jobId;
      }
    }

    let job = null;
    if (effectiveJobId) {
      job = await Job.findById(effectiveJobId).catch(() => null);
    }

    const { jobText, jobSkills } = buildJobMatchingContext(job);

    const candidateObj = candidate.toObject ? candidate.toObject() : candidate;
    const candidateSkills = Array.isArray(candidateObj.skills)
      ? candidateObj.skills.filter(Boolean)
      : [];

    const matchingSkills = candidateSkills.filter((skill) =>
      jobSkills.some((jobSkill) => {
        if (!jobSkill || !skill) return false;
        return (
          jobSkill.toLowerCase().includes(skill.toLowerCase()) ||
          skill.toLowerCase().includes(jobSkill.toLowerCase())
        );
      })
    );

    const skillOverlapPercentage = jobSkills.length
      ? Math.round((matchingSkills.length / jobSkills.length) * 100)
      : 0;

    let pythonScore = null;
    const resumeText =
      typeof candidateObj.resumeText === "string" ? candidateObj.resumeText : "";

    if (jobText && resumeText.trim().length > 0) {
      try {
        const pythonResult = await runCvMatcher(jobText, [resumeText], 1);

        if (
          pythonResult?.matches?.length &&
          pythonResult.matches[0]?.similarity_score !== undefined
        ) {
          pythonScore = clampPercentage(pythonResult.matches[0].similarity_score);
        }
      } catch (err) {
        console.error("❌ Semantic match calculation failed:", err.message);
      }
    }

    const finalScore = clampPercentage(
      pythonScore !== null && pythonScore !== undefined
        ? pythonScore
        : skillOverlapPercentage
    );

    const matchExplanation = generateMatchExplanation(
      matchingSkills,
      jobSkills,
      finalScore
    );

    // Check if this candidate is saved by the HR
    const hrId = req.user.id;
    const savedCandidate = await SavedCandidate.findOne({
      hrId: hrId,
      candidateId: candidateId,
    }).catch(() => null); // Ignore if model doesn't exist

    res.json({
      success: true,
      isSaved: !!savedCandidate,
      data: {
        id: candidate._id,
        name: candidate.name || user?.name || '',
        email: candidate.email || user?.email || '',
        phone: candidate.phone || user?.phone || applicationData?.basicInfo?.phoneNumber || '',
        profilePicture: candidate.photo || user?.profileImage || null,
        university: candidate.university || '',
        degree: candidate.degree || '',
        extractedSkills: candidate.skills || [],
        experience: candidate.experience || '',
        experienceLevel: candidate.experienceLevel || '',
        cvText: candidate.resumeText || '',
        cvUrl: candidate.cvUrl || '',
        cvFileName: candidate.cvFileName || '',
        // Application specific data
        appliedAt: applicationData?.appliedAt || null,
        applicationStatus: applicationData?.status || 'Pending',
        basicInfo: applicationData?.basicInfo || null,
        screeningAnswers: applicationData?.customAnswers || [],
        hrNotes: applicationData?.hrNotes || '',
        // Match info
        matchPercentage: finalScore,
        matchExplanation,
      },
    });
  } catch (error) {
    console.error("Get Candidate Details Error:", error);
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// Save candidate
export const saveCandidate = async (req, res) => {
  try {
    const candidateId = req.params.id;
    const hrId = req.user.id;
    const { jobId, notes } = req.body;

    // Check if already saved
    const existingSaved = await SavedCandidate.findOne({
      hrId: hrId,
      candidateId: candidateId,
    });

    if (existingSaved) {
      return res.json({
        success: true,
        message: "Candidate already saved",
        data: existingSaved,
      });
    }

    // Save the candidate
    const savedCandidate = await SavedCandidate.create({
      hrId: hrId,
      candidateId: candidateId,
      jobId: jobId || null,
      notes: notes || "",
    });

    res.json({
      success: true,
      message: "Candidate saved successfully",
      data: savedCandidate,
    });
  } catch (error) {
    console.error("Save Candidate Error:", error);
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// Unsave candidate
export const unsaveCandidate = async (req, res) => {
  try {
    const candidateId = req.params.id;
    const hrId = req.user.id;

    const result = await SavedCandidate.findOneAndDelete({
      hrId: hrId,
      candidateId: candidateId,
    });

    if (!result) {
      return res.status(404).json({
        success: false,
        message: "Saved candidate not found",
      });
    }

    res.json({
      success: true,
      message: "Candidate unsaved successfully",
    });
  } catch (error) {
    console.error("Unsave Candidate Error:", error);
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// Get all saved candidates
export const getSavedCandidates = async (req, res) => {
  try {
    const hrId = req.user.id;

    const savedCandidates = await SavedCandidate.find({ hrId: hrId })
      .populate({
        path: 'candidateId',
        select: 'name email skills photo experienceLevel',
      })
      .populate({
        path: 'jobId',
        select: 'title',
      })
      .sort({ savedAt: -1 });

    res.json({
      success: true,
      count: savedCandidates.length,
      data: savedCandidates.map((saved) => ({
        id: saved._id,
        candidate: saved.candidateId ? {
          id: saved.candidateId._id,
          name: saved.candidateId.name,
          email: saved.candidateId.email,
          skills: saved.candidateId.skills || [],
          photo: saved.candidateId.photo,
          experienceLevel: saved.candidateId.experienceLevel,
        } : null,
        jobTitle: saved.jobId?.title || null,
        notes: saved.notes,
        savedAt: saved.savedAt,
      })),
    });
  } catch (error) {
    console.error("Get Saved Candidates Error:", error);
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// Get HR notifications
export const getHRNotifications = async (req, res) => {
  try {
    const notifications = await Notification.find({ userId: req.user.id })
      .sort({ createdAt: -1 })
      .limit(50);

    res.json({
      success: true,
      count: notifications.length,
      data: notifications.map((notif) => ({
        id: notif._id,
        title: notif.title,
        message: notif.message,
        type: notif.type || "system",
        read: notif.read || false,
        createdAt: notif.createdAt,
        metadata: notif.metadata || {},
      })),
    });
  } catch (error) {
    console.error("Get Notifications Error:", error);
    res.status(500).json({
      success: true, // Return success but empty array
      count: 0,
      data: [],
    });
  }
};

// Get HR profile
export const getHRProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select("-password");
    const company = await Company.findOne({ ownerId: req.user.id });

    res.json({
      success: true,
      data: {
        user,
        company,
      },
    });
  } catch (error) {
    console.error("Get Profile Error:", error);
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// Update HR profile
export const updateHRProfile = async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.user.id,
      { $set: req.body },
      { new: true, runValidators: true }
    ).select("-password");

    res.json({
      success: true,
      data: user,
    });
  } catch (error) {
    console.error("Update Profile Error:", error);
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};
