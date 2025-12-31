# نظام الإشعارات للـ HR عند التقديم على الوظائف

## التحديثات المنفذة

### Backend Updates

#### 1. تحديث jobController.js
- إضافة كود لإرسال إشعار للـ HR عند تقديم موظف على وظيفة
- الإشعار يحتوي على:
  - عنوان: "متقدم جديد على الوظيفة"
  - رسالة: اسم المتقدم واسم الوظيفة
  - نوع: "application"
  - رابط: `/job/{jobId}/applicants`
  - metadata: تحتوي على jobId, jobTitle, candidateId, candidateName, applicationId

#### 2. تحديث Notification Model
- إضافة حقل `metadata` من نوع Mixed لتخزين معلومات إضافية

#### 3. تحديث hrController.js
- تحديث `getJobCandidates` لاستخدام Application model والحصول على كل التفاصيل
- تحديث `getHRNotifications` لإرجاع metadata مع كل إشعار

### Frontend Updates

#### 1. إنشاء JobApplicantsScreen
صفحة جديدة لعرض المتقدمين على وظيفة معينة تحتوي على:
- عرض معلومات الوظيفة
- قائمة بجميع المتقدمين مع:
  - نسبة التطابق (Match Percentage)
  - معلومات الاتصال (اسم، بريد إلكتروني، هاتف)
  - المهارات
  - تاريخ التقديم
- عند الضغط على متقدم، تظهر نافذة منبثقة بالتفاصيل الكاملة:
  - جميع المعلومات الأساسية
  - إجابات الأسئلة المخصصة
  - زر لعرض السيرة الذاتية الكاملة

#### 2. تحديث NotificationsScreen
- إضافة دعم للضغط على الإشعارات
- عند الضغط على إشعار من نوع "application":
  - الانتقال تلقائياً لصفحة JobApplicantsScreen
  - تمرير jobId و jobTitle من metadata
  - تعليم الإشعار كمقروء
- تحديث الأيقونات والألوان لدعم أنواع الإشعارات المختلفة

#### 3. تحديث NotificationModel
- تحديث fromJson لدعم حقل `read` من Backend

#### 4. تحديث ApiService
- إضافة دالة `markNotificationAsRead` لتعليم الإشعار كمقروء

## كيفية الاستخدام

### للموظف (Employee):
1. يقوم الموظف بالتقديم على وظيفة من خلال شاشة Job Application
2. يتم إنشاء الطلب بنجاح

### للـ HR:
1. يتلقى HR إشعاراً فورياً عند تقديم أي موظف
2. الإشعار يحتوي على اسم المتقدم واسم الوظيفة
3. عند الضغط على الإشعار:
   - يتم الانتقال لصفحة عرض المتقدمين على هذه الوظيفة
   - يشاهد HR قائمة بجميع المتقدمين
   - يمكنه الضغط على أي متقدم لرؤية التفاصيل الكاملة
   - يمكنه رؤية السيرة الذاتية والبروفايل الكامل

## الملفات المعدلة

### Backend:
- `/Backend/controllers/jobController.js` - إضافة إرسال الإشعار
- `/Backend/controllers/hrController.js` - تحديث getJobCandidates و getHRNotifications
- `/Backend/controllers/notificationController.js` - تحسين markAsRead
- `/Backend/models/Notification.js` - إضافة metadata field

### Frontend:
- `/lib/screens/job_applicants_screen.dart` - **ملف جديد**
- `/lib/screens/notifications_screen.dart` - تحديث لدعم التنقل
- `/lib/models/notification.dart` - تحديث fromJson
- `/lib/services/api_service.dart` - إضافة markNotificationAsRead

## الخطوات التالية المقترحة

1. ✅ إضافة صفحة لعرض السيرة الذاتية الكاملة للمتقدم
2. ✅ إضافة إمكانية تحديث حالة الطلب (قبول، رفض، قيد المراجعة)
3. ✅ إضافة فلترة وترتيب المتقدمين
4. ✅ إضافة إحصائيات للوظيفة (عدد المتقدمين، متوسط التطابق، إلخ)
5. ✅ إضافة إشعارات push notifications
