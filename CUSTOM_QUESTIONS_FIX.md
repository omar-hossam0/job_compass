# Custom Questions Fix - إصلاح الأسئلة المخصصة

## المشكلة (Problem)
عندما يقوم HR بإنشاء وظيفة ويضيف أسئلة مخصصة (customQuestions)، لا تظهر هذه الأسئلة للطلاب عند التقديم على الوظيفة. بدلاً من ذلك، يرون فقط الأسئلة الافتراضية.

When HR creates a job and adds custom questions, these questions don't appear for students when applying for the job. Instead, they only see the default questions.

## السبب (Root Cause)
المشكلة كانت في `Backend/controllers/hrController.js` في دالة `createJob`:
- الدالة لم تكن تستقبل `customQuestions` من request body
- الدالة لم تكن تحفظ `customQuestions` في قاعدة البيانات

The problem was in `Backend/controllers/hrController.js` in the `createJob` function:
- The function wasn't receiving `customQuestions` from request body
- The function wasn't saving `customQuestions` to the database

## الحل (Solution)

### تم تعديل `hrController.createJob` (Modified):

**قبل (Before):**
```javascript
const { title, description, requiredSkills, experienceLevel } = req.body;

const job = await Job.create({
  title,
  description,
  requiredSkills: Array.isArray(requiredSkills)
    ? requiredSkills
    : requiredSkills.split(",").map((s) => s.trim()),
  experienceLevel,
  companyId: company._id,
  postedBy: req.user.id,
  status: "Active",
  department: req.body.department || "General",
  location: company.location,
});
```

**بعد (After):**
```javascript
const {
  title,
  description,
  requiredSkills,
  experienceLevel,
  customQuestions,  // ✅ Added
  salary,           // ✅ Added
  location,         // ✅ Added
  jobType,          // ✅ Added
} = req.body;

// Parse customQuestions if it's a string
let questionsArray = customQuestions || [];
if (typeof customQuestions === "string") {
  try {
    questionsArray = JSON.parse(customQuestions);
  } catch (e) {
    questionsArray = [];
  }
}

const job = await Job.create({
  title,
  description,
  requiredSkills: Array.isArray(requiredSkills)
    ? requiredSkills
    : requiredSkills.split(",").map((s) => s.trim()),
  experienceLevel,
  companyId: company._id,
  postedBy: req.user.id,
  status: "Active",
  department: req.body.department || "General",
  location: location || company.location,  // ✅ Updated
  salary: salary,                          // ✅ Added
  jobType: jobType,                        // ✅ Added
  customQuestions: questionsArray,         // ✅ Added
});
```

## الملفات المعدلة (Modified Files)

1. **Backend/controllers/hrController.js**
   - تم تحديث `createJob` لاستقبال وحفظ `customQuestions`
   - Updated `createJob` to receive and save `customQuestions`

2. **Backend/controllers/jobController.js** (تم إضافة debugging logs)
   - Added debug logs in `getJob` to track customQuestions
   - Added debug logs in `createJob` to track customQuestions

3. **lib/screens/job_details_screen.dart** (تم إضافة debugging logs)
   - Added debug logs to track customQuestions from API response
   - Added debug logs to track Job object creation

4. **lib/models/job.dart** (تم إضافة debugging logs)
   - Added detailed debug logs in `Job.fromJson` for customQuestions parsing

5. **lib/screens/post_job_screen.dart** (تم إضافة debugging logs)
   - Added debug logs to track customQuestions before posting

## Testing Script
تم إنشاء سكريبت للتحقق من الأسئلة المخصصة في قاعدة البيانات:
Created a script to check custom questions in the database:

```bash
node Backend/scripts/checkCustomQuestions.js
```

## الخطوات التالية (Next Steps)

1. **اختبار الإصلاح (Test the fix):**
   - قم بإعادة تشغيل الـ backend server
   - أنشئ وظيفة جديدة مع أسئلة مخصصة
   - تحقق من ظهور الأسئلة للطلاب عند التقديم

2. **إزالة Debug Logs (Remove debug logs):**
   - بعد التأكد من أن كل شيء يعمل، يمكن إزالة console.log/print statements

## ملاحظات (Notes)

- الأسئلة المخصصة القديمة لن تتأثر (فقط الوظائف الجديدة)
- Old custom questions won't be affected (only new jobs)

- نموذج Job يدعم customQuestions بالفعل، كان المشكلة فقط في عدم حفظها
- The Job model already supports customQuestions, the problem was just not saving them

- الكود يدعم إرسال customQuestions كـ array أو string (JSON)
- The code supports sending customQuestions as array or string (JSON)
