# Job Compass - Complete App Flow & Integration Guide

## 🎯 App Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         APP STARTUP                              │
│  1. Initialize API Service                                      │
│  2. Load stored token from SharedPreferences                    │
│  3. Check authentication status                                 │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    STUDENT DASHBOARD (HOME)                      │
│  • API: GET /student/dashboard                                  │
│  • Shows: Welcome, Stats, Top 3 Jobs, Quick Actions            │
│                                                                  │
│  Quick Actions:                                                 │
│  ┌──────────┬──────────┐  ┌──────────┬──────────┐            │
│  │Upload CV │ Analyze  │  │Learning  │   Job    │            │
│  │          │  Skills  │  │  Path    │ Matches  │            │
│  └────┬─────┴────┬─────┘  └────┬─────┴────┬─────┘            │
└───────┼──────────┼─────────────┼──────────┼───────────────────┘
        │          │             │          │
        ↓          ↓             ↓          ↓
┌───────────┐ ┌────────────┐ ┌──────────┐ ┌────────────┐
│ PROFILE & │ │   SKILL    │ │ LEARNING │ │    JOB     │
│    CV     │ │  ANALYSIS  │ │   PATH   │ │  MATCHES   │
└─────┬─────┘ └────────────┘ └──────────┘ └─────┬──────┘
      │                                          │
      ↓                                          ↓
┌────────────┐                           ┌─────────────┐
│  SETTINGS  │                           │ JOB DETAILS │
└────────────┘                           └──────┬──────┘
                                                │
                                                ↓
                                         ┌─────────────┐
                                         │  SKILL GAP  │
                                         │  ANALYSIS   │
                                         └──────┬──────┘
                                                │
                                                ↓
                                         ┌─────────────┐
                                         │  LEARNING   │
                                         │    PATH     │
                                         └─────────────┘
```

---

## 📱 Screen-by-Screen Flow

### Screen 1: Student Dashboard

**Entry Point**: Main home after login

**User Actions**:

1. View profile completion → Navigate to Profile
2. See skill match score → Navigate to Skills Analysis
3. Tap job card → Navigate to Job Details
4. Click "Upload CV" → Navigate to Profile
5. Click "Analyze Skills" → Navigate to Skills Analysis
6. Click "Learning Path" → Navigate to Learning Path
7. Click "Job Matches" → Navigate to Job Matches
8. Tap notification bell → Navigate to Notifications

**Data Loaded**:

- Student info (name, email, profile pic)
- Profile completion %
- Skill match score
- Top 3 matched jobs
- Total job matches count
- Total skills count

---

### Screen 2: Profile & CV Management

**Navigation From**: Dashboard, Settings

**User Actions**:

1. Upload PDF CV → Opens file picker → Uploads to server
2. Update existing CV → Same as upload
3. View extracted skills → Shows first 10 skills
4. Click "View All" → Navigate to Skills Analysis
5. Click settings icon → Navigate to Settings

**Data Loaded**:

- Personal information
- CV status (uploaded/not uploaded)
- Upload date
- Extracted skills preview

---

### Screen 3: Skill Analysis

**Navigation From**: Dashboard, Profile

**User Actions**:

1. Filter by category (All/Technical/Soft) → Updates list
2. View skill details → Shows proficiency, level, explanation
3. Pull to refresh → Reloads skills

**Data Loaded**:

- All extracted skills
- Technical skills list
- Soft skills list
- Skill proficiency (0-100%)
- Skill levels (Beginner/Intermediate/Advanced)
- AI-generated explanations

---

### Screen 4: Job Matches

**Navigation From**: Dashboard

**User Actions**:

1. Sort by match/salary/date → Reorders list
2. Tap job card → Navigate to Job Details (with jobId)
3. Pull to refresh → Reloads matches

**Data Loaded**:

- All matched jobs
- Match percentages
- Job details (title, company, salary, etc.)
- Average match score

---

### Screen 5: Job Details

**Navigation From**: Job Matches, Dashboard

**User Actions**:

1. Bookmark job → Saves job locally
2. Click "View Gap" → Navigate to Skill Gap Analysis (with jobId)
3. Click "Apply Now" → Shows success message
4. Back → Returns to Job Matches

**Data Loaded**:

- Complete job information
- Required skills
- Match score
- Missing skills count
- Job description

---

### Screen 6: Skill Gap Analysis

**Navigation From**: Job Details

**User Actions**:

1. View skill comparisons → See required vs current levels
2. Review missing skills → See what to learn
3. Read suggestions → Get improvement tips
4. Click "View Learning Path" → Navigate to Learning Path

**Data Loaded**:

- Overall match percentage
- Skill-by-skill comparison
- Required vs current proficiency
- Missing skills list
- AI improvement suggestions

---

### Screen 7: Learning Path

**Navigation From**: Dashboard, Skill Gap Analysis

**User Actions**:

1. View weekly modules → See organized learning path
2. Tap course → Opens external URL (YouTube/Coursera/Udemy)
3. Mark module complete → Updates progress
4. Pull to refresh → Reloads path

**Data Loaded**:

- AI-generated learning modules
- Weekly organization
- Course recommendations
- Platform links
- Difficulty levels
- Duration estimates

---

### Screen 8: Interview Preparation

**Navigation From**: Dashboard

**User Actions**:

1. Start session → Begins interview simulation
2. Answer questions → Type responses
3. Submit answers → Get AI feedback
4. View feedback → See strengths/weaknesses
5. Start new session → Repeat practice

**Data Loaded**:

- Interview questions
- AI responses
- Performance feedback
- Overall score
- Strengths & weaknesses

---

### Screen 9: Notifications

**Navigation From**: Dashboard (bell icon)

**User Actions**:

1. Tap notification → Navigate to related screen
2. Mark all as read → Updates read status
3. Pull to refresh → Loads new notifications

**Data Loaded**:

- Job match notifications
- Learning path updates
- Interview reminders
- Read/unread status
- Timestamps

---

### Screen 10: Settings

**Navigation From**: Profile

**User Actions**:

1. Edit profile → Navigate to Profile
2. Change password → Shows dialog
3. Select language → Updates app language
4. Toggle notifications → Updates preferences
5. Logout → Clears token, returns to login
6. Delete account → Shows confirmation

**Data Loaded**:

- Current settings
- Language preference
- Notification preferences

---

## 🔄 Data Flow

### 1. API Service Layer

```dart
ApiService (Singleton)
  ├─ Token Management
  │   ├─ initToken() - Load from storage
  │   ├─ saveToken() - Save to SharedPreferences
  │   └─ clearToken() - Remove on logout
  ├─ HTTP Methods
  │   ├─ get()
  │   ├─ post()
  │   ├─ put()
  │   ├─ delete()
  │   └─ uploadFile() - For CV upload
  └─ Endpoints
      ├─ getStudentDashboard()
      ├─ getStudentProfile()
      ├─ uploadCV()
      ├─ getSkillsAnalysis()
      ├─ getJobMatches()
      ├─ getJobDetails()
      ├─ getSkillGap()
      ├─ getLearningPath()
      ├─ startInterviewSession()
      └─ getNotifications()
```

### 2. State Management Flow

```dart
Screen Load
  ↓
setState({ isLoading: true })
  ↓
API Call (try-catch)
  ↓
Success → Parse JSON → Update Models → setState({ data, isLoading: false })
  ↓
Error → setState({ error, isLoading: false }) → Show Error Screen
```

### 3. Error Handling Pattern

```dart
try {
  final response = await _apiService.method();
  setState(() {
    _data = Model.fromJson(response);
    _isLoading = false;
  });
} catch (e) {
  setState(() {
    _error = e.toString();
    _isLoading = false;
  });
}
```

---

## 🎨 UI Component Hierarchy

```
GradientBackground
  └─ LoadingOverlay
      └─ SafeArea
          └─ Column
              ├─ AppBar (custom)
              └─ Content
                  ├─ GlassCard
                  │   ├─ Headers
                  │   ├─ Stats
                  │   └─ Data
                  ├─ PrimaryButton
                  └─ Lists
```

---

## 📦 Dependencies Usage

### 1. http (^1.1.0)

- All API calls
- GET, POST, PUT, DELETE
- Multipart file upload

### 2. shared_preferences (^2.2.2)

- Token storage
- User preferences
- Language selection

### 3. file_picker (^6.1.1)

- CV upload (PDF only)
- File selection dialog

### 4. url_launcher (^6.2.2)

- Open course URLs
- External links (Coursera, YouTube, Udemy)

---

## 🔐 Authentication Flow

```
1. User logs in
   ↓
2. Backend returns token
   ↓
3. ApiService.saveToken(token)
   ↓
4. Token stored in SharedPreferences
   ↓
5. All API calls include: Authorization: Bearer {token}
   ↓
6. User logs out
   ↓
7. ApiService.clearToken()
   ↓
8. Token removed from storage
   ↓
9. Navigate to login screen
```

---

## 📱 Navigation Routes

```dart
// Add to main.dart
MaterialApp(
  routes: {
    '/dashboard': (_) => StudentDashboardScreen(),
    '/profile': (_) => ProfileCVScreen(),
    '/skills-analysis': (_) => SkillAnalysisScreen(),
    '/job-matches': (_) => JobMatchesScreen(),
    '/learning-path': (_) => LearningPathScreen(),
    '/interview-prep': (_) => InterviewPrepScreen(),
    '/notifications': (_) => NotificationsScreen(),
    '/settings': (_) => SettingsScreen(),
  },
  onGenerateRoute: (settings) {
    if (settings.name == '/job-details') {
      final jobId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (_) => JobDetailsScreen(jobId: jobId),
      );
    }
    if (settings.name == '/skill-gap') {
      final jobId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (_) => SkillGapScreen(jobId: jobId),
      );
    }
    return null;
  },
)
```

---

## ✅ Testing Checklist

### Per Screen:

- [ ] Loads without errors
- [ ] API call succeeds
- [ ] Data displays correctly
- [ ] Loading state shows
- [ ] Error state shows (on network error)
- [ ] Empty state shows (on no data)
- [ ] Navigation works
- [ ] Pull-to-refresh works
- [ ] UI matches design

### Overall:

- [ ] Token persists across app restarts
- [ ] Logout clears token
- [ ] All navigation routes work
- [ ] File upload works
- [ ] External URLs open
- [ ] Settings persist

---

## 🚀 Deployment Steps

1. **Update Backend URL**:

   ```dart
   static const String baseUrl = 'http://YOUR_BACKEND_IP:3000/api';
   ```

2. **Test All Screens**:

   - Run through complete user journey
   - Test error cases
   - Verify API responses

3. **Build APK**:

   ```bash
   flutter build apk --release
   ```

4. **Test on Device**:
   - Install APK
   - Test all features
   - Check performance

---

**🎉 Complete Implementation Ready for Production!**
