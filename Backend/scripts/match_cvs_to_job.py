"""
Job-to-CVs Matching System - Enhanced with Hybrid Weighted Scoring
Finds best matching CVs for a given job description using:
1. TF-IDF cosine similarity (semantic matching)
2. Critical technical keywords boost (skill-based matching)
3. Weighted hybrid scoring for accurate results
"""

import sys
import json
import os
import re
from collections import Counter
import math

def tokenize(text):
    """Tokenize and clean text"""
    # Convert to lowercase
    text = text.lower()
    # Extract words (alphanumeric + some special chars)
    words = re.findall(r'\b[\w\+\#]+\b', text)
    
    # Remove very common words (stop words)
    stop_words = {
        'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 
        'of', 'with', 'by', 'from', 'as', 'is', 'was', 'are', 'were', 'be',
        'been', 'being', 'have', 'has', 'had', 'do', 'does', 'did', 'will',
        'would', 'should', 'could', 'can', 'may', 'might', 'must', 'this',
        'that', 'these', 'those', 'i', 'you', 'he', 'she', 'it', 'we', 'they',
        'am', 'your', 'my', 'our', 'their'
    }
    
    return [w for w in words if w not in stop_words and len(w) > 2]


def extract_critical_skills_from_job(job_text):
    """
    Enhanced extraction of critical technical skills AND important phrases from job description
    Returns list of important keywords and phrases
    """
    job_lower = job_text.lower()
    
    # Comprehensive technical skills database (expanded)
    all_skills = {
        # Programming Languages
        'python', 'javascript', 'java', 'c++', 'c#', 'csharp', 'php', 'ruby', 
        'swift', 'kotlin', 'go', 'golang', 'rust', 'typescript', 'scala',
        'perl', 'r', 'matlab', 'dart', 'flutter', 'objective-c', 'vb.net',
        
        # Web Technologies
        'html', 'html5', 'css', 'css3', 'react', 'reactjs', 'angular', 'vue', 
        'vuejs', 'nodejs', 'node.js', 'express', 'expressjs', 'django', 'flask', 
        'fastapi', 'spring', 'springboot', 'asp.net', 'laravel', 'symfony',
        'next.js', 'nextjs', 'nuxt', 'gatsby', 'jquery', 'bootstrap', 'tailwind',
        'webpack', 'babel', 'sass', 'less', 'redux', 'mobx', 'graphql',
        
        # Databases
        'sql', 'mysql', 'postgresql', 'postgres', 'mongodb', 'redis', 'oracle', 
        'sqlite', 'mariadb', 'cassandra', 'dynamodb', 'firebase', 'firestore', 
        'elasticsearch', 'neo4j', 'couchdb', 'mssql', 'db2', 'nosql',
        
        # Cloud & DevOps
        'aws', 'azure', 'gcp', 'cloud', 'docker', 'kubernetes', 'k8s', 'jenkins', 
        'ci/cd', 'terraform', 'ansible', 'git', 'github', 'gitlab', 'bitbucket',
        'linux', 'unix', 'bash', 'shell', 'nginx', 'apache', 'devops',
        
        # Backend & APIs
        'rest', 'restful', 'api', 'apis', 'graphql', 'microservices', 
        'websocket', 'grpc', 'soap', 'json', 'xml', 'authentication', 'jwt',
        
        # Mobile Development
        'android', 'ios', 'mobile', 'react-native', 'flutter', 'xamarin', 'ionic',
        'swift', 'kotlin', 'cordova',
        
        # Data Science & ML
        'machine-learning', 'ml', 'deep-learning', 'dl', 'ai', 'tensorflow', 
        'pytorch', 'keras', 'scikit-learn', 'sklearn', 'pandas', 'numpy', 
        'jupyter', 'data-science', 'nlp', 'computer-vision', 'artificial-intelligence',
        'data-analysis', 'statistics', 'analytics',
        
        # General Skills
        'developer', 'development', 'programming', 'coding', 'software',
        'engineer', 'engineering', 'backend', 'back-end', 'frontend', 'front-end',
        'fullstack', 'full-stack', 'architecture', 'design-patterns', 'design',
        'testing', 'debugging', 'agile', 'scrum', 'tdd', 'bdd', 'unit-testing',
        'oop', 'functional', 'async', 'multithreading', 'performance', 'optimization',
        'security', 'scalability', 'deployment', 'monitoring', 'troubleshooting',
        
        # Additional important terms
        'experience', 'senior', 'junior', 'lead', 'team', 'project', 'problem-solving',
        'communication', 'collaboration', 'leadership', 'management'
    }
    
    # Find which skills are mentioned in the job description
    critical_skills = []
    skill_positions = {}  # Track position of first occurrence for weighting
    
    for skill in all_skills:
        # Use word boundaries to match whole words
        pattern = r'\b' + re.escape(skill.replace('-', r'[-\s]?')) + r'\b'
        match = re.search(pattern, job_lower)
        if match:
            critical_skills.append(skill)
            skill_positions[skill] = match.start()
    
    # Sort by position (skills mentioned earlier are often more important)
    critical_skills.sort(key=lambda x: skill_positions.get(x, 999999))
    
    # Also extract bigrams (two-word phrases) from job description for better matching
    tokens = tokenize(job_text)
    if len(tokens) > 1:
        bigrams = [f"{tokens[i]} {tokens[i+1]}" for i in range(len(tokens)-1)]
        # Add most common bigrams
        from collections import Counter
        common_bigrams = [bg for bg, count in Counter(bigrams).most_common(10)]
        # Only add bigrams that aren't already covered by skills
        for bg in common_bigrams:
            if bg not in ' '.join(critical_skills):
                critical_skills.append(bg)
    
    return critical_skills


def calculate_keyword_boost(cv_text, critical_skills, max_boost=50.0):
    """
    Calculate keyword boost score based on critical skills presence
    Returns a score between 0 and max_boost (default 50%)
    Enhanced to give higher scores for good matches
    """
    if not critical_skills:
        return 0.0
        
    cv_lower = cv_text.lower()
    matched_skills = 0
    skill_weights = {}
    
    # Weight skills by their importance (earlier = more important)
    for idx, skill in enumerate(critical_skills[:20]):  # Top 20 skills
        weight = 1.0 + (0.5 * (20 - idx) / 20)  # 1.0 to 1.5 weight
        skill_weights[skill] = weight
    
    total_weight = 0
    matched_weight = 0
    
    for skill in critical_skills:
        weight = skill_weights.get(skill, 1.0)
        total_weight += weight
        
        # Check if skill appears in CV
        pattern = r'\b' + re.escape(skill.replace('-', r'[-\s]?')) + r'\b'
        if re.search(pattern, cv_lower):
            matched_skills += 1
            matched_weight += weight
    
    # Calculate boost with enhanced scoring
    if total_weight > 0:
        match_ratio = matched_weight / total_weight
        # Apply power curve to boost high matches
        boosted_ratio = math.pow(match_ratio, 0.85)  # Softer curve for better scores
        boost_score = boosted_ratio * max_boost
    else:
        boost_score = 0.0
    
    return boost_score


def calculate_tf_idf(documents):
    """
    Calculate TF-IDF for documents
    Returns: list of dictionaries {term: tfidf_score}
    """
    n_docs = len(documents)
    
    # Calculate document frequency for each term
    df = {}
    for doc in documents:
        tokens = tokenize(doc)
        unique_tokens = set(tokens)
        for token in unique_tokens:
            df[token] = df.get(token, 0) + 1
    
    # Calculate TF-IDF for each document
    tfidf_docs = []
    for doc in documents:
        tokens = tokenize(doc)
        token_counts = Counter(tokens)
        doc_length = len(tokens)
        
        tfidf = {}
        for token, count in token_counts.items():
            # TF: term frequency
            tf = count / doc_length if doc_length > 0 else 0
            # IDF: inverse document frequency
            idf = math.log(n_docs / df[token]) if df[token] > 0 else 0
            tfidf[token] = tf * idf
        
        tfidf_docs.append(tfidf)
    
    return tfidf_docs


def cosine_similarity_simple(text1, text2):
    """Calculate cosine similarity using term frequencies"""
    tokens1 = tokenize(text1)
    tokens2 = tokenize(text2)
    
    if not tokens1 or not tokens2:
        return 0.0
    
    # Count term frequencies  
    freq1 = Counter(tokens1)
    freq2 = Counter(tokens2)
    
    # Get all unique terms
    all_terms = set(freq1.keys()) | set(freq2.keys())
    
    # Calculate dot product and magnitudes
    dot_product = sum(freq1.get(term, 0) * freq2.get(term, 0) for term in all_terms)
    magnitude1 = math.sqrt(sum(val**2 for val in freq1.values()))
    magnitude2 = math.sqrt(sum(val**2 for val in freq2.values()))
    
    if magnitude1 == 0 or magnitude2 == 0:
        return 0.0
    
    return dot_product / (magnitude1 * magnitude2)


def match_cv_to_job_hybrid(cv_text, job_text, critical_skills):
    """
    Enhanced CV-Job matching using Hybrid Weighted Scoring:
    1. Calculate semantic similarity (TF-IDF cosine similarity) - base score (50%)
    2. Calculate keyword boost (critical skills matching) - bonus score (50%)
    3. Apply experience boost for strong matches
    4. Normalize final score to ensure it's between 0-100%
    
    Returns similarity score (0-100)
    """
    # 1. Semantic similarity (0-1 range, then scale to 0-50%)
    semantic_similarity = cosine_similarity_simple(cv_text, job_text)
    # Apply softer scaling to boost scores
    semantic_score = math.pow(semantic_similarity, 0.8) * 50.0  # Max 50%
    
    # 2. Keyword boost based on critical skills (0-50%)
    keyword_boost = calculate_keyword_boost(cv_text, critical_skills, max_boost=50.0)
    
    # 3. Base hybrid score (50% semantic + 50% keywords)
    base_score = semantic_score + keyword_boost
    
    # 4. Apply bonus for strong matches (if both scores are good)
    if semantic_score > 25 and keyword_boost > 25:
        # Strong match bonus: up to 10% extra
        bonus = min(10.0, (semantic_score - 25) * 0.2 + (keyword_boost - 25) * 0.2)
        base_score += bonus
    
    # 5. Ensure score is within valid range (0-100)
    final_score = max(0.0, min(100.0, base_score))
    
    return final_score


def main():
    """
    Main execution: read job + CVs from stdin, return top matches as JSON
    Enhanced with Hybrid Weighted Scoring for accurate matching
    """
    try:
        # Read input from stdin
        input_data = json.loads(sys.stdin.read())
        
        job_description = input_data.get('job_description', '')
        cv_texts = input_data.get('cv_texts', [])
        top_k = input_data.get('top_k', 10)
        
        if not job_description:
            raise ValueError("Missing job_description")
        
        if not cv_texts:
            raise ValueError("Missing cv_texts")
        
        print(f"🔍 Matching {len(cv_texts)} CVs using Hybrid Weighted Scoring...", file=sys.stderr, flush=True)
        
        # Step 1: Extract critical skills from job description
        critical_skills = extract_critical_skills_from_job(job_description)
        print(f"🎯 Found {len(critical_skills)} critical skills in job description", file=sys.stderr, flush=True)
        if critical_skills:
            print(f"   Top skills: {', '.join(critical_skills[:10])}", file=sys.stderr, flush=True)
        
        # Step 2: Match each CV to the job using hybrid scoring
        all_matches = []
        
        for cv_index, cv_text in enumerate(cv_texts):
            # Calculate semantic similarity (50% weight)
            semantic_sim = calculate_semantic_similarity(job_description, cv_text)
            semantic_score = math.pow(semantic_sim, 0.8) * 50.0
            
            # Calculate keyword boost with weighted matching (50% weight)
            cv_lower = cv_text.lower()
            skill_weights = {}
            for idx, skill in enumerate(critical_skills[:20]):
                weight = 1.0 + (0.5 * (20 - idx) / 20)
                skill_weights[skill] = weight
            
            total_weight = sum(skill_weights.get(skill, 1.0) for skill in critical_skills)
            matched_weight = sum(
                skill_weights.get(skill, 1.0) 
                for skill in critical_skills 
                if re.search(r'\b' + re.escape(skill.replace('-', r'[-\s]?')) + r'\b', cv_lower)
            )
            
            match_ratio = matched_weight / total_weight if total_weight > 0 else 0
            boosted_ratio = math.pow(match_ratio, 0.85)
            keyword_boost = boosted_ratio * 50.0
            
            # Base score
            base_score = semantic_score + keyword_boost
            
            # Strong match bonus (up to 10%)
            if semantic_score > 25 and keyword_boost > 25:
                bonus = min(10.0, (semantic_score - 25) * 0.2 + (keyword_boost - 25) * 0.2)
                base_score += bonus
            
            # Final score (0-100)
            final_score = max(0.0, min(100.0, base_score))
            
            # Count matched skills for reporting
            matched_skills = sum(
                1 for skill in critical_skills 
                if re.search(r'\b' + re.escape(skill.replace('-', r'[-\s]?')) + r'\b', cv_lower)
            )
            
            # Log details for first few CVs (debugging)
            if cv_index < 3:
                bonus_val = base_score - semantic_score - keyword_boost
                print(f"   CV #{cv_index + 1}: Semantic={semantic_score:.1f}% + Keywords={keyword_boost:.1f}% + Bonus={bonus_val:.1f}% = {final_score:.1f}%", 
                      file=sys.stderr, flush=True)
            
            all_matches.append({
                'job_index': cv_index,  # Named for compatibility with backend
                'cv_index': cv_index,
                'similarity_score': round(final_score, 2),
                'semantic_score': round(semantic_score, 2),
                'keyword_score': round(keyword_boost, 2),
                'matched_skills': matched_skills,
                'total_skills': len(critical_skills)
            })
        
        # Step 3: Sort by score descending
        all_matches = sorted(all_matches, key=lambda x: x['similarity_score'], reverse=True)
        
        # Step 4: Take top K
        top_matches = all_matches[:top_k]
        
        if top_matches:
            top_scores = [f"{m['similarity_score']:.1f}%" for m in top_matches[:3]]
            print(f"✅ Top 3 matches: {', '.join(top_scores)}", file=sys.stderr, flush=True)
            print(f"📊 Score range: {top_matches[-1]['similarity_score']:.1f}% - {top_matches[0]['similarity_score']:.1f}%", file=sys.stderr, flush=True)
        
        # Return results as JSON to stdout
        result = {
            'success': True,
            'matches': top_matches,
            'total_cvs': len(cv_texts),
            'matched_cvs': len(all_matches),
            'critical_skills': critical_skills[:20],  # Include top 20 skills for reference
            'method': 'hybrid_weighted_scoring'
        }
        
        print(json.dumps(result), flush=True)
        
    except json.JSONDecodeError as e:
        error_response = {
            'success': False,
            'error': f'Invalid JSON input: {str(e)}'
        }
        print(json.dumps(error_response), flush=True)
        sys.exit(1)
        
    except Exception as e:
        import traceback
        error_response = {
            'success': False,
            'error': str(e),
            'traceback': traceback.format_exc()
        }
        print(json.dumps(error_response), flush=True)
        sys.exit(1)


if __name__ == "__main__":
    main()

