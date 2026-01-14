import mongoose from "mongoose";
import dotenv from "dotenv";
import Job from "../models/Job.js";

dotenv.config();

const checkJobStatus = async () => {
    try {
        const mongoUri = process.env.MONGO_URI || "mongodb://localhost:27017/cv_project_db";
        await mongoose.connect(mongoUri);
        console.log("✅ Connected to MongoDB\n");

        // Get the latest job
        const latestJob = await Job.findOne().sort({ createdAt: -1 });

        if (!latestJob) {
            console.log("❌ No jobs found in database");
            process.exit(0);
        }

        console.log("📋 Latest Job Details:");
        console.log("=".repeat(80));
        console.log(`Title: ${latestJob.title}`);
        console.log(`ID: ${latestJob._id}`);
        console.log(`Status: ${latestJob.status}`);
        console.log(`Posted By: ${latestJob.postedBy}`);
        console.log(`Company: ${latestJob.company || 'N/A'}`);
        console.log(`Location: ${latestJob.location || 'N/A'}`);
        console.log(`Job Type: ${latestJob.jobType || 'N/A'}`);
        console.log(`Created At: ${latestJob.createdAt}`);
        console.log(`Description: ${latestJob.description?.substring(0, 100)}...`);
        console.log(`Required Skills: ${latestJob.requiredSkills?.join(', ') || 'N/A'}`);
        console.log(`Custom Questions (${latestJob.customQuestions?.length || 0}):`);
        if (latestJob.customQuestions && latestJob.customQuestions.length > 0) {
            latestJob.customQuestions.forEach((q, i) => {
                console.log(`  ${i + 1}. ${q}`);
            });
        } else {
            console.log("  (None)");
        }
        console.log("=".repeat(80));

        // Check if job is visible to employees
        console.log("\n🔍 Visibility Check:");
        if (latestJob.status === "Active") {
            console.log("✅ Job status is 'Active' - should be visible to employees");
        } else {
            console.log(`⚠️ Job status is '${latestJob.status}' - NOT visible to employees`);
            console.log("💡 Only jobs with status 'Active' are visible to employees");
        }

        process.exit(0);
    } catch (error) {
        console.error("❌ Error:", error);
        process.exit(1);
    }
};

checkJobStatus();
