# تحديثات النظام - Profile & Role Validation

## التحديثات المُنفذة ✅

### 1. التحقق من الـ Role عند تسجيل الدخول

- ✅ تم تعديل `sign_in_screen.dart` لإرسال الـ role المختار إلى الباك إند
- ✅ تم تعديل `ApiService.login()` لقبول وإرسال الـ role
- ✅ الباك إند (`authController.js`) يتحقق الآن من:
  - إذا سجل المستخدم كـ "user" (موظف)، لا يستطيع تسجيل الدخول بـ "hr"
  - إذا سجل كـ "hr"، لا يستطيع تسجيل الدخول بـ "user"
  - يعرض رسالة خطأ واضحة: `"This account is registered as HR/Student. Please select the correct account type."`

### 2. شاشة Profile الجديدة مع رفع الصور

تم إنشاء `profile_screen.dart` التي تتضمن:

- ✅ عرض بيانات المستخدم الحالية (الاسم، الإيميل، الهاتف)
- ✅ تعديل البيانات الشخصية
- ✅ رفع صورة profile من الجهاز
- ✅ عرض نوع الحساب (HR أو Employee)
- ✅ حفظ التغييرات في قاعدة البيانات

### 3. تكامل الباك إند

- ✅ endpoint موجود بالفعل: `POST /api/auth/me/upload-image`
- ✅ يحول الصورة إلى base64 ويحفظها في MongoDB
- ✅ endpoint موجود: `PUT /api/auth/me` لتحديث البيانات
- ✅ endpoint موجود: `GET /api/auth/me` لجلب بيانات المستخدم

## كيفية الاستخدام

### تجربة التحقق من الـ Role:

1. سجل حساب جديد كـ "Employee" (user)
2. حاول تسجيل الدخول بنفس الإيميل لكن اختر "HR"
3. النتيجة: ستظهر رسالة خطأ تخبرك أن الحساب مسجل كـ Student

### تجربة Profile والصورة:

1. سجّل الدخول بحسابك
2. اذهب إلى Settings → Edit Profile
3. ستظهر شاشة Profile تعرض:
   - اسمك
   - إيميلك
   - رقم الهاتف
   - نوع الحساب
4. اضغط على أيقونة الكاميرا لرفع صورة
5. عدّل البيانات واضغط "Save Changes"

## الملفات المعدلة

### Flutter (Frontend):

- ✅ `lib/screens/sign_in_screen.dart` - إضافة role للـ login
- ✅ `lib/screens/profile_screen.dart` - شاشة جديدة
- ✅ `lib/screens/settings_screen.dart` - تحديث عرض الإيميل
- ✅ `lib/services/api_service.dart` - إضافة role parameter
- ✅ `lib/main.dart` - إضافة مسار `/profile`

### Backend:

- ✅ `Backend/controllers/authController.js` - دعم profileImage
- ✅ `Backend/routes/authRoutes.js` - مسار رفع الصور موجود مسبقاً

## تشغيل التطبيق

```bash
# Backend (في طرفية منفصلة)
cd Backend
npm start

# Flutter Web
flutter run -d chrome

# أو للتشغيل على Android
flutter run -d <device-id>
```

## بيانات الاختبار

### حساب Employee:

- Email: test@example.com
- Password: test123
- Role: user

### حساب HR:

- Email: hr@example.com
- Password: hr123456
- Role: hr

## ملاحظات مهمة

1. **الصور تُحفظ كـ base64** في قاعدة البيانات
2. **الحد الأقصى لحجم الصورة**: 5MB
3. **أنواع الملفات المسموحة**: صور فقط (jpg, png, gif, etc.)
4. **التحقق من الـ role** يحدث في الباك إند للأمان

## API Endpoints المستخدمة

```
POST   /api/auth/login              - تسجيل الدخول مع التحقق من role
GET    /api/auth/me                 - جلب بيانات المستخدم
PUT    /api/auth/me                 - تحديث البيانات
POST   /api/auth/me/upload-image    - رفع صورة profile
```

## الخطوات التالية (اختياري)

- [ ] إضافة crop للصورة قبل الرفع
- [ ] ضغط الصور لتقليل الحجم
- [ ] إضافة تقدم (progress bar) عند رفع الصور
- [ ] حفظ الصور في GridFS بدلاً من base64
