import mongoose from "mongoose";
import Job from "../models/Job.js";

async function fixDBAJob() {
  try {
    await mongoose.connect("mongodb://localhost:27017/cv_project_db");
    console.log("✅ Connected to MongoDB\n");

    // Fix Database Administrator
    const dbaJob = await Job.findById("69554fe1492d6624ad65703a");
    if (dbaJob) {
      console.log("📋 Updating Database Administrator (DBA)...");
      console.log("Old Skills:", dbaJob.requiredSkills);
      
      dbaJob.requiredSkills = [
        'SQL',
        'MySQL',
        'PostgreSQL',
        'Database Design',
        'Backup Management',
        'Performance Tuning',
        'Data Security',
        'Query Optimization'
      ];
      
      await dbaJob.save();
      console.log("New Skills:", dbaJob.requiredSkills);
      console.log("✅ Database Administrator updated\n");
    } else {
      console.log("❌ DBA Job not found");
    }

    console.log("✅ Done!");
    process.exit(0);
  } catch (error) {
    console.error("❌ Error:", error);
    process.exit(1);
  }
}

fixDBAJob();
