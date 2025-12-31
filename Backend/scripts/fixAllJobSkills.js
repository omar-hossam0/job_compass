import mongoose from "mongoose";
import Job from "../models/Job.js";

async function fixAllJobs() {
    try {
        await mongoose.connect("mongodb://localhost:27017/cv_project_db");
        console.log("✅ Connected to MongoDB\n");

        // Fix Network Engineer
        const networkJob = await Job.findById("6952ce1f31bd1aed320be0dc");
        if (networkJob) {
            console.log("📋 Updating Network Engineer...");
            console.log("Old Skills:", networkJob.requiredSkills);

            networkJob.requiredSkills = [
                'Cisco',
                'Routing',
                'Switching',
                'VPN',
                'Firewalls',
                'Network Security',
                'TCP/IP',
                'LAN/WAN'
            ];

            await networkJob.save();
            console.log("New Skills:", networkJob.requiredSkills);
            console.log("✅ Network Engineer updated\n");
        }

        // Fix Full Stack Developer
        const fullStackJob = await Job.findById("692f785b75c065ced2691c65");
        if (fullStackJob) {
            console.log("📋 Updating Full Stack Developer...");
            console.log("Old Skills:", fullStackJob.requiredSkills);

            fullStackJob.requiredSkills = [
                'React.js',
                'Node.js',
                'Express',
                'MySQL',
                'MongoDB',
                'REST APIs',
                'Git',
                'Docker',
                'JavaScript',
                'HTML',
                'CSS'
            ];

            await fullStackJob.save();
            console.log("New Skills:", fullStackJob.requiredSkills);
            console.log("✅ Full Stack Developer updated\n");
        }

        console.log("✅ All jobs updated successfully!");
        process.exit(0);
    } catch (error) {
        console.error("❌ Error:", error);
        process.exit(1);
    }
}

fixAllJobs();
