# 🚀 Job Compass - Quick Start Guide

## تشغيل كل شيء بضغطة واحدة

### الطريقة 1️⃣: استخدام Start Script (الأسهل ✨)

#### في PowerShell:
```powershell
.\start_all.ps1
```

#### في Windows Explorer:
- Double-click على `start_all.bat`

#### في VS Code Terminal:
```powershell
.\start_all.ps1
```

---

## 📋 ما الذي يحدث؟

عند تشغيل `start_all.ps1`:

1. ✅ **ML Classification Service** يبدأ على `http://localhost:5001`
   - يصنف الـ CVs تلقائياً عند رفعها

2. ✅ **Backend API Server** يبدأ على `http://localhost:5000`
   - يتعامل مع كل طلبات HR والموظفين

3. ✅ **Flutter Web App** يفتح في Chrome
   - التطبيق جاهز للاستخدام!

---

## 🛑 إيقاف كل الخدمات

```powershell
.\stop_all.ps1
```

أو اضغط `Ctrl+C` في كل نافذة PowerShell.

---

## 🔧 تشغيل يدوي (إذا أردت)

### 1. ML Service:
```powershell
cd Backend\ml-classifier
.\venv\Scripts\python -m uvicorn cv_classifier:app --port 5001
```

### 2. Backend:
```powershell
cd Backend
npm run dev
```

### 3. Flutter:
```powershell
flutter run -d chrome
```

---

## ⚙️ الإعدادات

- **Backend Port**: `5000` (في `Backend/server.js`)
- **ML Service Port**: `5001` (في `Backend/ml-classifier/cv_classifier.py`)
- **Database**: MongoDB على `mongodb://localhost:27017/cv_project_db`

---

## 🐛 استكشاف الأخطاء

### المنفذ مشغول (Port already in use):
```powershell
# إيقاف العملية على port 5000
Get-NetTCPConnection -LocalPort 5000 | Select-Object -ExpandProperty OwningProcess | Stop-Process -Force

# إيقاف العملية على port 5001
Get-NetTCPConnection -LocalPort 5001 | Select-Object -ExpandProperty OwningProcess | Stop-Process -Force
```

### ML Service لا يعمل:
```powershell
cd Backend\ml-classifier
pip install fastapi uvicorn numpy
```

### Backend لا يعمل:
```powershell
cd Backend
npm install
```

### Flutter لا يعمل:
```powershell
flutter pub get
flutter doctor
```

---

## 📚 معلومات إضافية

- **الوثائق الكاملة**: انظر إلى `QUICK_START.md`
- **API Documentation**: `Backend/API_DOCUMENTATION.md`
- **ML Service**: يستخدم keyword classification (يمكن ترقيته لـ TensorFlow لاحقاً)

---

## 🎯 نصائح

1. **أول مرة تشغيل**:
   - تأكد من تشغيل MongoDB
   - شغل `npm install` في Backend
   - شغل `flutter pub get` في المجلد الرئيسي

2. **للتطوير**:
   - استخدم `start_all.ps1` لتوفير الوقت
   - النوافذ المصغرة تبقى في الخلفية
   - يمكنك رؤية logs في نوافذها

3. **عند الانتهاء**:
   - استخدم `stop_all.ps1` لإيقاف كل شيء
   - أو أغلق نوافذ PowerShell

---

**Happy Coding! 💻✨**
