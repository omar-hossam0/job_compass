# Job-CV Matching System Setup

## نظام مطابقة الوظائف مع السير الذاتية

تم ربط نظام المطابقة الهجين (Hybrid Weighted Scoring) من مجلد `job_hr` مع نظام HR Dashboard.

### المميزات:
- ✅ مقارنة Job Description مع CVs
- ✅ Hybrid Scoring (Keyword Matching + Semantic Similarity)
- ✅ نفس نسب التقييم كما في تقييم CV الموظفين
- ✅ يدعم المهارات التقنية (Technical Skills)

### التثبيت:

```bash
# Install Python dependencies
cd Backend/ml-classifier
pip install -r requirements.txt
```

### كيف يعمل:

1. **HR يضغط "Find Matches"** في الـ HR Dashboard
2. **Backend يستدعي** `job_cv_matcher.py`
3. **Python Script**:
   - يحمل Job Description من MongoDB
   - يحمل كل الـ CVs من Users collection
   - يستخدم Hybrid Scoring:
     - Base Score (50%)
     - Keyword Matching (50%) - يبحث عن المهارات التقنية
   - يرجع أفضل 10 مرشحين

4. **Backend يعرض النتائج** مع النسب المئوية

### مثال النتيجة:

```json
{
  "success": true,
  "data": [
    {
      "candidateId": "...",
      "candidateName": "Ahmed Mohamed",
      "email": "ahmed@example.com",
      "matchScore": 85.5,
      "extractedSkills": ["JavaScript", "Node.js", "React"]
    }
  ],
  "jobTitle": "Backend Developer",
  "totalMatches": 10
}
```

### التخصيص:

يمكنك تعديل المهارات التقنية في `job_cv_matcher.py`:

```python
tech_keywords = [
    "javascript", "python", "java", "react", "node.js",
    # أضف المزيد من المهارات هنا
]
```

### ملاحظات:
- النظام يستخدم `cvText` من User model
- النسب من 0-100%
- يمكن استخدام BERT لتحسين Semantic Matching لاحقاً
