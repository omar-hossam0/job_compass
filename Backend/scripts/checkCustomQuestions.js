import mongoose from "mongoose";
import dotenv from "dotenv";
import Job from "../models/Job.js";

dotenv.config();

const checkCustomQuestions = async () => {
    try {
        // Connect to MongoDB
        const mongoUri = process.env.MONGO_URI || "mongodb://localhost:27017/cv_project_db";
        await mongoose.connect(mongoUri);
        console.log("✅ Connected to MongoDB");

        // Get all jobs
        const jobs = await Job.find().select(
            "title customQuestions createdAt"
        ).sort({ createdAt: -1 }).limit(10);

        console.log("\n📋 Last 10 Jobs with Custom Questions:\n");
        console.log("=".repeat(80));

        jobs.forEach((job, index) => {
            console.log(`\n${index + 1}. Job: ${job.title}`);
            console.log(`   ID: ${job._id}`);
            console.log(`   Created: ${job.createdAt}`);
            console.log(`   Custom Questions (${job.customQuestions?.length || 0}):`);

            if (job.customQuestions && job.customQuestions.length > 0) {
                job.customQuestions.forEach((q, i) => {
                    console.log(`      ${i + 1}. ${q}`);
                });
            } else {
                console.log(`      (No custom questions)`);
            }
            console.log("   " + "-".repeat(76));
        });

        console.log("\n" + "=".repeat(80));
        console.log(`\n✅ Total jobs checked: ${jobs.length}`);

        const jobsWithQuestions = jobs.filter(
            j => j.customQuestions && j.customQuestions.length > 0
        );
        console.log(`📊 Jobs with custom questions: ${jobsWithQuestions.length}`);
        console.log(`📊 Jobs without custom questions: ${jobs.length - jobsWithQuestions.length}`);

        process.exit(0);
    } catch (error) {
        console.error("❌ Error:", error);
        process.exit(1);
    }
};

checkCustomQuestions();
