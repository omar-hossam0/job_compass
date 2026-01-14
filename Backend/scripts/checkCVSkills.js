import mongoose from "mongoose";
import Candidate from "../models/Candidate.js";

mongoose.connect("mongodb://localhost:27017/cv_project_db").then(async () => {
    const candidate = await Candidate.findOne({ email: "baraawael7901@gmail.com" });
    const cv = candidate.resumeText.toLowerCase();

    console.log('\n=== Checking CV for Missing Skills ===\n');

    const missingSkills = [
        'postgresql',
        'backup',
        'backup management',
        'performance tuning',
        'data security',
        'error handling',
        'rest api design'
    ];

    missingSkills.forEach(skill => {
        const found = cv.includes(skill);
        console.log(`${found ? '✅' : '❌'} ${skill}`);
    });

    console.log('\n=== CV Keywords Found ===\n');
    const keywords = ['performance', 'optimization', 'security', 'backup', 'error', 'rest', 'api', 'design'];
    keywords.forEach(kw => {
        if (cv.includes(kw)) {
            console.log(`✅ ${kw}`);
        }
    });

    process.exit(0);
}).catch(err => {
    console.error(err);
    process.exit(1);
});
