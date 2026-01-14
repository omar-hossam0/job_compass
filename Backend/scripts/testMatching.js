import mongoose from "mongoose";
import Job from "../models/Job.js";
import Candidate from "../models/Candidate.js";

mongoose.connect("mongodb://localhost:27017/cv_project_db").then(async () => {
    const candidate = await Candidate.findOne({ email: "baraawael7901@gmail.com" });
    const jobs = await Job.find({ status: "Active" });

    console.log("\n=== CV SKILLS ===");
    console.log(candidate.skills.join(", "));

    console.log("\n=== CV TEXT (lowercase) ===");
    const cvLower = candidate.resumeText.toLowerCase();
    console.log(cvLower.substring(0, 500) + "...");

    console.log("\n=== TESTING MATCHES ===\n");

    jobs.forEach(job => {
        console.log(`\n📋 ${job.title}`);
        console.log(`Required Skills: ${job.requiredSkills.join(", ")}`);

        let found = [];
        let notFound = [];

        job.requiredSkills.forEach(skill => {
            const skillLower = skill.toLowerCase();
            let matched = false;

            // Create variants
            const variants = new Set([skillLower]);

            // .js framework names
            if (skillLower.includes(".js")) {
                const base = skillLower.replace(/\.js$/, "");
                variants.add(base);
                variants.add(base + "js");
            } else if (skillLower.endsWith("js") && skillLower.length > 2) {
                const base = skillLower.slice(0, -2);
                variants.add(base + ".js");
                variants.add(base);
            }

            // Slash-separated
            if (skillLower.includes("/")) {
                skillLower.split("/").forEach(part => variants.add(part.trim()));
            }

            // Space-separated ONLY for known technical terms
            const technicalAcronyms = ['rest api', 'tcp/ip', 'lan/wan', 'rest apis'];
            if (technicalAcronyms.includes(skillLower)) {
                skillLower.split(" ").forEach(word => {
                    if (word.length >= 3) variants.add(word);
                });
            }

            // Check all variants
            for (const variant of variants) {
                if (cvLower.includes(variant)) {
                    found.push(`${skill} (matched via "${variant}")`);
                    matched = true;
                    break;
                }
            }

            if (!matched) {
                notFound.push(skill);
            }
        });

        const score = Math.round((found.length / job.requiredSkills.length) * 100);
        console.log(`\n✅ Matched (${found.length}/${job.requiredSkills.length}):`);
        found.forEach(s => console.log(`   - ${s}`));

        if (notFound.length > 0) {
            console.log(`\n❌ Not Found (${notFound.length}):`);
            notFound.forEach(s => console.log(`   - ${s}`));
        }

        console.log(`\n📊 Match Score: ${score}%`);
        console.log("─".repeat(60));
    });

    process.exit(0);
}).catch(err => {
    console.error("Error:", err);
    process.exit(1);
});
