import Candidate from "../models/Candidate.js";
import Job from "../models/Job.js";

// Get all candidates
export const getAllCandidates = async (req, res) => {
  try {
    const candidates = await Candidate.find()
      .sort({ createdAt: -1 })
      .populate("applications.jobId", "title department");

    res.json({
      success: true,
      count: candidates.length,
      data: candidates,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// Get single candidate
export const getCandidate = async (req, res) => {
  try {
    const candidate = await Candidate.findById(req.params.id).populate(
      "applications.jobId",
      "title department"
    );

    if (!candidate) {
      return res.status(404).json({
        success: false,
        message: "Candidate not found",
      });
    }

    res.json({
      success: true,
      data: candidate,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// Create candidate
export const createCandidate = async (req, res) => {
  try {
    const candidate = await Candidate.create(req.body);

    res.status(201).json({
      success: true,
      message: "Candidate created successfully",
      data: candidate,
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: "Failed to create candidate",
      error: error.message,
    });
  }
};

// Update candidate
export const updateCandidate = async (req, res) => {
  try {
    const candidate = await Candidate.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );

    if (!candidate) {
      return res.status(404).json({
        success: false,
        message: "Candidate not found",
      });
    }

    res.json({
      success: true,
      message: "Candidate updated successfully",
      data: candidate,
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: "Failed to update candidate",
      error: error.message,
    });
  }
};

// Delete candidate
export const deleteCandidate = async (req, res) => {
  try {
    const candidate = await Candidate.findByIdAndDelete(req.params.id);

    if (!candidate) {
      return res.status(404).json({
        success: false,
        message: "Candidate not found",
      });
    }

    res.json({
      success: true,
      message: "Candidate deleted successfully",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// Search candidates
export const searchCandidates = async (req, res) => {
  try {
    const { q, skills, experienceLevel, minExperience } = req.query;
    let query = {};

    if (q) {
      query.$text = { $search: q };
    }
    if (skills) {
      query.skills = { $in: skills.split(",") };
    }
    if (experienceLevel) {
      query.experienceLevel = experienceLevel;
    }
    if (minExperience) {
      query.experience = { $gte: parseInt(minExperience) };
    }

    const candidates = await Candidate.find(query).sort({ createdAt: -1 });

    res.json({
      success: true,
      count: candidates.length,
      data: candidates,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// Apply for job
export const applyForJob = async (req, res) => {
  try {
    const { candidateId, jobId, matchPercentage } = req.body;

    const candidate = await Candidate.findById(candidateId);
    const job = await Job.findById(jobId);

    if (!candidate || !job) {
      return res.status(404).json({
        success: false,
        message: "Candidate or Job not found",
      });
    }

    // Check if already applied
    const alreadyApplied = candidate.applications.some(
      (app) => app.jobId.toString() === jobId
    );

    if (alreadyApplied) {
      return res.status(400).json({
        success: false,
        message: "Already applied to this job",
      });
    }

    // Add application
    candidate.applications.push({
      jobId,
      matchPercentage: matchPercentage || 0,
      status: "Applied",
    });

    await candidate.save();

    // Update job applicants count
    job.applicantsCount += 1;
    await job.save();

    res.json({
      success: true,
      message: "Application submitted successfully",
      data: candidate,
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: "Failed to apply",
      error: error.message,
    });
  }
};

// Update application status
export const updateApplicationStatus = async (req, res) => {
  try {
    const { candidateId, jobId, status } = req.body;

    const candidate = await Candidate.findById(candidateId);

    if (!candidate) {
      return res.status(404).json({
        success: false,
        message: "Candidate not found",
      });
    }

    const application = candidate.applications.find(
      (app) => app.jobId.toString() === jobId
    );

    if (!application) {
      return res.status(404).json({
        success: false,
        message: "Application not found",
      });
    }

    application.status = status;
    await candidate.save();

    res.json({
      success: true,
      message: "Application status updated",
      data: candidate,
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: "Failed to update status",
      error: error.message,
    });
  }
};

// Calculate match percentage (AI placeholder)
export const calculateMatch = async (req, res) => {
  try {
    const { candidateId, jobId } = req.body;

    const candidate = await Candidate.findById(candidateId);
    const job = await Job.findById(jobId);

    if (!candidate || !job) {
      return res.status(404).json({
        success: false,
        message: "Candidate or Job not found",
      });
    }

    // Simple matching algorithm
    const candidateSkills = candidate.skills.map((s) => s.toLowerCase());
    const requiredSkills = job.requiredSkills.map((s) => s.toLowerCase());

    const matchingSkills = candidateSkills.filter((skill) =>
      requiredSkills.includes(skill)
    );

    const matchPercentage = Math.round(
      (matchingSkills.length / requiredSkills.length) * 100
    );

    res.json({
      success: true,
      data: {
        matchPercentage,
        matchingSkills,
        missingSkills: requiredSkills.filter(
          (skill) => !candidateSkills.includes(skill)
        ),
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};
