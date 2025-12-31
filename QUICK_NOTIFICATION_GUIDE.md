# دليل سريع - نظام الإشعارات

## التدفق الكامل

### 1️⃣ عند تقديم موظف على وظيفة:
```
Employee applies to job 
    ↓
Backend: jobController.applyToJob()
    ↓
Create Application
    ↓
Send Notification to HR
    ↓
HR receives notification
```

### 2️⃣ عند استقبال HR للإشعار:
```
HR opens app
    ↓
Sees notification badge
    ↓
Opens notifications screen
    ↓
Sees: "محمد علي قدم على وظيفة مطور برمجيات"
```

### 3️⃣ عند ضغط HR على الإشعار:
```
Tap on notification
    ↓
Navigate to JobApplicantsScreen
    ↓
Shows all applicants for that job
    ↓
HR can tap any applicant to see details
    ↓
HR can view full profile/CV
```

## مثال على الإشعار

### في Backend (jobController.js):
```javascript
await Notification.create({
  userId: job.postedBy, // HR ID
  title: "متقدم جديد على الوظيفة",
  message: `${fullName} قدم على وظيفة ${job.title}`,
  type: "application",
  read: false,
  link: `/job/${jobId}/applicants`,
  metadata: {
    jobId: jobId,
    jobTitle: job.title,
    candidateId: candidate._id,
    candidateName: fullName,
    applicationId: application._id,
  },
});
```

### في Frontend (NotificationsScreen):
```dart
void _handleNotificationTap(NotificationModel notification) {
  if (notification.type == 'application') {
    final jobId = notification.metadata!['jobId'];
    final jobTitle = notification.metadata!['jobTitle'];
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobApplicantsScreen(
          jobId: jobId.toString(),
          jobTitle: jobTitle.toString(),
        ),
      ),
    );
  }
}
```

## الميزات الرئيسية

✅ **إشعار فوري**: يتم إرسال الإشعار فوراً عند التقديم
✅ **معلومات كاملة**: الإشعار يحتوي على اسم المتقدم واسم الوظيفة
✅ **انتقال تلقائي**: الضغط على الإشعار ينقل مباشرة للصفحة المطلوبة
✅ **تفاصيل المتقدمين**: يمكن رؤية جميع المتقدمين على الوظيفة
✅ **نسبة التطابق**: عرض نسبة تطابق كل متقدم مع متطلبات الوظيفة
✅ **إجابات مخصصة**: عرض إجابات المتقدم على الأسئلة المخصصة

## اختبار النظام

### الخطوة 1: تشغيل Backend
```bash
cd Backend
npm start
```

### الخطوة 2: تشغيل Flutter App
```bash
flutter run
```

### الخطوة 3: اختبار التدفق
1. قم بتسجيل الدخول كـ Employee
2. ابحث عن وظيفة وقدم عليها
3. قم بتسجيل الخروج
4. سجل دخول كـ HR (الشخص الذي نشر الوظيفة)
5. افتح شاشة الإشعارات
6. يجب أن ترى إشعار "متقدم جديد على الوظيفة"
7. اضغط على الإشعار
8. يجب أن تنتقل لصفحة عرض المتقدمين
9. اضغط على أي متقدم لرؤية التفاصيل

## حل المشاكل الشائعة

### الإشعار لا يظهر؟
- تأكد من أن Backend يعمل
- تأكد من أن HR هو الذي نشر الوظيفة (postedBy)
- تحقق من console logs في Backend

### لا يتم الانتقال عند الضغط؟
- تأكد من أن metadata موجود في الإشعار
- تحقق من أن jobId صحيح

### المتقدمين لا يظهرون؟
- تأكد من أن التقديم تم بنجاح
- تحقق من Application collection في MongoDB
- تأكد من أن endpoint /hr/jobs/:id/candidates يعمل
