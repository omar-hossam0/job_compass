"""
CV Classification Service for Job Compass
Uses MLP model with TF-IDF vectorizer to classify CVs into job categories
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import pickle
import numpy as np
import json
import os
import sys
import re

# Try to import tensorflow/keras
try:
    import tensorflow as tf
    from tensorflow import keras
    HAS_TENSORFLOW = True
except ImportError:
    HAS_TENSORFLOW = False
    print("⚠️ TensorFlow not available")

# Try to import sklearn
try:
    from sklearn.feature_extraction.text import TfidfVectorizer
    HAS_SKLEARN = True
except ImportError:
    HAS_SKLEARN = False
    print("⚠️ Scikit-learn not available")

app = FastAPI(title="CV Classification Service", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global variables
model = None
vectorizer = None
label_encoder = None
job_classes = []
MODEL_READY = False
MODEL_LOAD_ERROR = None

# Paths
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, "mlp_cv_model.h5")
VECTORIZER_PATH = os.path.join(BASE_DIR, "vectorizer.pkl")
LABEL_ENCODER_PATH = os.path.join(BASE_DIR, "label_encoder.pkl")
JOB_CLASSES_PATH = os.path.join(BASE_DIR, "job_classes.json")


class CVClassificationRequest(BaseModel):
    cv_text: str


class CVClassificationResponse(BaseModel):
    success: bool
    job_category: str = None
    confidence: float = None
    top_3_predictions: list = None
    error: str = None


def clean_text(text: str) -> str:
    """Clean and preprocess CV text"""
    if not text:
        return ""
    text = str(text).lower()
    # Remove special characters but keep spaces
    text = re.sub(r'[^a-z\s]', ' ', text)
    # Remove extra whitespace
    text = re.sub(r'\s+', ' ', text).strip()
    return text


def load_models():
    """Load all ML models and encoders"""
    global model, vectorizer, label_encoder, job_classes, MODEL_READY, MODEL_LOAD_ERROR

    print("🔄 Loading CV Classification models...")

    MODEL_READY = False
    MODEL_LOAD_ERROR = None

    # Load job classes metadata (optional but useful for UI)
    if os.path.exists(JOB_CLASSES_PATH):
        with open(JOB_CLASSES_PATH, 'r', encoding='utf-8') as f:
            data = json.load(f)
            if isinstance(data, dict):
                job_classes = data.get("job_classes", [])
            else:
                job_classes = data
        print(f"✅ Loaded {len(job_classes)} job categories")
    else:
        print(f"⚠️ Job classes file not found: {JOB_CLASSES_PATH}")

    # All ML artefacts are required for a verified classification run
    if not HAS_SKLEARN:
        MODEL_LOAD_ERROR = "Scikit-learn not installed"
        print(f"❌ {MODEL_LOAD_ERROR}")
        return False

    if not os.path.exists(VECTORIZER_PATH):
        MODEL_LOAD_ERROR = f"Vectorizer not found at {VECTORIZER_PATH}"
        print(f"❌ {MODEL_LOAD_ERROR}")
        return False

    if not os.path.exists(LABEL_ENCODER_PATH):
        MODEL_LOAD_ERROR = f"Label encoder not found at {LABEL_ENCODER_PATH}"
        print(f"❌ {MODEL_LOAD_ERROR}")
        return False

    if not HAS_TENSORFLOW:
        MODEL_LOAD_ERROR = "TensorFlow not installed"
        print(f"❌ {MODEL_LOAD_ERROR}")
        return False

    if not os.path.exists(MODEL_PATH):
        MODEL_LOAD_ERROR = f"Model file not found at {MODEL_PATH}"
        print(f"❌ {MODEL_LOAD_ERROR}")
        return False

    try:
        with open(VECTORIZER_PATH, 'rb') as f:
            vectorizer = pickle.load(f)
        print("✅ Vectorizer loaded")
    except Exception as exc:
        MODEL_LOAD_ERROR = f"Could not load vectorizer: {exc}"
        print(f"❌ {MODEL_LOAD_ERROR}")
        return False

    try:
        with open(LABEL_ENCODER_PATH, 'rb') as f:
            label_encoder = pickle.load(f)
        print(f"✅ Label encoder loaded with {len(label_encoder.classes_)} classes")
    except Exception as exc:
        MODEL_LOAD_ERROR = f"Could not load label encoder: {exc}"
        print(f"❌ {MODEL_LOAD_ERROR}")
        return False

    try:
        model = keras.models.load_model(MODEL_PATH)
        print("✅ Keras model loaded")
        print(f"   Input shape: {model.input_shape}")
        print(f"   Output shape: {model.output_shape}")
    except Exception as exc:
        MODEL_LOAD_ERROR = f"Error loading Keras model: {exc}"
        print(f"❌ {MODEL_LOAD_ERROR}")
        return False

    MODEL_READY = True
    print("✅ All models loaded successfully!")
    return True


@app.on_event("startup")
async def startup_event():
    """Load models on startup"""
    success = load_models()
    if not success:
        print("⚠️ Some models failed to load. Classification may not work properly.")


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "model_ready": MODEL_READY,
        "model_loaded": model is not None,
        "vectorizer_loaded": vectorizer is not None,
        "label_encoder_loaded": label_encoder is not None,
        "num_classes": len(job_classes) if job_classes else 0,
        "load_error": MODEL_LOAD_ERROR,
    }


@app.get("/categories")
async def get_categories():
    """Get all available job categories"""
    if label_encoder is not None:
        return {
            "success": True,
            "categories": list(label_encoder.classes_)
        }
    elif job_classes:
        return {
            "success": True,
            "categories": job_classes
        }
    return {
        "success": False,
        "error": "Categories not loaded"
    }


@app.post("/classify", response_model=CVClassificationResponse)
async def classify_cv(request: CVClassificationRequest):
    """
    Classify a CV text into a job category
    
    Input: CV text
    Output: Job category with confidence score
    """
    try:
        cv_text = request.cv_text
        if not cv_text or len(cv_text.strip()) < 50:
            raise HTTPException(status_code=400, detail="CV text is too short (minimum 50 characters)")
        
        # Clean the text
        cleaned_text = clean_text(cv_text)
        print(f"\n🔍 Classifying CV...")
        print(f"   Original length: {len(cv_text)}")
        print(f"   Cleaned length: {len(cleaned_text)}")
        print(f"   Preview: {cleaned_text[:100]}...")
        
        # Check if ML model is available
        if not MODEL_READY:
            message = MODEL_LOAD_ERROR or "Classification model not loaded"
            print(f"❌ Classification aborted: {message}")
            return CVClassificationResponse(
                success=False,
                error=message
            )

        if model is not None and vectorizer is not None and label_encoder is not None:
            # Use ML model
            # Vectorize
            text_vector = vectorizer.transform([cleaned_text])
            
            # Convert sparse matrix to dense array if needed
            if hasattr(text_vector, 'toarray'):
                text_vector = text_vector.toarray()
            
            # Predict
            predictions = model.predict(text_vector, verbose=0)
            
            # Get top predictions
            top_indices = np.argsort(predictions[0])[::-1][:3]
            top_classes = label_encoder.inverse_transform(top_indices)
            top_confidences = predictions[0][top_indices]
            
            # Best prediction
            best_idx = top_indices[0]
            best_class = top_classes[0]
            best_confidence = float(top_confidences[0])
            
            print(f"✅ ML Classification result:")
            print(f"   Category: {best_class}")
            print(f"   Confidence: {best_confidence:.2%}")
            
            # Format top 3 predictions
            top_3 = [
                {"category": str(cat), "confidence": float(conf)}
                for cat, conf in zip(top_classes, top_confidences)
            ]
            
            return CVClassificationResponse(
                success=True,
                job_category=str(best_class),
                confidence=best_confidence,
                top_3_predictions=top_3
            )
        else:
            # Should not reach here, but guard just in case
            print("❌ Incomplete model components despite MODEL_READY flag")
            return CVClassificationResponse(
                success=False,
                error="Classification model components missing"
            )

    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Classification error: {e}")
        import traceback
        traceback.print_exc()
        return CVClassificationResponse(
            success=False,
            error=str(e)
        )


def keyword_classify(text: str) -> CVClassificationResponse:
    """
    Fallback classification using keyword matching
    Works without TensorFlow/sklearn
    """
    # Define keywords for each category
    category_keywords = {
        "Backend Developer": ["python", "java", "node", "nodejs", "express", "django", "flask", "spring", "backend", "api", "rest", "sql", "database", "mongodb", "postgresql", "mysql", "redis", "microservices", "php", "laravel"],
        "Frontend Developer": ["react", "angular", "vue", "javascript", "typescript", "html", "css", "frontend", "ui", "webpack", "sass", "bootstrap", "tailwind", "responsive", "dom", "jquery"],
        "Full-Stack Developer": ["fullstack", "full stack", "mern", "mean", "frontend", "backend", "react", "node", "full-stack"],
        "DevOps Engineer": ["devops", "docker", "kubernetes", "k8s", "jenkins", "cicd", "ci/cd", "aws", "azure", "gcp", "terraform", "ansible", "linux", "bash", "shell", "deployment", "infrastructure", "monitoring", "prometheus", "grafana"],
        "Data Scientist": ["data science", "machine learning", "ml", "deep learning", "tensorflow", "pytorch", "pandas", "numpy", "scikit", "sklearn", "jupyter", "neural", "nlp", "computer vision", "statistics", "r programming"],
        "Data Analyst": ["data analyst", "analytics", "sql", "tableau", "power bi", "excel", "visualization", "reporting", "dashboard", "business intelligence", "bi", "data visualization"],
        "Mobile Developer": ["android", "ios", "swift", "kotlin", "flutter", "react native", "mobile", "xamarin", "objective-c", "mobile app"],
        "Cloud Engineer": ["cloud", "aws", "azure", "gcp", "google cloud", "cloud architect", "serverless", "lambda", "ec2", "s3", "cloud computing"],
        "Machine Learning Engineer": ["machine learning engineer", "ml engineer", "mlops", "model deployment", "tensorflow", "pytorch", "model training", "ml pipeline"],
        "QA Engineer": ["qa", "quality assurance", "testing", "selenium", "automation", "test cases", "bug", "cypress", "jest", "unit test", "integration test"],
        "Security Engineer": ["security", "cybersecurity", "penetration", "vulnerability", "firewall", "encryption", "owasp", "security engineer", "infosec"],
        "Database Administrator": ["dba", "database administrator", "oracle", "sql server", "postgresql", "mysql", "database management", "backup", "replication"],
        "System Administrator": ["sysadmin", "system administrator", "linux admin", "windows server", "active directory", "vmware", "network", "server management"],
        "UI/UX Designer": ["ui", "ux", "user experience", "user interface", "figma", "sketch", "adobe xd", "wireframe", "prototype", "usability", "design thinking"],
        "Project Manager": ["project manager", "pm", "scrum", "agile", "jira", "project management", "stakeholder", "timeline", "budget", "pmp"],
        "Product Manager": ["product manager", "product owner", "roadmap", "backlog", "user stories", "market research", "product strategy"],
        "Business Analyst": ["business analyst", "requirements", "brd", "use cases", "process improvement", "stakeholder", "gap analysis"],
        "Technical Writer": ["technical writer", "documentation", "api docs", "user manual", "content", "writing"],
        "HR": ["human resources", "hr", "recruitment", "hiring", "talent acquisition", "employee relations", "onboarding"],
        "Marketing": ["marketing", "digital marketing", "seo", "sem", "social media", "content marketing", "email marketing", "campaign"],
        "Sales": ["sales", "business development", "crm", "salesforce", "lead generation", "negotiation", "account management"],
        "Finance": ["finance", "financial analyst", "budgeting", "forecasting", "investment", "portfolio"],
        "Accounting": ["accounting", "accountant", "bookkeeping", "tax", "audit", "cpa", "financial statements"],
        "Healthcare": ["healthcare", "medical", "nursing", "patient care", "clinical", "hospital", "physician", "health"],
        "Education": ["education", "teacher", "instructor", "curriculum", "training", "academic", "school", "university"],
        "Information-Technology": ["information technology", "it support", "helpdesk", "technical support", "networking", "troubleshooting"],
        "Software Engineer": ["software engineer", "software developer", "programming", "coding", "software development", "algorithms", "data structures"]
    }
    
    # Count keyword matches for each category
    text_lower = text.lower()
    category_scores = {}
    
    for category, keywords in category_keywords.items():
        score = 0
        matched_keywords = []
        for keyword in keywords:
            if keyword in text_lower:
                score += 1
                matched_keywords.append(keyword)
        if score > 0:
            category_scores[category] = {
                "score": score,
                "keywords": matched_keywords,
                "confidence": min(score / len(keywords), 1.0)  # Normalize to 0-1
            }
    
    if not category_scores:
        return CVClassificationResponse(
            success=True,
            job_category="General",
            confidence=0.3,
            top_3_predictions=[{"category": "General", "confidence": 0.3}]
        )
    
    # Sort by score
    sorted_categories = sorted(category_scores.items(), key=lambda x: x[1]["score"], reverse=True)
    
    # Get top 3
    top_3 = []
    for cat, data in sorted_categories[:3]:
        # Adjust confidence based on score
        confidence = min(0.4 + (data["score"] * 0.1), 0.95)  # Range: 0.5 to 0.95
        top_3.append({
            "category": cat,
            "confidence": confidence
        })
    
    best_category = top_3[0]["category"]
    best_confidence = top_3[0]["confidence"]
    
    print(f"✅ Keyword Classification result:")
    print(f"   Category: {best_category}")
    print(f"   Confidence: {best_confidence:.2%}")
    print(f"   Top 3: {top_3}")
    
    return CVClassificationResponse(
        success=True,
        job_category=best_category,
        confidence=best_confidence,
        top_3_predictions=top_3
    )


@app.post("/reload")
async def reload_models():
    """Reload all models"""
    success = load_models()
    return {
        "success": success,
        "message": "Models reloaded" if success else "Failed to reload models",
        "model_ready": MODEL_READY,
        "load_error": MODEL_LOAD_ERROR,
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=5001)
