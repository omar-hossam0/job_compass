import Job from "../models/Job.js";
import Candidate from "../models/Candidate.js";
import Company from "../models/Company.js";
import Notification from "../models/Notification.js";
import User from "../models/User.js";

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

    const { title, description, requiredSkills, experienceLevel } = req.body;

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
      location: company.location,
    });

    res.status(201).json({
      success: true,
      data: {
        id: job._id,
        title: job.title,
        description: job.description,
        requiredSkills: job.requiredSkills,
        experienceLevel: job.experienceLevel,
        status: job.status,
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

    // Find all candidates who have applied to this job
    const candidates = await Candidate.find({
      "applications.jobId": req.params.id,
    }).select("name email photo skills resumeUrl applications resumeText");

    console.log("Candidates who applied:", candidates.length);

    // Calculate match percentage for each candidate
    const candidatesWithMatch = candidates.map((candidate) => {
      const candidateSkills = candidate.skills || [];
      const jobSkills = job.requiredSkills || [];

      const matchingSkills = candidateSkills.filter((skill) =>
        jobSkills.some(
          (jobSkill) =>
            jobSkill.toLowerCase().includes(skill.toLowerCase()) ||
            skill.toLowerCase().includes(jobSkill.toLowerCase())
        )
      );

      const matchPercentage =
        jobSkills.length > 0
          ? Math.round((matchingSkills.length / jobSkills.length) * 100)
          : 0;

      // Find the application for this job
      const application = candidate.applications.find(
        (app) => app.jobId.toString() === req.params.id
      );

      return {
        id: candidate._id,
        name: candidate.name,
        email: candidate.email,
        photo: candidate.photo || "",
        extractedSkills: candidateSkills.slice(0, 5),
        matchPercentage,
        appliedAt: application?.appliedAt || null,
        applicationStatus: application?.status || "Pending",
      };
    });

    // Sort by match percentage
    candidatesWithMatch.sort((a, b) => b.matchPercentage - a.matchPercentage);

    res.json({
      success: true,
      data: candidatesWithMatch,
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
    const candidate = await Candidate.findById(req.params.id);

    if (!candidate) {
      return res.status(404).json({
        success: false,
        message: "Candidate not found",
      });
    }

    res.json({
      success: true,
      data: {
        id: candidate._id,
        name: candidate.name,
        email: candidate.email,
        phone: candidate.phone,
        photo: candidate.photo || "",
        university: candidate.university,
        degree: candidate.degree,
        extractedSkills: candidate.skills,
        experience: candidate.experience,
        experienceLevel: candidate.experienceLevel,
        cvText: candidate.resumeText || "",
        resumeUrl: candidate.resumeUrl,
        matchPercentage: 75, // Default for now
        matchExplanation: "Good match based on skills and experience",
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
    // In a real app, you would save this to a saved_candidates collection
    res.json({
      success: true,
      message: "Candidate saved successfully",
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

// Get HR notifications
export const getHRNotifications = async (req, res) => {
  try {
    const notifications = await Notification.find({ userId: req.user.id })
      .sort({ createdAt: -1 })
      .limit(20);

    res.json({
      success: true,
      data: notifications.map((notif) => ({
        id: notif._id,
        title: notif.title,
        message: notif.message,
        type: notif.type || "info",
        isRead: notif.isRead || false,
        createdAt: notif.createdAt,
      })),
    });
  } catch (error) {
    console.error("Get Notifications Error:", error);
    res.status(500).json({
      success: true, // Return success but empty array
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
