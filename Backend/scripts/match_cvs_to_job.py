"""
Job-to-CVs Matching System
Finds best matching CVs for a given job description using TF-IDF + cosine similarity
Professional matching without heavy ML dependencies
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


def match_cv_to_job(cv_text, job_text):
    """
    Match a CV to a job description using cosine similarity
    Returns similarity score (0-100)
    """
    similarity = cosine_similarity_simple(cv_text, job_text)
    return similarity * 100


def main():
    """
    Main execution: read job + CVs from stdin, return top matches as JSON
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
        
        print(f"🔍 Matching {len(cv_texts)} CVs to job using TF-IDF...", file=sys.stderr, flush=True)
        
        # Match each CV to the job
        all_matches = []
        for cv_index, cv_text in enumerate(cv_texts):
            if not cv_text or len(cv_text.strip()) < 10:
                continue
            
            score = match_cv_to_job(cv_text, job_description)
            
            all_matches.append({
                'job_index': cv_index,  # Named for compatibility with backend
                'cv_index': cv_index,
                'similarity_score': round(score, 2)
            })
        
        # Sort by score descending
        all_matches = sorted(all_matches, key=lambda x: x['similarity_score'], reverse=True)
        
        # Take top K
        top_matches = all_matches[:top_k]
        
        if top_matches:
            top_scores = [f"{m['similarity_score']:.1f}%" for m in top_matches[:3]]
            print(f"✅ Top 3 matches: {', '.join(top_scores)}", file=sys.stderr, flush=True)
        
        # Return results as JSON to stdout
        result = {
            'success': True,
            'matches': top_matches,
            'total_cvs': len(cv_texts),
            'matched_cvs': len(all_matches)
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
