# 🤖 CV Classification Feature - Testing Guide

## ✅ ما تم إضافته

### Backend:
1. **ML Classification Service** على `http://localhost:5001`
   - يصنف الـ CVs إلى 42 فئة وظيفية
   - يعطي نسبة ثقة (confidence)
   - يرجع أفضل 3 تصنيفات

2. **تعديل `/student/upload-cv`**:
   - يستدعي ML service تلقائياً بعد رفع CV
   - يحفظ النتيجة في الـ database
   - يرجع التصنيف في response

3. **تعديل `/student/profile`**:
   - يرجع `cvCategory`, `cvCategoryConfidence`, `cvTopCategories`

### Frontend (Flutter):
1. **صفحة Profile** تعرض الآن:
   - كارد جميل للـ CV Classification
   - الفئة الوظيفية (مثل: Backend Developer)
   - نسبة الثقة (مع لون: أخضر 80%+، برتقالي 60%+، أحمر أقل)
   - Alternative Matches (أفضل 2 تصنيفات بديلة)

2. **رسالة النجاح** بعد رفع CV:
   - تعرض التصنيف مباشرة
   - مثال: "CV uploaded successfully! Classified as: Backend Developer (95%)"

---

## 🧪 كيفية التجربة

### 1. تأكد من تشغيل كل الخدمات:

```powershell
# في terminal 1: ML Service
cd Backend\ml-classifier
.\venv\Scripts\python -m uvicorn cv_classifier:app --port 5001

# في terminal 2: Backend
cd Backend
npm run dev

# في terminal 3: Flutter
flutter run -d chrome
```

أو استخدم:
```powershell
.\start_all.ps1
```

---

### 2. افتح التطبيق واذهب للـ Profile:

```
http://localhost:<port>/#/profile
```

---

### 3. ارفع CV:

1. اضغط على **"Resume"**
2. اختر ملف PDF
3. انتظر الرفع والتصنيف

**النتيجة المتوقعة**:
- رسالة خضراء: `CV uploaded successfully! Classified as: Backend Developer (95%)`
- كارد أزرق يظهر في الـ Profile:
  ```
  🤖 CV Classification
  ┌─────────────────────────────────┐
  │ 💼 Backend Developer      [95%] │
  │ ─────────────────────────────── │
  │ Alternative Matches:            │
  │ → Full-Stack Developer    60%   │
  │ → DevOps Engineer         50%   │
  └─────────────────────────────────┘
  ```

---

## 📝 أمثلة CVs للاختبار

### Backend Developer CV:
```
I am a software developer with 5 years of experience in:
- Python, Django, Flask
- Node.js, Express
- MongoDB, PostgreSQL
- REST APIs
- Docker, microservices
```

**النتيجة المتوقعة**: `Backend Developer (95%)`

---

### DevOps Engineer CV:
```
DevOps engineer specializing in:
- Docker, Kubernetes
- Jenkins, CI/CD
- AWS, Azure
- Terraform, Ansible
- Linux administration
```

**النتيجة المتوقعة**: `DevOps Engineer (95%)`

---

### Frontend Developer CV:
```
Frontend developer with expertise in:
- React, Angular
- JavaScript, TypeScript
- HTML, CSS
- Webpack, Sass
- Responsive design
```

**النتيجة المتوقعة**: `Frontend Developer (95%)`

---

## 🐛 استكشاف الأخطاء

### ❌ الكارد لا يظهر:

**السبب المحتمل**: لم يتم رفع CV أو التصنيف فشل

**الحل**:
1. تحقق من logs في ML service terminal
2. تحقق من response في Network tab (Developer Tools)
3. تأكد أن ML service يعمل: `http://localhost:5001/health`

---

### ❌ التصنيف غير دقيق:

**السبب**: حالياً يستخدم keyword matching (fallback)

**الحل لاحقاً**: تثبيت `scikit-learn` و `tensorflow` للـ ML model الأصلي:
```powershell
cd Backend\ml-classifier
.\venv\Scripts\pip install scikit-learn tensorflow
```

---

### ❌ Error: ML Service not available:

**الحل**:
```powershell
# إعادة تشغيل ML Service
cd Backend\ml-classifier
.\venv\Scripts\python -m uvicorn cv_classifier:app --port 5001
```

---

## 📊 تحسينات مستقبلية

- [ ] تثبيت TensorFlow/sklearn للـ ML model الأصلي (دقة أعلى)
- [ ] إضافة زر "Re-classify" لإعادة التصنيف
- [ ] عرض الـ skills المستخرجة من CV
- [ ] إضافة graph للـ confidence scores
- [ ] حفظ history للتصنيفات السابقة

---

**Happy Testing! 🚀**
