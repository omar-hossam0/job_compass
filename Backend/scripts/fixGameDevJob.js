import mongoose from "mongoose";
import Job from "../models/Job.js";

async function fixGameDevJob() {
    try {
        await mongoose.connect("mongodb://localhost:27017/cv_project_db");
        console.log("✅ Connected to MongoDB");

        const gameDevJob = await Job.findById("693d523196b2f5fe4d4f8609");

        if (gameDevJob) {
            console.log("\n📋 Original Job:");
            console.log("Title:", gameDevJob.title);
            console.log("Required Skills:", gameDevJob.requiredSkills);

            // Update skills to match the job description
            gameDevJob.requiredSkills = [
                'Unity',
                'C#',
                'Unreal',
                'C++',
                'Game Physics',
                'Animation',
                '3D',
                '2D'
            ];

            await gameDevJob.save();

            console.log("\n✅ Updated Job:");
            console.log("Title:", gameDevJob.title);
            console.log("Required Skills:", gameDevJob.requiredSkills);
        } else {
            console.log("❌ Job not found");
        }

        process.exit(0);
    } catch (error) {
        console.error("❌ Error:", error);
        process.exit(1);
    }
}

fixGameDevJob();
