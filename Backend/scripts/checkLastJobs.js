import mongoose from "mongoose";
import Job from "../models/Job.js";

mongoose.connect("mongodb://localhost:27017/cv_project_db").then(async () => {
    const jobs = await Job.find({ status: 'Active' }).sort({ createdAt: -1 }).limit(3).lean();

    console.log('\n=== Last 3 Active Jobs ===\n');
    jobs.forEach((j, i) => {
        console.log(`${i + 1}. ${j.title}`);
        console.log(`   Created: ${j.createdAt}`);
        console.log(`   Skills: ${j.requiredSkills.join(', ')}`);
        console.log(`   Description: ${j.description.substring(0, 100)}...`);
        console.log('');
    });

    process.exit(0);
}).catch(err => {
    console.error(err);
    process.exit(1);
});
