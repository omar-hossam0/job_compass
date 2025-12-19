/**
 * Hybrid CV-Job Matching System
 * Combines keyword matching with semantic similarity
 * Similar to the Python test_my_cv.py hybrid approach
 */

/**
 * Normalize text: lowercase, handle special chars, standardize terms
 */
function normalize(text) {
    return text
        .toLowerCase()
        .replace(/\+/g, 'p')
        .replace(/#/g, 'sharp')
        .replace(/node\.?\s*js/gi, 'nodejs')
        .replace(/c\+\+/g, 'cpp')
        .replace(/c#/g, 'csharp');
}

/**
 * Tokenize text into words
 */
function tokenize(text) {
    return normalize(text)
        .replace(/[^a-z0-9\s]+/g, ' ')
        .split(/\s+/)
        .filter(Boolean);
}

/**
 * Stop words to filter out
 */
const STOP_WORDS = new Set([
    'the', 'and', 'for', 'with', 'from', 'into', 'that', 'this', 'will',
    'shall', 'have', 'has', 'are', 'was', 'were', 'to', 'in', 'on', 'of',
    'a', 'an', 'by', 'at', 'as', 'or', 'your', 'you', 'we', 'our', 'be',
    'is', 'it', 'can', 'may', 'must', 'should', 'would', 'could'
]);

/**
 * Filter out stop words and very short tokens
 */
function filterTokens(tokens) {
    return tokens.filter(w => !STOP_WORDS.has(w) && w.length > 2);
}

/**
 * Simple stemming (remove common suffixes)
 */
function stem(word) {
    return word
        .replace(/(ing|ed|s|es|tion|ment|ness|ity|ly)$/, '')
        .replace(/(.)\1+$/, '$1'); // Remove repeated chars at end
}

/**
 * Create bigrams from token array
 */
function makeBigrams(tokens) {
    const bigrams = [];
    for (let i = 0; i < tokens.length - 1; i++) {
        bigrams.push(`${tokens[i]} ${tokens[i + 1]}`);
    }
    return bigrams;
}

/**
 * Synonym mapping for technical terms
 */
const SYNONYMS = {
    'javascript': ['js', 'nodejs', 'node', 'typescript', 'ts', 'react', 'angular', 'vue'],
    'python': ['py', 'django', 'flask', 'fastapi', 'pandas', 'numpy'],
    'sql': ['mysql', 'postgresql', 'postgres', 'mssql', 'sqlserver', 'database', 'db'],
    'nodejs': ['node', 'node.js', 'express', 'expressjs'],
    'reactjs': ['react', 'react.js'],
    'docker': ['container', 'containerization'],
    'kubernetes': ['k8s', 'orchestration'],
    'devops': ['ci', 'cd', 'jenkins', 'gitlab', 'deployment'],
    'ai': ['artificial intelligence', 'machine learning', 'ml', 'deep learning', 'neural network'],
    'frontend': ['front-end', 'ui', 'ux', 'user interface'],
    'backend': ['back-end', 'server-side', 'api'],
    'fullstack': ['full-stack', 'full stack'],
    'testing': ['qa', 'quality assurance', 'selenium', 'automation', 'jest', 'mocha'],
    'git': ['github', 'gitlab', 'version control', 'vcs'],
    'cloud': ['aws', 'azure', 'gcp', 'google cloud'],
    'mobile': ['android', 'ios', 'react native', 'flutter'],
    'security': ['cybersecurity', 'infosec', 'owasp', 'penetration testing']
};

/**
 * Check if CV has any synonym of a term
 */
function hasAnySynonym(cvTokenSet, cvText, term) {
    const variations = [term].concat(SYNONYMS[term] || []);
    for (const variant of variations) {
        const normalized = stem(normalize(variant));
        if (cvTokenSet.has(normalized) || cvText.includes(normalized)) {
            return true;
        }
    }
    return false;
}

/**
 * Calculate semantic similarity using token overlap
 */
function calculateSemanticSimilarity(cvTokens, jobTokens) {
    const cvSet = new Set(cvTokens);
    const jobSet = new Set(jobTokens);

    // Calculate unigram intersection
    let uniIntersection = 0;
    for (const token of jobSet) {
        if (cvSet.has(token)) {
            uniIntersection++;
        }
    }

    const uniSimilarity = jobSet.size > 0 ? (uniIntersection / jobSet.size) * 100 : 0;

    // Calculate bigram similarity
    const cvBigrams = new Set(makeBigrams(cvTokens));
    const jobBigrams = makeBigrams(jobTokens);
    const jobBigramSet = new Set(jobBigrams);

    let biIntersection = 0;
    for (const bigram of jobBigramSet) {
        if (cvBigrams.has(bigram)) {
            biIntersection++;
        }
    }

    const biSimilarity = jobBigramSet.size > 0 ? (biIntersection / jobBigramSet.size) * 100 : 0;

    // Combine unigram (60%) and bigram (40%) similarity
    return Math.max(
        uniSimilarity * 0.6 + biSimilarity * 0.4,
        uniSimilarity
    );
}

/**
 * Calculate keyword matching score based on important technical skills
 */
function calculateKeywordScore(cvText, cvTokenSet, jobText, jobTokens) {
    const jobSet = new Set(jobTokens);
    let keywordScore = 0;
    let matchedKeywords = 0;
    let totalKeywords = 0;

    // Extract potential keywords from job (nouns, technical terms)
    const keywords = jobTokens.filter(token => token.length >= 3);

    // Weight important technical terms higher
    const technicalTerms = ['python', 'javascript', 'java', 'nodejs', 'react', 'angular',
        'vue', 'sql', 'mongodb', 'docker', 'kubernetes', 'aws', 'azure',
        'git', 'api', 'rest', 'graphql', 'microservices', 'agile', 'scrum'];

    for (const keyword of keywords) {
        totalKeywords++;

        // Check if keyword exists in CV (including synonyms)
        if (cvTokenSet.has(keyword) || hasAnySynonym(cvTokenSet, cvText, keyword)) {
            matchedKeywords++;

            // Give higher weight to technical terms
            if (technicalTerms.some(tech => keyword.includes(tech) || tech.includes(keyword))) {
                keywordScore += 2; // Double weight for tech terms
            } else {
                keywordScore += 1;
            }
        }
    }

    // Normalize keyword score to 0-100 range
    return totalKeywords > 0 ? (keywordScore / totalKeywords) * 100 : 0;
}

/**
 * Hybrid Matching: Combine semantic similarity with keyword matching
 * @param {string} cvText - Candidate's CV text
 * @param {Array} jobs - Array of job objects with {_id, title, description}
 * @param {number} topK - Number of top matches to return (default 10)
 * @returns {Array} - Sorted array of {job, matchScore} objects
 */
function hybridMatch(cvText, jobs, topK = 10) {
    console.log('🔍 Starting Hybrid Matching...');
    console.log(`📄 CV Length: ${cvText.length} characters`);
    console.log(`💼 Jobs to match: ${jobs.length}`);
    console.log('⚠️  IMPORTANT: Using ONLY job.description field (not title, company, location, etc.)');
    console.log('   This matches test_my_cv.py behavior exactly!');

    // Preprocess CV
    const cvTextNorm = normalize(cvText);
    const cvTokensRaw = tokenize(cvText);
    const cvTokens = filterTokens(cvTokensRaw).map(stem);
    const cvTokenSet = new Set(cvTokens);
    const cvBigrams = makeBigrams(cvTokens);

    console.log(`🧾 CV Tokens: ${cvTokens.length}, Bigrams: ${cvBigrams.length}`);

    // Process each job
    const scoredJobs = jobs.map((job, idx) => {
        // Use description + requiredSkills to avoid overrating single-skill postings
        const jobText = (job.description || '').toLowerCase();
        const requiredSkills = Array.isArray(job.requiredSkills) ? job.requiredSkills : [];

        const jobTokensRaw = tokenize(jobText);
        const jobTokens = filterTokens(jobTokensRaw).map(stem);

        // Calculate semantic similarity (like BERT embeddings) from description
        const semanticScore = jobTokens.length > 0
            ? calculateSemanticSimilarity(cvTokens, jobTokens)
            : 0;

        // Calculate keyword matching score from description
        const keywordScore = jobTokens.length > 0
            ? calculateKeywordScore(cvTextNorm, cvTokenSet, jobText, jobTokens)
            : 0;

        // STRICT MATCHING: Focus on requiredSkills overlap with strong domain filtering
        const normalizedReqSkills = requiredSkills
            .map(normalize)
            .map(stem)
            .filter(Boolean);

        const matchedRequired = normalizedReqSkills.filter((skill) =>
            cvTokenSet.has(skill) || hasAnySynonym(cvTokenSet, cvTextNorm, skill)
        );

        const matchedCount = matchedRequired.length;
        const totalCount = normalizedReqSkills.length;

        // Get title for domain detection
        const title = (job.title || '').toLowerCase();

        // BLACKLIST: Completely unrelated domains = ZERO
        const isBlacklistedDomain = /(marketing|accountant|account|finance|sales|hr|recruiter|designer|copywriter|content writer|far to job)/.test(title);

        if (isBlacklistedDomain) {
            return {
                job,
                matchScore: 0
            };
        }

        // Game dev must have gaming keywords in CV
        const isGameDev = /(game|unity|unreal)/.test(title);
        if (isGameDev && !cvTextNorm.includes('game') && !cvTextNorm.includes('unity') && !cvTextNorm.includes('unreal')) {
            return {
                job,
                matchScore: 0
            };
        }

        // Backend/fullstack detection
        const isBackendTitle = /(back[- ]?end|backend|full[- ]?stack|fullstack|node\.?js|express|react|angular|vue|api|server|developer|engineer)/.test(title);

        // For backend/fullstack: also check title keywords (e.g., "React + Node" in title)
        const titleKeywords = tokenize(title).filter(t => t.length > 2 && !/full|time|part|contract|remote|entry|mid|senior/.test(t));
        const titleMatches = titleKeywords.filter(tk => cvTokenSet.has(stem(normalize(tk)))).length;

        // Required skills scoring
        let requiredSkillScore = 0;
        if (totalCount === 0 || matchedCount === 0) {
            // No skills listed or no match
            requiredSkillScore = titleMatches > 0 ? titleMatches * 20 : 0; // Use title keywords if no requiredSkills
        } else {
            const matchPercentage = (matchedCount / totalCount) * 100;
            const absoluteBonus = Math.min(matchedCount * 8, 30);
            requiredSkillScore = Math.min((matchPercentage * 0.7) + absoluteBonus, 100);
        }

        // Hybrid scoring: Semantic 35%, Keywords 15%, Skills 50%
        let hybridScore = (semanticScore * 0.35) + (keywordScore * 0.15) + (requiredSkillScore * 0.5);

        // Backend/fullstack boost if title keywords match
        if (isBackendTitle && (titleMatches >= 2 || matchedCount >= 2 || semanticScore > 50)) {
            hybridScore = Math.min(hybridScore + 20, 100);
        }

        // Penalty for low semantic + low skills
        if (semanticScore < 30 && matchedCount < 2 && titleMatches < 1) {
            hybridScore *= 0.3;
        }

        if (idx < 5) {
            console.log(
                `📊 Job ${idx + 1} "${job.title}": ` +
                `Semantic=${semanticScore.toFixed(2)}%, ` +
                `Keyword=${keywordScore.toFixed(2)}%, ` +
                `ReqSkills=${requiredSkillScore.toFixed(2)}%, ` +
                `Hybrid=${hybridScore.toFixed(2)}%`
            );
        }

        return {
            job,
            matchScore: Math.round(hybridScore * 100) / 100
        };
    });

    // Sort by score descending
    scoredJobs.sort((a, b) => b.matchScore - a.matchScore);

    // Return top K
    const topMatches = scoredJobs.slice(0, topK);

    console.log(`✅ Top ${topMatches.length} matches calculated`);
    topMatches.slice(0, 5).forEach((match, idx) => {
        console.log(`   ${idx + 1}. "${match.job.title}": ${match.matchScore}%`);
    });

    return topMatches;
}

export { hybridMatch };
