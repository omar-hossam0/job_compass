import mongoose from "mongoose";
import Candidate from "../models/Candidate.js";
import Job from "../models/Job.js";

const checkCVAndMatching = async () => {
    try {
        const mongoUri = "mongodb://localhost:27017/cv_project_db";
        await mongoose.connect(mongoUri);
        console.log("✅ Connected to MongoDB\n");

        // Get all candidates with CV
        const candidates = await Candidate.find({ resumeText: { $exists: true, $ne: "" } }).limit(3);

        if (candidates.length === 0) {
            console.log("❌ No candidates with CV found");
            process.exit(0);
        }

        // Get active jobs
        const jobs = await Job.find({ status: "Active" }).limit(5);

        console.log("=".repeat(80));
        console.log("📄 CV ANALYSIS AND JOB MATCHING");
        console.log("=".repeat(80));

        for (const candidate of candidates) {
            console.log(`\n👤 Candidate: ${candidate.name || candidate.email}`);
            console.log("-".repeat(60));

            const cvText = candidate.resumeText.toLowerCase();
            const cvLength = cvText.length;

            console.log(`📝 CV Length: ${cvLength} characters`);

            // Extract skills from CV
            const SKILLS = ['javascript', 'typescript', 'python', 'java', 'node.js', 'nodejs', 'react',
                'angular', 'vue', 'mongodb', 'mysql', 'postgresql', 'docker', 'kubernetes', 'aws',
                'azure', 'gcp', 'linux', 'git', 'ci/cd', 'jenkins', 'devops', 'backend', 'frontend',
                'express', 'django', 'flask', 'spring', 'api', 'rest', 'graphql', 'html', 'css',
                'c++', 'c#', 'php', 'ruby', 'go', 'rust', 'swift', 'kotlin', 'flutter', 'react native'];

            const foundSkills = SKILLS.filter(skill => {
                const escaped = skill.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
                try {
                    const regex = new RegExp(`\\b${escaped}\\b`, 'i');
                    return regex.test(cvText);
                } catch {
                    return cvText.includes(skill);
                }
            });

            console.log(`🔧 Skills found in CV: ${foundSkills.join(', ') || 'None detected'}`);

            // Show first 500 chars of CV
            console.log(`\n📄 CV Preview (first 500 chars):`);
            console.log(cvText.substring(0, 500) + "...");

            console.log("\n📊 Job Matching Analysis:");
            console.log("-".repeat(40));

            for (const job of jobs) {
                const jobSkills = (job.requiredSkills || []).map(s => s.toLowerCase());
                const jobTitle = job.title;

                // Count exact matches
                let exactMatches = 0;
                const matchedSkills = [];
                const missingSkills = [];

                jobSkills.forEach(skill => {
                    const skillVariants = [skill];
                    if (skill.includes('.js')) skillVariants.push(skill.replace('.js', ''), skill.replace('.js', 'js'));
                    if (skill.includes('js') && !skill.includes('.js')) skillVariants.push(skill.replace('js', '.js'));

                    const found = skillVariants.some(v => {
                        const escaped = v.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
                        try {
                            return new RegExp(`\\b${escaped}\\b`, 'i').test(cvText);
                        } catch {
                            return cvText.includes(v);
                        }
                    });

                    if (found) {
                        exactMatches++;
                        matchedSkills.push(skill);
                    } else {
                        missingSkills.push(skill);
                    }
                });

                const matchPercent = jobSkills.length > 0 ? Math.round((exactMatches / jobSkills.length) * 100) : 0;

                console.log(`\n📌 ${jobTitle}`);
                console.log(`   Required Skills: ${jobSkills.join(', ') || 'None specified'}`);
                console.log(`   ✓ Matched (${matchedSkills.length}): ${matchedSkills.join(', ') || 'None'}`);
                console.log(`   ✗ Missing (${missingSkills.length}): ${missingSkills.join(', ') || 'None'}`);
                console.log(`   📊 Match Score: ${matchPercent}% (${exactMatches}/${jobSkills.length})`);
            }

            console.log("\n" + "=".repeat(80));
        }

        process.exit(0);
    } catch (error) {
        console.error("❌ Error:", error);
        process.exit(1);
    }
};

checkCVAndMatching();
