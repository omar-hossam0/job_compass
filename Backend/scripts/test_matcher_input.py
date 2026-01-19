#!/usr/bin/env python3
"""
Simple test to verify CV matching produces valid percentages (0-100%)
"""

import sys
import json

# Sample job description
job_description = """
Senior Backend Developer Position

Requirements:
- 5+ years experience in backend development
- Strong proficiency in Node.js and Express.js
- Experience with MongoDB and Redis
- RESTful API design and implementation
- Docker and Kubernetes knowledge
- Git version control
- Agile/Scrum methodologies
"""

# Sample CVs
cvs = [
    # CV 1: Perfect match
    """
    Senior Backend Developer with 6 years experience.
    Expert in Node.js, Express.js, MongoDB, Redis.
    Built 20+ REST APIs using Node.js and Express.
    Strong Docker and Kubernetes skills.
    Proficient in Git and Agile methodologies.
    Led multiple backend teams.
    """,
    
    # CV 2: Good match
    """
    Backend Developer with 4 years experience.
    Skilled in Node.js, Express.js, and MongoDB.
    Created several REST APIs.
    Experience with Docker and Git.
    Familiar with Agile practices.
    """,
    
    # CV 3: Fair match
    """
    Full Stack Developer with 3 years experience.
    Frontend: React, Vue.js
    Backend: Node.js, Express
    Database: MongoDB
    Version control: Git
    """,
    
    # CV 4: Low match
    """
    Junior Developer with 1 year experience.
    Learning JavaScript and Node.js.
    Completed online courses.
    Basic Git knowledge.
    """,
    
    # CV 5: Very low match (different stack)
    """
    Python Developer with 5 years experience.
    Expert in Django and Flask.
    PostgreSQL database design.
    AWS cloud deployment.
    """
]

# Test data
test_input = {
    'job_description': job_description,
    'cv_texts': cvs,
    'top_k': 5
}

# Write to stdin for the Python script
sys.stdout.write(json.dumps(test_input))
sys.stdout.flush()
