import mongoose from "mongoose";
import Job from "../models/Job.js";

async function checkAllJobs() {
    try {
        await mongoose.connect("mongodb://localhost:27017/cv_project_db");
        console.log("✅ Connected to MongoDB");

        const jobs = await Job.find({});

        console.log(`\n📊 Found ${jobs.length} active jobs\n`);

        jobs.forEach((job, index) => {
            console.log(`\n${"=".repeat(60)}`);
            console.log(`Job #${index + 1}`);
            console.log(`${"=".repeat(60)}`);
            console.log("ID:", job._id);
            console.log("Title:", job.title);
            console.log("Company:", job.company);
            console.log("Location:", job.location);
            console.log("Required Skills:", job.requiredSkills);
            console.log("Skills Count:", job.requiredSkills?.length || 0);
            console.log("Description (first 200 chars):");
            console.log(job.description?.substring(0, 200));
        });

        process.exit(0);
    } catch (error) {
        console.error("❌ Error:", error);
        process.exit(1);
    }
}

checkAllJobs();
