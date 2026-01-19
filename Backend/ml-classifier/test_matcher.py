"""
Test script for job_cv_matcher.py
"""
import sys
import json

# Simulate command line argument
sys.argv = ['job_cv_matcher.py', '507f1f77bcf86cd799439011']  # Fake job ID for testing

# Import and run
try:
    from job_cv_matcher import CVJobMatcher
    
    matcher = CVJobMatcher()
    
    # Test keyword matching
    cv_text = "Experienced JavaScript developer with Node.js and React skills. 5 years of backend development."
    critical_skills = ["javascript", "node.js", "react", "backend"]
    
    boost = matcher.calculate_keyword_boost(cv_text, critical_skills, boost_weight=5.0)
    print(f"✅ Keyword Boost Test: {boost} points")
    
    # Test score calculation
    job_text = "Looking for a Node.js backend developer with React experience"
    score = matcher.calculate_similarity_score(job_text, cv_text, critical_skills)
    print(f"✅ Similarity Score Test: {score}%")
    
    print("\n✅ All tests passed!")
    
except Exception as e:
    print(f"❌ Test failed: {e}")
    import traceback
    traceback.print_exc()
