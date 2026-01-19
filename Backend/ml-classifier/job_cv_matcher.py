"""
JOB-to-CVs Matching System for HR Dashboard
Matches job descriptions with candidate CVs using hybrid scoring
"""

import sys
import json
import re
from pymongo import MongoClient
from bson.objectid import ObjectId

class CVJobMatcher:
    def __init__(self):
        self.model = True  # Simulated model for now
        
    def calculate_keyword_boost(self, cv_text, critical_skills, boost_weight=10.0):
        """
        Calculate bonus points based on critical technical skills
        Uses same skill matching logic as JavaScript studentRoutes for consistency
        """
        keyword_count = 0
        cv_lower = cv_text.lower()
        
        for skill in critical_skills:
            skill_lower = skill.lower()
            
            # Create skill variants (same as JavaScript logic)
            skill_variants = set()
            skill_variants.add(skill_lower)
            
            # Handle .js framework names (node.js, express.js, react.js, etc.)
            if '.js' in skill_lower:
                base = skill_lower.replace('.js', '')
                skill_variants.add(base)                    # node.js -> node
                skill_variants.add(base + 'js')             # node.js -> nodejs
                skill_variants.add(base + ' js')            # node.js -> node js
            elif skill_lower.endswith('js') and len(skill_lower) > 2:
                base = skill_lower[:-2]  # Remove 'js' suffix
                skill_variants.add(base + '.js')            # nodejs -> node.js
                skill_variants.add(base)                    # nodejs -> node
            
            # Handle slash-separated skills (MongoDB/MySQL -> match if CV has MongoDB OR MySQL)
            if '/' in skill_lower:
                parts = skill_lower.split('/')
                for part in parts:
                    skill_variants.add(part.strip())
            
            # Handle space-separated ONLY for known technical terms
            is_compound_technical = (
                'api' in skill_lower or
                'tcp' in skill_lower or
                'lan' in skill_lower or
                'ci/cd' in skill_lower or
                'html' in skill_lower or
                'css' in skill_lower
            )
            
            if ' ' in skill_lower and is_compound_technical:
                words = skill_lower.split(' ')
                for word in words:
                    if len(word) >= 2:
                        skill_variants.add(word)
                skill_variants.add(skill_lower.replace(' ', ''))
            
            # Check if CV contains any variant (same matching rules as JavaScript)
            found = False
            for variant in skill_variants:
                if not variant or len(variant) < 2:
                    continue
                
                # For short skills (<=3 chars), use simple substring match
                if len(variant) <= 3:
                    if variant in cv_lower:
                        found = True
                        break
                else:
                    # For longer skills, try word boundary match first
                    escaped = re.escape(variant)
                    pattern = r'\b' + escaped + r'\b'
                    if re.search(pattern, cv_lower, re.IGNORECASE):
                        found = True
                        break
                    # Fallback to substring match
                    if variant in cv_lower:
                        found = True
                        break
            
            if found:
                keyword_count += 1
                
        return keyword_count * boost_weight
    
    def extract_skills_from_job(self, job_description, required_skills):
        """
        Extract technical skills from job description and required skills
        Same extraction logic as JavaScript studentRoutes for consistency
        """
        all_skills = set()
        
        # Add explicitly listed skills
        if required_skills:
            all_skills.update([s.lower() for s in required_skills])
        
        # Common technical keywords to extract (same as JavaScript KNOWN_SKILLS)
        tech_keywords = [
            # Programming Languages
            'javascript', 'python', 'java', 'c#', 'c++', 'php', 'ruby', 'go', 'rust', 'swift', 'kotlin', 'typescript',
            # Frontend
            'react', 'react.js', 'reactjs', 'angular', 'vue', 'vue.js', 'vuejs', 'html', 'css', 'sass', 'less', 'bootstrap', 'tailwind',
            # Backend
            'node', 'node.js', 'nodejs', 'express', 'express.js', 'expressjs', 'django', 'flask', 'spring', 'laravel', 'rails',
            # Databases
            'mongodb', 'mysql', 'postgresql', 'postgres', 'sql', 'redis', 'firebase', 'dynamodb', 'oracle', 'sqlite',
            # DevOps & Cloud
            'docker', 'kubernetes', 'aws', 'azure', 'gcp', 'jenkins', 'ci/cd', 'linux', 'git', 'github', 'gitlab',
            # APIs
            'rest', 'restful', 'graphql', 'api', 'apis', 'websocket', 'socket.io',
            # Other
            'jwt', 'oauth', 'authentication', 'authorization', 'security', 'testing', 'agile', 'scrum'
        ]
        
        job_lower = job_description.lower()
        for keyword in tech_keywords:
            escaped = re.escape(keyword)
            pattern = r'\b' + escaped + r'\b'
            if re.search(pattern, job_lower, re.IGNORECASE):
                all_skills.add(keyword)
        
        return list(all_skills)
    
    def calculate_similarity_score(self, job_text, cv_text, critical_skills):
        """
        Calculate hybrid weighted similarity score between job and CV
        Same scoring system as the original employ system
        """
        # Base BERT semantic similarity score (fixed at 55 for consistency)
        # This ensures the same CV + Job combination always gets the same score
        # In production, this would use actual BERT model
        bert_base_score = 55.0
        
        # Calculate keyword boost (10 points per matched skill - same as employ system)
        keyword_boost = self.calculate_keyword_boost(cv_text, critical_skills, boost_weight=10.0)
        
        # Final hybrid score (same formula as employ system)
        # Final Score = (BERT Score × 0.5) + Keyword Boost
        final_score = (bert_base_score * 0.5) + keyword_boost
        
        # Normalize to 0-100 scale
        normalized_score = min(final_score, 100.0)
        
        return round(normalized_score, 2)
    
    def match_job_to_cvs(self, job_data, candidates):
        """
        Match a job description with candidate CVs
        Returns sorted list of matches
        """
        job_description = job_data.get('description', '')
        job_title = job_data.get('title', '')
        required_skills = job_data.get('requiredSkills', [])
        
        # Extract critical skills from job
        critical_skills = self.extract_skills_from_job(
            job_description + ' ' + job_title,
            required_skills
        )
        
        # Debug: Print extracted skills
        print(f"📋 Required Skills from DB: {required_skills}", file=sys.stderr)
        print(f"🔍 Total Critical Skills: {len(critical_skills)}", file=sys.stderr)
        print(f"   Skills: {', '.join(critical_skills[:20])}", file=sys.stderr)
        sys.stderr.flush()
        
        matches = []
        
        for candidate in candidates:
            # Try both resumeText and cvText for compatibility
            cv_text = candidate.get('resumeText', '') or candidate.get('cvText', '')
            
            # Skip if no CV text
            if not cv_text or len(cv_text) < 50:
                continue
            
            # Calculate similarity score
            score = self.calculate_similarity_score(
                job_description,
                cv_text,
                critical_skills
            )
            
            # Debug: Print candidate matching details
            candidate_name = candidate.get('name', 'Unknown')
            candidate_skills = candidate.get('skills', [])
            print(f"👤 {candidate_name}: Skills in DB: {candidate_skills[:5]}, Score: {score}%", file=sys.stderr)
            sys.stderr.flush()
            
            matches.append({
                'candidateId': str(candidate['_id']),
                'candidateName': candidate.get('name', 'Unknown'),
                'email': candidate.get('email', ''),
                'phone': candidate.get('phone', ''),
                'matchScore': score,
                'extractedSkills': candidate.get('skills', []) or candidate.get('extractedSkills', []),
                'cvUrl': candidate.get('resumeUrl', '') or candidate.get('cvUrl', ''),
                'appliedAt': candidate.get('createdAt', None)
            })
        
        # Sort by match score (highest first)
        matches.sort(key=lambda x: x['matchScore'], reverse=True)
        
        return matches

def main():
    try:
        # Read input from command line arguments
        if len(sys.argv) < 2:
            print(json.dumps({
                'success': False,
                'message': 'Missing job ID parameter'
            }))
            sys.exit(1)
        
        job_id = sys.argv[1]
        print(f"🔄 Processing job ID: {job_id}", file=sys.stderr)
        
        # Connect to MongoDB
        mongo_uri = 'mongodb://localhost:27017/cv_project_db'
        client = MongoClient(mongo_uri)
        db = client['cv_project_db']
        print("✅ Connected to MongoDB", file=sys.stderr)
        
        # Fetch job details
        job = db.jobs.find_one({'_id': ObjectId(job_id)})
        
        if not job:
            print(json.dumps({
                'success': False,
                'message': 'Job not found'
            }))
            sys.exit(1)
        
        print(f"📋 Job Title: {job.get('title', 'Untitled')}", file=sys.stderr)
        
        # Fetch all candidates who have uploaded CVs
        # Use 'candidates' collection
        candidates = list(db.candidates.find({
            'resumeText': {'$exists': True, '$ne': ''}
        }))
        
        # Log to stderr BEFORE processing
        print(f"🔍 Matching {len(candidates)} CVs using Hybrid Weighted Scoring...", file=sys.stderr)
        sys.stderr.flush()
        
        # If no candidates, return empty
        if not candidates:
            result = {
                'success': True,
                'data': [],
                'message': 'No candidates with CVs found',
                'jobTitle': job.get('title', 'Job'),
                'totalCandidates': 0,
                'totalMatches': 0
            }
            print(json.dumps(result, default=str))
            sys.stdout.flush()
            return
        
        # Match job to CVs
        matcher = CVJobMatcher()
        
        # Extract critical skills first
        job_description = job.get('description', '')
        job_title = job.get('title', '')
        required_skills = job.get('requiredSkills', [])
        critical_skills = matcher.extract_skills_from_job(
            job_description + ' ' + job_title,
            required_skills
        )
        
        # Log to stderr BEFORE processing
        print(f"🎯 Found {len(critical_skills)} critical skills in job description", file=sys.stderr)
        if critical_skills:
            top_skills = ', '.join(critical_skills[:10])
            print(f"   Top skills: {top_skills}", file=sys.stderr)
        sys.stderr.flush()
        
        matches = matcher.match_job_to_cvs(job, candidates)
        
        # Log final count
        print(f"✅ Found {len(matches)} matches", file=sys.stderr)
        sys.stderr.flush()
        
        # Return results as JSON to stdout (clean output only!)
        result = {
            'success': True,
            'data': matches,
            'jobTitle': job.get('title', 'Job'),
            'totalCandidates': len(candidates),
            'totalMatches': len(matches)
        }
        print(json.dumps(result, default=str))
        sys.stdout.flush()
        
    except Exception as e:
        import traceback
        error_details = traceback.format_exc()
        print(f"❌ ERROR: {str(e)}", file=sys.stderr)
        print(error_details, file=sys.stderr)
        sys.stderr.flush()
        result = {
            'success': False,
            'message': f'Error: {str(e)}'
        }
        print(json.dumps(result))
        sys.stdout.flush()

if __name__ == "__main__":
    main()
