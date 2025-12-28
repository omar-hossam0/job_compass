import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Singleton pattern
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
  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Generic GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: _getHeaders())
          .timeout(const Duration(seconds: 10));

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
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getHeaders(),
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
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getHeaders(),
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
      final response = await http
          .delete(Uri.parse('$baseUrl$endpoint'), headers: _getHeaders())
          .timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Handle response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {'success': true, ...data};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Request failed'};
    }
  }

  // File upload
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    File file, {
    String fieldName = 'cv',
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );

      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }

      request.files.add(
        await http.MultipartFile.fromPath(fieldName, file.path),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Upload error: ${e.toString()}'};
    }
  }

  // ============================================
  // AUTH ENDPOINTS
  // ============================================

  static Future<Map<String, dynamic>> register({
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

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String? role,
  }) async {
    try {
      print('🔐 Attempting login to: $baseUrl/auth/login');
      print('📧 Email: $email');

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 30));

      print('📊 Response status: ${response.statusCode}');
      print('📝 Response body: ${response.body}');

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
    } catch (e) {
      print('❌ Login error: ${e.toString()}');
      return {
        'success': false,
        'message': 'Connection error. Please check if the server is running.',
      };
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

  Future<Map<String, dynamic>> getHRProfile() async {
    return await get('/hr/profile');
  }

  Future<Map<String, dynamic>> updateHRProfile(
    Map<String, dynamic> data,
  ) async {
    return await put('/hr/profile', data);
  }
}
