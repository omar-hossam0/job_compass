import Job from "../models/Job.js";
import Candidate from "../models/Candidate.js";
import Application from "../models/Application.js";

// Get all jobs
export const getAllJobs = async (req, res) => {
  try {
    let query = {};

    // HR sees only their posted jobs, employees see all active jobs
    if (req.user.role === "hr") {
      query = { postedBy: req.user.id };
    } else {
      // Employees see all active jobs
      query = { status: "Active" };
    }

    const jobs = await Job.find(query)
      .sort({ createdAt: -1 })
      .populate("postedBy", "name email");

    // For employees: calculate match scores using Python BERT matcher
    let enrichedJobs = jobs;
    if (req.user.role === "employee") {
      try {
        // Import pythonMatcher here to avoid circular dependency
        const { getPythonMatcher } = await import("../utils/pythonMatcher.js");
        const pythonMatcher = getPythonMatcher();

        const candidate = await Candidate.findOne({ email: req.user.email });
        if (candidate && candidate.resumeText && candidate.resumeText.trim()) {
          const cvText = candidate.resumeText;
          const jobDescriptions = jobs.map((job) => job.description || "");

          // Use Python BERT matcher for accurate semantic similarity
          const matches = await pythonMatcher.match(
            cvText,
            jobDescriptions,
            jobs.length
          );

          enrichedJobs = jobs.map((job, idx) => {
            const matchData = matches.find((m) => m.job_index === idx);
            const jobObj = job.toObject();
            jobObj.matchScore = matchData
              ? Math.round(matchData.similarity_score * 100) / 100
              : 0;
            return jobObj;
          });

          // Sort by match score descending
          enrichedJobs.sort(
            (a, b) => (b.matchScore || 0) - (a.matchScore || 0)
          );
        }
      } catch (matchError) {
        console.error(
          "❌ Failed to calculate match scores:",
          matchError.message
        );
        // Continue without match scores
      }
    }

    res.json({
      success: true,
      count: enrichedJobs.length,
      data: enrichedJobs,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// Get single job
export const getJob = async (req, res) => {
  try {
    const job = await Job.findById(req.params.id).populate(
      "postedBy",
      "name email"
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
    console.log(
      "📥 createJob called by user:",
      req.user ? req.user._id : "unknown"
    );
    console.log("📋 req.body keys:", Object.keys(req.body));
    if (req.file)
      console.log(
        "📎 Uploaded file:",
        req.file.originalname,
        "size:",
        req.file.size
      );
    const {
      title,
      description,
      department,
      requiredSkills,
      experienceLevel,
      salary,
      location,
      jobType,
      company,
      customQuestions,
      companyLogo: logoFromBody,
    } = req.body;

    // Parse requiredSkills if it's a string
    let skillsArray = requiredSkills;
    if (typeof requiredSkills === "string") {
      skillsArray = requiredSkills
        .split(",")
        .map((skill) => skill.trim())
        .filter((skill) => skill);
    }

    // Parse customQuestions if it's a string
    let questionsArray = customQuestions || [];
    if (typeof customQuestions === "string") {
      try {
        questionsArray = JSON.parse(customQuestions);
      } catch (e) {
        questionsArray = [];
      }
    }

    // Parse salary if it's sent as separate fields
    let salaryObj = salary;
    if (req.body.salaryMin || req.body.salaryMax) {
      salaryObj = {
        min: req.body.salaryMin ? Number(req.body.salaryMin) : undefined,
        max: req.body.salaryMax ? Number(req.body.salaryMax) : undefined,
        currency: req.body.currency || "USD",
      };
    }

    // Handle company logo (from body or file upload)
    let companyLogo = logoFromBody || null;
    if (req.file) {
      companyLogo = `data:${req.file.mimetype
        };base64,${req.file.buffer.toString("base64")}`;
    }

    const job = await Job.create({
      title,
      description,
      department: department || "General",
      requiredSkills: skillsArray,
      experienceLevel,
      salary: salaryObj,
      location: location || "Remote",
      jobType: jobType || "Full-time",
      company: company || "Company Name",
      companyLogo,
      customQuestions: questionsArray,
      postedBy: req.user.id,
    });

    res.status(201).json({
      success: true,
      message: "Job created successfully",
      data: job,
    });
  } catch (error) {
    console.error("Create Job Error:", error);
    res.status(400).json({
      success: false,
      message: "Failed to create job",
      error: error.message,
    });
  }
};

// Update job
export const updateJob = async (req, res) => {
  try {
    let job = await Job.findById(req.params.id);

    if (!job) {
      return res.status(404).json({
        success: false,
        message: "Job not found",
      });
    }

    // Check if user owns the job
    if (job.postedBy.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: "Not authorized to update this job",
      });
    }

    job = await Job.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });

    res.json({
      success: true,
      message: "Job updated successfully",
      data: job,
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: "Failed to update job",
      error: error.message,
    });
  }
};

// Delete job
export const deleteJob = async (req, res) => {
  try {
    const job = await Job.findById(req.params.id);

    if (!job) {
      return res.status(404).json({
        success: false,
        message: "Job not found",
      });
    }

    // Check if user owns the job
    if (job.postedBy.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: "Not authorized to delete this job",
      });
    }

    await Job.findByIdAndDelete(req.params.id);

    res.json({
      success: true,
      message: "Job deleted successfully",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// Search jobs
export const searchJobs = async (req, res) => {
  try {
    const { q, status, experienceLevel } = req.query;
    let query = { postedBy: req.user.id };

    if (q) {
      query.$text = { $search: q };
    }
    if (status) {
      query.status = status;
    }
    if (experienceLevel) {
      query.experienceLevel = experienceLevel;
    }

    const jobs = await Job.find(query).sort({ createdAt: -1 });

    res.json({
      success: true,
      count: jobs.length,
      data: jobs,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// Get job applicants
export const getJobApplicants = async (req, res) => {
  try {
    const candidates = await Candidate.find({
      "applications.jobId": req.params.id,
    }).select("-applications");

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

// Apply to a job
export const applyToJob = async (req, res) => {
  try {
    console.log('\n📝 APPLICATION REQUEST');
    console.log('Job ID:', req.params.id);
    console.log('User:', req.user.email);
    console.log('Request Body:', JSON.stringify(req.body, null, 2));

    const jobId = req.params.id;
    const userId = req.user.id;
    const userEmail = req.user.email;

    // Validate required basic information
    const { fullName, phoneNumber, region, address, expectedSalary, customAnswers } = req.body;

    if (!fullName || !phoneNumber || !region || !address || expectedSalary === undefined) {
      console.log('❌ Missing required fields');
      return res.status(400).json({
        success: false,
        message: "جميع الحقول الأساسية مطلوبة (الاسم، التليفون، المنطقة، العنوان، السالري المتوقع)",
      });
    }

    // Find the job
    const job = await Job.findById(jobId);
    if (!job) {
      return res.status(404).json({
        success: false,
        message: "الوظيفة غير موجودة",
      });
    }

    // Find or create candidate profile
    let candidate = await Candidate.findOne({ email: userEmail });

    if (!candidate) {
      // Create basic candidate profile if doesn't exist
      candidate = await Candidate.create({
        email: userEmail,
        name: req.user.name || fullName,
        applications: [],
      });
    }

    // Check if already applied
    const existingApplication = await Application.findOne({
      jobId: jobId,
      candidateId: candidate._id,
    });

    if (existingApplication) {
      return res.status(400).json({
        success: false,
        message: "لقد تقدمت بالفعل على هذه الوظيفة",
      });
    }

    // Validate custom answers if job has custom questions
    const customAnswersArray = customAnswers || [];
    if (job.customQuestions && job.customQuestions.length > 0) {
      if (customAnswersArray.length !== job.customQuestions.length) {
        return res.status(400).json({
          success: false,
          message: `يرجى الإجابة على جميع الأسئلة (${job.customQuestions.length} أسئلة)`,
        });
      }
    }

    // Create application with all information
    console.log('✅ Creating application...');
    const application = await Application.create({
      jobId: jobId,
      candidateId: candidate._id,
      basicInfo: {
        fullName,
        phoneNumber,
        region,
        address,
        expectedSalary: Number(expectedSalary),
      },
      customAnswers: customAnswersArray,
      status: "Pending",
    });
    console.log('✅ Application created:', application._id);

    // Also add to job's applicants list (for backward compatibility)
    job.applicants = job.applicants || [];
    job.applicants.push({
      candidateId: candidate._id,
      appliedAt: new Date(),
      status: "Pending",
    });
    job.applicantsCount = job.applicants.length;
    await job.save();

    // Add to candidate applications
    candidate.applications = candidate.applications || [];
    candidate.applications.push({
      jobId: jobId,
      appliedAt: new Date(),
      status: "Applied", // Changed from "Pending" to match Candidate schema
    });
    await candidate.save();

    res.json({
      success: true,
      message: "تم التقديم بنجاح!",
      data: {
        applicationId: application._id,
        jobId: jobId,
        jobTitle: job.title,
        appliedAt: application.appliedAt,
      },
    });
  } catch (error) {
    console.error('❌ Apply to Job Error:', error);
    console.error('Error details:', error.message);
    console.error('Stack:', error.stack);
    res.status(500).json({
      success: false,
      message: "خطأ في الخادم",
      error: error.message,
    });
  }
};

// Cancel application
export const cancelApplication = async (req, res) => {
  try {
    console.log('\n🗑️ CANCEL APPLICATION REQUEST');
    console.log('Job ID:', req.params.id);
    console.log('User:', req.user.email);

    const jobId = req.params.id;
    const userEmail = req.user.email;

    // Find candidate
    const candidate = await Candidate.findOne({ email: userEmail });
    if (!candidate) {
      return res.status(404).json({
        success: false,
        message: "الملف الشخصي غير موجود",
      });
    }

    // Find application
    const application = await Application.findOne({
      jobId: jobId,
      candidateId: candidate._id,
    });

    if (!application) {
      return res.status(404).json({
        success: false,
        message: "لم يتم العثور على طلب التقديم",
      });
    }

    // Delete application
    await Application.findByIdAndDelete(application._id);

    // Remove from job's applicants list
    const job = await Job.findById(jobId);
    if (job) {
      job.applicants = job.applicants.filter(
        (app) => app.candidateId.toString() !== candidate._id.toString()
      );
      job.applicantsCount = job.applicants.length;
      await job.save();
    }

    // Remove from candidate applications
    candidate.applications = candidate.applications.filter(
      (app) => app.jobId.toString() !== jobId
    );
    await candidate.save();

    console.log('✅ Application cancelled successfully');
    res.json({
      success: true,
      message: "تم إلغاء التقديم بنجاح",
    });
  } catch (error) {
    console.error('❌ Cancel Application Error:', error);
    res.status(500).json({
      success: false,
      message: "خطأ في الخادم",
      error: error.message,
    });
  }
};
