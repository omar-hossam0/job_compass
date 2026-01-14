import mongoose from "mongoose";
import Job from "../models/Job.js";
import Candidate from "../models/Candidate.js";

mongoose.connect("mongodb://localhost:27017/cv_project_db").then(async () => {
    const candidate = await Candidate.findOne({ email: "baraawael7901@gmail.com" });
    const jobs = await Job.find({ status: 'Active' }).sort({ createdAt: -1 }).lean();

    console.log('\n=== ALL ACTIVE JOBS ===');
    console.log(`Total: ${jobs.length} jobs\n`);

    // Simulate the matching algorithm from studentRoutes.js
    const cvLower = candidate.resumeText.toLowerCase();

    const results = jobs.map(job => {
        const skills = job.requiredSkills.map(s => s.toLowerCase());
        let matches = 0;

        skills.forEach(skill => {
            const variants = new Set([skill]);

            // .js variants
            if (skill.includes('.js')) {
                const base = skill.replace(/\.js$/, '');
                variants.add(base);
                variants.add(base + 'js');
            } else if (skill.endsWith('js') && skill.length > 2) {
                const base = skill.slice(0, -2);
                variants.add(base + '.js');
                variants.add(base);
            }

            // Slash-separated
            if (skill.includes('/')) {
                skill.split('/').forEach(part => variants.add(part.trim()));
            }

            // Technical acronyms
            const isCompoundTechnical =
                skill.includes('api') ||
                skill.includes('tcp') ||
                skill.includes('lan') ||
                skill.includes('html') ||
                skill.includes('css') ||
                skill.includes('query') ||
                skill.includes('database') ||
                (skill.includes(' ') && skill.split(' ').length === 2 &&
                    skill.split(' ').every(w => w.length <= 4 && w.match(/^[a-z0-9]+$/)));

            if (skill.includes(' ') && isCompoundTechnical) {
                skill.split(' ').forEach(word => {
                    if (word.length >= 2) variants.add(word);
                });
                variants.add(skill.replace(/\s+/g, ''));
            }

            // For long skills (3+ words), match if CV contains 2 consecutive words
            if (skill.split(' ').length >= 3) {
                const words = skill.split(' ');
                for (let i = 0; i < words.length - 1; i++) {
                    const bigram = words[i] + ' ' + words[i + 1];
                    if (bigram.length >= 6) {
                        variants.add(bigram);
                    }
                }
            }

            // Check variants
            for (const variant of variants) {
                if (!variant || variant.length < 2) continue;

                const escaped = variant.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
                try {
                    const regex = new RegExp(`\\b${escaped}\\b`, 'i');
                    if (regex.test(cvLower)) {
                        matches++;
                        break;
                    }
                } catch (e) {
                    if (cvLower.includes(variant)) {
                        matches++;
                        break;
                    }
                }

                if (variant.length <= 3 && cvLower.includes(variant)) {
                    matches++;
                    break;
                }
            }
        });

        const matchScore = Math.round((matches / skills.length) * 100);
        return {
            title: job.title,
            skills: job.requiredSkills.length,
            matched: matches,
            score: matchScore,
            createdAt: job.createdAt,
            shouldShow: matchScore >= 60
        };
    });

    // Sort by score
    results.sort((a, b) => b.score - a.score);

    console.log('Jobs that SHOULD APPEAR (>= 60%):');
    results.filter(r => r.shouldShow).forEach(r => {
        console.log(`  ✅ ${r.title}: ${r.matched}/${r.skills} = ${r.score}%`);
    });

    console.log('\nJobs that WON\'T APPEAR (< 60%):');
    results.filter(r => !r.shouldShow).forEach(r => {
        console.log(`  ❌ ${r.title}: ${r.matched}/${r.skills} = ${r.score}%`);
    });

    console.log(`\nTotal jobs >= 60%: ${results.filter(r => r.shouldShow).length}`);
    console.log(`Total jobs in database: ${jobs.length}`);

    process.exit(0);
}).catch(err => {
    console.error(err);
    process.exit(1);
});
