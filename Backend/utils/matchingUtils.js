/**
 * Shared matching utilities for CV-Job matching
 * Used by both employee and HR endpoints to ensure consistent percentages
 */

// Common tech skills to extract from job descriptions
const KNOWN_SKILLS = [
    // Programming Languages
    "javascript",
    "python",
    "java",
    "c#",
    "c++",
    "php",
    "ruby",
    "go",
    "rust",
    "swift",
    "kotlin",
    "typescript",
    // Frontend
    "react",
    "react.js",
    "reactjs",
    "angular",
    "vue",
    "vue.js",
    "vuejs",
    "html",
    "css",
    "sass",
    "less",
    "bootstrap",
    "tailwind",
    // Backend
    "node",
    "node.js",
    "nodejs",
    "express",
    "express.js",
    "expressjs",
    "django",
    "flask",
    "spring",
    "laravel",
    "rails",
    // Databases
    "mongodb",
    "mysql",
    "postgresql",
    "postgres",
    "sql",
    "redis",
    "firebase",
    "dynamodb",
    "oracle",
    "sqlite",
    // DevOps & Cloud
    "docker",
    "kubernetes",
    "aws",
    "azure",
    "gcp",
    "jenkins",
    "ci/cd",
    "linux",
    "git",
    "github",
    "gitlab",
    // APIs
    "rest",
    "restful",
    "graphql",
    "api",
    "apis",
    "websocket",
    "socket.io",
    // Other
    "jwt",
    "oauth",
    "authentication",
    "authorization",
    "security",
    "testing",
    "agile",
    "scrum",
];

/**
 * Calculate keyword-based match percentage between CV text and job
 * Returns a percentage (0-100) based on how many job skills are found in CV
 * 
 * @param {string} cvText - The CV/resume text content
 * @param {Object} job - Job object with title, description, requiredSkills
 * @returns {number} Match percentage (0-100)
 */
export const calculateKeywordMatch = (cvText, job) => {
    const cvLower = (cvText || "").toLowerCase();

    // Build comprehensive job content from description + title + requiredSkills
    // This ensures identical job content produces identical match scores
    const jobTitle = (job.title || "").toLowerCase();
    const jobDesc = (job.description || "").toLowerCase();
    const jobSkills = (job.requiredSkills || []).map(s => (s || "").toLowerCase()).join(" ");
    const fullJobContent = `${jobTitle} ${jobDesc} ${jobSkills}`;

    // Extract all technical keywords from complete job content
    const allSkills = new Set();

    // Add requiredSkills (explicit skills)
    (job.requiredSkills || []).forEach(skill => {
        if (skill && skill.trim()) allSkills.add(skill.toLowerCase().trim());
    });

    // Extract additional skills from description using KNOWN_SKILLS list
    KNOWN_SKILLS.forEach(knownSkill => {
        if (fullJobContent.includes(knownSkill.toLowerCase())) {
            allSkills.add(knownSkill.toLowerCase());
        }
    });

    // If no skills found, return 0
    if (allSkills.size === 0) {
        console.log(`⚠️ "${job.title}": No skills found in job → 0%`);
        return 0;
    }

    const skills = Array.from(allSkills).sort(); // Sort for consistency
    let exactMatches = 0;
    const matchedSkills = [];
    const missingSkills = [];

    skills.forEach((skill) => {
        // Normalize and create all possible variants for the same skill
        const skillVariants = new Set();

        // Add original skill
        skillVariants.add(skill);

        // Handle .js framework names (node.js, express.js, react.js, etc.)
        if (skill.includes(".js")) {
            const base = skill.replace(/\.js$/i, "");
            skillVariants.add(base); // node.js -> node
            skillVariants.add(base + "js"); // node.js -> nodejs
            skillVariants.add(base + " js"); // node.js -> node js
        } else if (skill.match(/js$/i) && skill.length > 2) {
            const base = skill.replace(/js$/i, "");
            skillVariants.add(base + ".js"); // nodejs -> node.js
            skillVariants.add(base); // nodejs -> node
        }

        // Handle slash-separated skills (MongoDB/MySQL -> match if CV has MongoDB OR MySQL)
        if (skill.includes("/")) {
            const parts = skill.split("/");
            parts.forEach((part) => skillVariants.add(part.trim()));
        }

        // Handle space-separated ONLY for known technical terms and compound phrases
        const isCompoundTechnicalSkill =
            skill.includes("api") || // REST API, REST APIs
            skill.includes("tcp") || // TCP/IP
            skill.includes("lan") || // LAN/WAN
            skill.includes("ci/cd") || // CI/CD
            skill.includes("html") || // HTML, HTML5
            skill.includes("css"); // CSS, CSS3

        if (skill.includes(" ") && isCompoundTechnicalSkill) {
            skill.split(" ").forEach((word) => {
                if (word.length >= 2) skillVariants.add(word);
            });
            skillVariants.add(skill.replace(/\s+/g, ""));
        }

        // Check if CV contains any variant
        const found = Array.from(skillVariants).some((variant) => {
            if (!variant || variant.length < 2) return false;

            const escaped = variant.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");

            try {
                const exactRegex = new RegExp(`\\b${escaped}\\b`, "i");
                if (exactRegex.test(cvLower)) return true;
            } catch (e) {
                if (cvLower.includes(variant)) return true;
            }

            if (variant.length <= 3) {
                return cvLower.includes(variant);
            }

            return false;
        });

        if (found) {
            exactMatches++;
            matchedSkills.push(skill);
        } else {
            missingSkills.push(skill);
        }
    });

    const totalSkills = skills.length;
    if (totalSkills === 0) return 0;

    // Calculate actual percentage match based on skills matched
    const matchPercentage = (exactMatches / totalSkills) * 100;
    const matchScore = Math.round(matchPercentage);

    console.log(
        `📊 "${job.title}": ${exactMatches}/${totalSkills} skills → ${matchScore}%`,
    );
    if (matchedSkills.length > 0)
        console.log(`   ✓ Matched: ${matchedSkills.join(", ")}`);
    if (missingSkills.length > 0 && missingSkills.length <= 5)
        console.log(`   ✗ Missing: ${missingSkills.join(", ")}`);

    return matchScore;
};

/**
 * Extract skills from job description if requiredSkills is empty or too few
 * Merges explicit requiredSkills with skills detected in description/title
 * 
 * @param {Object} job - Job object with title, description, requiredSkills
 * @returns {Array<string>} Array of skill strings (lowercase)
 */
export const extractSkillsFromDescription = (job) => {
    const requiredSkills = job.requiredSkills || [];

    // Always extract from description and merge with required skills
    // This ensures consistency with Python matcher
    const description = (job.description || "").toLowerCase();
    const title = (job.title || "").toLowerCase();
    const combinedText = `${title} ${description}`;

    const extractedSkills = [];

    KNOWN_SKILLS.forEach((skill) => {
        const escaped = skill.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
        const regex = new RegExp(`\\b${escaped}\\b`, "i");
        if (regex.test(combinedText)) {
            // Keep lowercase for consistency with Python matcher
            if (!extractedSkills.includes(skill)) {
                extractedSkills.push(skill);
            }
        }
    });

    // Merge with existing skills (if any)
    const allSkills = [...requiredSkills.map((s) => s.toLowerCase())];
    extractedSkills.forEach((skill) => {
        const skillLower = skill.toLowerCase();
        const exists = allSkills.some((s) => s.toLowerCase() === skillLower);
        if (!exists) {
            allSkills.push(skill);
        }
    });

    if (extractedSkills.length > 0) {
        console.log(
            `🔍 Auto-extracted ${extractedSkills.length} skills for "${job.title}": ${extractedSkills.slice(0, 10).join(", ")}${extractedSkills.length > 10 ? "..." : ""}`,
        );
    }

    console.log(
        `📋 Total skills for matching "${job.title}": ${allSkills.length}`,
    );

    return allSkills;
};

export { KNOWN_SKILLS };
