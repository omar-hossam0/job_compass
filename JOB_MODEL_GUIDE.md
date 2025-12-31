# 📁 Job Model - دليل استخدام موديل الوظائف

## 📍 موقع الملف
`lib/models/job.dart`

## 📝 الوصف
موديل Job هو الموديل المسؤول عن تمثيل بيانات الوظائف في التطبيق. يستخدم في:
- عرض الوظائف في Job Matches
- تفاصيل الوظيفة
- Dashboard
- التقديم على الوظائف

## 🎯 الخصائص الرئيسية

### معلومات أساسية
- `id`: معرف الوظيفة
- `title`: عنوان الوظيفة
- `company`: اسم الشركة
- `companyLogo`: شعار الشركة (optional)
- `description`: وصف الوظيفة
- `location`: الموقع

### معلومات التوظيف
- `employmentType`: نوع التوظيف (Full-time, Part-time, Remote, etc.)
- `salary`: الراتب
- `salaryPeriod`: فترة الراتب (/year, /month)
- `experienceYears`: سنوات الخبرة المطلوبة

### التطابق والمهارات
- `requiredSkills`: المهارات المطلوبة
- `matchScore`: نسبة التطابق مع السيرة الذاتية (0-100)
- `missingSkillsCount`: عدد المهارات الناقصة

### معلومات إضافية
- `postedAt`: تاريخ نشر الوظيفة
- `applicantsCount`: عدد المتقدمين
- `customQuestions`: الأسئلة المخصصة من HR

## 🔧 الدوال المساعدة (Helper Methods)

### 1. formattedSalary
```dart
String formattedSalary
```
تنسيق الراتب بشكل قابل للقراءة:
- `$50k/year` للرواتب الكبيرة
- `$500/month` للرواتب الصغيرة
- `Negotiable` إذا كان الراتب 0

### 2. matchLevel
```dart
String matchLevel
```
تحديد مستوى التطابق:
- `Excellent` - 80% فأكثر
- `Good` - 60-79%
- `Fair` - 40-59%
- `Low` - أقل من 40%

### 3. isRecent
```dart
bool isRecent
```
التحقق من أن الوظيفة حديثة (أقل من 7 أيام)

### 4. formattedPostedDate
```dart
String formattedPostedDate
```
تنسيق تاريخ النشر:
- `5m ago` - منذ دقائق
- `3h ago` - منذ ساعات
- `2d ago` - منذ أيام
- `1w ago` - منذ أسابيع
- `2mo ago` - منذ شهور

## 💻 أمثلة الاستخدام

### استيراد الموديل
```dart
import '../models/job.dart';
// أو
import '../models/student.dart'; // يستورد Job تلقائياً
```

### إنشاء Job من JSON
```dart
final job = Job.fromJson({
  '_id': '123',
  'title': 'Flutter Developer',
  'company': 'Tech Co',
  'description': 'Build amazing apps',
  'location': 'Cairo',
  'jobType': 'Full-time',
  'salary': {'min': 5000, 'max': 8000},
  'experienceLevel': 'Mid Level',
  'requiredSkills': ['Flutter', 'Dart', 'Firebase'],
  'matchScore': 85,
  'createdAt': '2025-12-31T10:00:00Z',
});
```

### استخدام الخصائص
```dart
print(job.title); // Flutter Developer
print(job.formattedSalary); // $5k/year
print(job.matchLevel); // Excellent
print(job.isRecent); // true
print(job.formattedPostedDate); // 2h ago
```

### تحويل إلى JSON
```dart
final json = job.toJson();
```

## 🔄 التوافق مع Backend

الموديل يدعم صيغ مختلفة من Backend:

### Salary
```json
// Object format
"salary": {"min": 5000, "max": 8000, "currency": "USD"}

// Number format
"salary": 5000
```

### Employment Type
```json
// Array format
"employmentType": ["Full-time", "Remote"]

// String format (jobType)
"jobType": "Full-time"
```

### Date Fields
```json
// postedAt
"postedAt": "2025-12-31T10:00:00Z"

// createdAt (fallback)
"createdAt": "2025-12-31T10:00:00Z"
```

### Experience
```json
// Years format
"experienceYears": 3

// Level format (auto-converted)
"experienceLevel": "Mid Level" // => 3 years
```

## 🎨 في واجهة المستخدم

### Job Card
```dart
JobCard(
  job: job,
  onTap: () {
    // Navigate to job details
  },
)
```

### عرض Match Score
```dart
Container(
  child: Text(
    '${job.matchScore}%',
    style: TextStyle(
      color: job.matchScore >= 70 
        ? Colors.green 
        : Colors.orange,
    ),
  ),
)
```

### عرض الراتب
```dart
Text(job.formattedSalary)
```

### عرض التاريخ
```dart
Text(job.formattedPostedDate)
```

## ⚠️ ملاحظات مهمة

1. **Null Safety**: الموديل يدعم null safety بشكل كامل
2. **Error Handling**: في حالة فشل parsing، يتم إرجاع قيم افتراضية
3. **Flexible Parsing**: يدعم صيغ مختلفة من Backend
4. **Type Safety**: جميع الحقول محددة الأنواع

## 🔗 ملفات مرتبطة

- `lib/models/student.dart` - يستورد Job model
- `lib/screens/job_matches_screen.dart` - يعرض قائمة الوظائف
- `lib/screens/job_details_screen.dart` - يعرض تفاصيل وظيفة
- `lib/widgets/job_card.dart` - كارت الوظيفة
- `lib/screens/student_dashboard_screen.dart` - Dashboard

## 📊 مثال كامل

```dart
import 'package:flutter/material.dart';
import '../models/job.dart';

class JobExample extends StatelessWidget {
  final Job job;

  const JobExample({required this.job});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text(job.title, style: TextStyle(fontSize: 20)),
          Text(job.company),
          Text(job.formattedSalary),
          Text('${job.matchScore}% Match'),
          Text(job.matchLevel),
          Text(job.formattedPostedDate),
          if (job.isRecent)
            Chip(label: Text('New')),
          Wrap(
            children: job.requiredSkills
                .map((skill) => Chip(label: Text(skill)))
                .toList(),
          ),
        ],
      ),
    );
  }
}
```
