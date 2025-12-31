import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Backend Base URLs (primary LAN IP, fallback localhost for local testing)
  static const List<String> baseUrls = [
    'http://localhost:5000/api', // Localhost (for web & desktop dev)
    'http://192.168.1.7:5000/api', // LAN IP (for physical devices)
  ];

  // Backwards-compatible single baseUrl getter used by existing methods
  static String get baseUrl => baseUrls.first;

  String? _token;

  // Initialize token from storage
  Future<void> initToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  // Save token to storage
  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear token
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Get headers with token
  Future<Map<String, String>> _getHeaders() async {
    final headers = {'Content-Type': 'application/json'};

    // Load token from storage if not in memory
    if (_token == null) {
      print('🔄 Token not in memory, loading from storage...');
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      print(
        '📦 Token from storage: ${_token != null ? _token!.substring(0, 20) + "..." : "null"}',
      );
    } else {
      print('✓ Token already in memory: ${_token!.substring(0, 20)}...');
    }

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
      print('🔐 Authorization header added');
    } else {
      print('⚠️ No token available!');
    }
    return headers;
  }

  // Generic GET request
  Future<Map<String, dynamic>> get(String endpoint, {Duration? timeout}) async {
    try {
      final headers = await _getHeaders();
      // Use longer timeout for AI endpoints (job-matches needs time for BERT)
      final timeoutDuration =
          timeout ??
          (endpoint.contains('job-matches')
              ? const Duration(seconds: 60)
              : const Duration(seconds: 10));

      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Generic POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Generic PUT request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Generic DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Handle response
  Map<String, dynamic> _handleResponse(http.Response response) {
    print('📥 API Response Status: ${response.statusCode}');
    print('📥 API Response Body: ${response.body}');
    
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    print('📦 Decoded Data: $data');
    print('📦 Data type: ${data.runtimeType}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Merge data with success flag
      final result = Map<String, dynamic>.from(data);
      result['success'] = true;
      print('✅ Final result: $result');
      return result;
    } else {
      return {'success': false, 'message': data['message'] ?? 'Request failed'};
    }
  }

  // File upload
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    dynamic file, {
    String fieldName = 'cv',
    String? filename,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );

      debugPrint('📤 UPLOAD REQUEST:');
      debugPrint('  URL: $baseUrl$endpoint');

      // Load token from storage if not in memory
      if (_token == null) {
        final prefs = await SharedPreferences.getInstance();
        _token = prefs.getString('auth_token');
      }

      debugPrint('  Token present: ${_token != null}');

      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }

      // Support both File (mobile/desktop) and Uint8List (web)
      if (file is File) {
        request.files.add(
          await http.MultipartFile.fromPath(fieldName, file.path),
        );
      } else if (file is Uint8List) {
        // Determine MIME type from filename
        String mimeType = 'application/octet-stream';
        if (filename != null) {
          final ext = filename.toLowerCase().split('.').last;
          final mimeTypes = {
            'pdf': 'application/pdf',
            'doc': 'application/msword',
            'docx':
                'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'txt': 'text/plain',
            'rtf': 'application/rtf',
            'jpg': 'image/jpeg',
            'jpeg': 'image/jpeg',
            'png': 'image/png',
          };
          mimeType = mimeTypes[ext] ?? 'application/octet-stream';
        }

        debugPrint('  Filename: $filename');
        debugPrint('  MIME type: $mimeType');
        debugPrint('  File size: ${file.length} bytes');

        request.files.add(
          http.MultipartFile.fromBytes(
            fieldName,
            file,
            filename: filename ?? 'upload.dat',
            contentType: MediaType.parse(mimeType),
          ),
        );
      } else {
        throw Exception('Invalid file type');
      }

      debugPrint('  Sending multipart request...');
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('  Response status: ${response.statusCode}');
      debugPrint('  Response: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      return {'success': false, 'message': 'Upload error: ${e.toString()}'};
    }
  }

  // ============================================
  // AUTH ENDPOINTS
  // ============================================

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    return await _postWithFallback('/auth/register', {
      'email': email,
      'password': password,
      'name': name,
      'role': role,
    }, expectCreated: true);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      print('🔐 Attempting login to: $baseUrl/auth/login');
      print('📧 Email: $email');
      print('👤 Role: $role');

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              'role': role,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('📊 Response status: ${response.statusCode}');
      print('📝 Response body: ${response.body}');

      final result = _handleResponse(response);

      // Save token if login successful
      if (result['success'] == true && result['token'] != null) {
        print('💾 Saving token: ${result['token'].substring(0, 20)}...');
        await saveToken(result['token']);
        print('✅ Token saved successfully');
        print('🔑 Token in memory: ${_token?.substring(0, 20)}...');
      } else {
        print('❌ No token in response or login failed');
      }

      return result;
    } catch (e) {
      print('❌ Login error: ${e.toString()}');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Helper: try POST against each base URL until one succeeds
  static Future<Map<String, dynamic>> _postWithFallback(
    String endpoint,
    Map<String, dynamic> body, {
    bool expectOK = false,
    bool expectCreated = false,
  }) async {
    Exception? lastError;

    // Build an ordered list of base URLs depending on runtime.
    // Android emulators must use 10.0.2.2 to reach host localhost.
    final List<String> orderedBases = [];
    if (kIsWeb) {
      orderedBases.addAll(baseUrls);
    } else {
      try {
        if (Platform.isAndroid) {
          // prefer emulator loopback first
          orderedBases.add('http://10.0.2.2:5000/api');
        }
      } catch (_) {
        // Platform may not be available in some runtimes; fall back gracefully
      }
      // then add configured bases (LAN IP, localhost)
      for (final b in baseUrls) {
        if (!orderedBases.contains(b)) orderedBases.add(b);
      }
    }

    for (final base in orderedBases) {
      try {
        final uri = Uri.parse('$base$endpoint');
        final response = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 10));

        final data = jsonDecode(response.body);

        if ((expectOK && response.statusCode == 200) ||
            (expectCreated && response.statusCode == 201) ||
            (!expectOK &&
                !expectCreated &&
                response.statusCode >= 200 &&
                response.statusCode < 300)) {
          // Save token automatically if present
          if (data is Map && data['token'] != null) {
            await ApiService().saveToken(data['token']);
          }
          return {'success': true, ...data};
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Request failed',
          };
        }
      } on TimeoutException catch (e) {
        lastError = e;
        continue; // try next base URL
      } on SocketException catch (e) {
        lastError = e;
        continue; // try next base URL
      } catch (e) {
        lastError = Exception(e.toString());
        continue;
      }
    }

    return {
      'success': false,
      'message': lastError != null
          ? 'Error: ${lastError.toString()}'
          : 'Unknown error',
    };
  }

  // ============================================
  // STUDENT DASHBOARD ENDPOINTS
  // ============================================

  Future<Map<String, dynamic>> getStudentDashboard() async {
    return await get('/student/dashboard');
  }

  Future<Map<String, dynamic>> getStudentProfile() async {
    return await get('/student/profile');
  }

  Future<Map<String, dynamic>> uploadCV(File file) async {
    return await uploadFile('/student/upload-cv', file);
  }

  Future<Map<String, dynamic>> getSkillsAnalysis() async {
    return await get('/student/skills-analysis');
  }

  Future<Map<String, dynamic>> getJobMatches() async {
    return await get('/student/job-matches');
  }

  Future<Map<String, dynamic>> getJobDetails(String jobId) async {
    return await get('/jobs/$jobId');
  }

  Future<Map<String, dynamic>> applyToJob(
    String jobId,
    Map<String, dynamic> applicationData,
  ) async {
    return await post('/jobs/$jobId/apply', applicationData);
  }

  Future<Map<String, dynamic>> cancelApplication(String jobId) async {
    return await delete('/jobs/$jobId/cancel-application');
  }

  Future<Map<String, dynamic>> getSkillGap(String jobId) async {
    return await get('/student/skill-gap/$jobId');
  }

  Future<Map<String, dynamic>> getLearningPath() async {
    return await get('/student/learning-path');
  }

  Future<Map<String, dynamic>> startInterviewSession(
    Map<String, dynamic> data,
  ) async {
    return await post('/student/interview-session', data);
  }

  Future<Map<String, dynamic>> getNotifications() async {
    return await get('/student/notifications');
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    return await put('/student/profile', data);
  }

  Future<Map<String, dynamic>> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    return await put('/student/change-password', {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
  }

  // ============================================
  // HR DASHBOARD ENDPOINTS
  // ============================================

  Future<Map<String, dynamic>> getHRDashboard() async {
    return await get('/hr/dashboard');
  }

  Future<Map<String, dynamic>> getHRJobs() async {
    return await get('/hr/jobs');
  }

  Future<Map<String, dynamic>> createJob(Map<String, dynamic> jobData) async {
    return await post('/hr/jobs', jobData);
  }

  Future<Map<String, dynamic>> getJobById(String jobId) async {
    return await get('/hr/jobs/$jobId');
  }

  Future<Map<String, dynamic>> updateJob(
    String jobId,
    Map<String, dynamic> jobData,
  ) async {
    return await put('/hr/jobs/$jobId', jobData);
  }

  Future<Map<String, dynamic>> closeJob(String jobId) async {
    return await put('/hr/jobs/$jobId/close', {});
  }

  Future<Map<String, dynamic>> getJobCandidates(String jobId) async {
    return await get('/hr/jobs/$jobId/candidates');
  }

  Future<Map<String, dynamic>> getCandidateDetails(String candidateId) async {
    return await get('/hr/candidates/$candidateId');
  }

  Future<Map<String, dynamic>> saveCandidate(String candidateId) async {
    return await post('/hr/candidates/$candidateId/save', {});
  }

  Future<Map<String, dynamic>> getHRNotifications() async {
    return await get('/hr/notifications');
  }

  Future<Map<String, dynamic>> markNotificationAsRead(String notificationId) async {
    return await put('/notifications/$notificationId', {});
  }

  Future<Map<String, dynamic>> getHRProfile() async {
    return await get('/hr/profile');
  }

  Future<Map<String, dynamic>> updateHRProfile(
    Map<String, dynamic> data,
  ) async {
    return await put('/hr/profile', data);
  }

  // ============================================
  // ML / ANALYSIS ENDPOINTS
  // ============================================

  /// Analyze a specific job against user's CV
  /// Returns matched skills, missing skills with learning links, and match percentage
  Future<Map<String, dynamic>> analyzeJobForUser(String jobId) async {
    return await get('/ml/analyze-job/$jobId');
  }
}
