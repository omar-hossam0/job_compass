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

  // Backend Base URLs
  static const List<String> _baseUrls = [
    'http://localhost:5000/api', // Localhost (for web & desktop dev)
    'http://192.168.1.39:5000/api', // LAN IP (for physical devices)
  ];

  // Dynamically determine the correct base URL
  static String get baseUrl {
    if (kIsWeb) return _baseUrls[0];
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:5000/api';
      if (Platform.isIOS) return 'http://localhost:5000/api';
    } catch (_) {}
    return _baseUrls[0];
  }

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

    if (_token == null) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
    }

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Generic GET request
  Future<Map<String, dynamic>> get(String endpoint, {Duration? timeout}) async {
    try {
      final headers = await _getHeaders();
      final timeoutDuration = timeout ??
          (endpoint.contains('job-matches')
              ? const Duration(seconds: 45)
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
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final result = Map<String, dynamic>.from(data);
        result['success'] = true;
        return result;
      } else {
        return {'success': false, 'message': data['message'] ?? 'Request failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Invalid server response'};
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

      if (_token == null) {
        final prefs = await SharedPreferences.getInstance();
        _token = prefs.getString('auth_token');
      }

      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }

      if (file is File) {
        request.files.add(
          await http.MultipartFile.fromPath(fieldName, file.path),
        );
      } else if (file is Uint8List) {
        request.files.add(
          http.MultipartFile.fromBytes(
            fieldName,
            file,
            filename: filename ?? 'upload.dat',
          ),
        );
      } else {
        throw Exception('Invalid file type');
      }

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

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    return await post('/auth/register', {
      'email': email,
      'password': password,
      'name': name,
      'role': role,
    });
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
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
          .timeout(const Duration(seconds: 15));

      final result = _handleResponse(response);

      if (result['success'] == true && result['token'] != null) {
        await saveToken(result['token']);
      }

      return result;
    } catch (e) {
      return {'success': false, 'message': 'Connection Error: Check if backend is running at $baseUrl'};
    }
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

  Future<Map<String, dynamic>> searchJobs(String query) async {
    return await get(
      '/student/jobs/search?query=${Uri.encodeComponent(query)}',
    );
  }

  Future<Map<String, dynamic>> getJobSuggestions(String query) async {
    return await get(
      '/student/jobs/suggestions?query=${Uri.encodeComponent(query)}',
    );
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

  Future<Map<String, dynamic>> getCandidateDetails(
    String candidateId, {
    String? jobId,
  }) async {
    final query = jobId != null ? '?jobId=$jobId' : '';
    return await get('/hr/candidates/$candidateId$query');
  }

  Future<Map<String, dynamic>> saveCandidate(
    String candidateId, {
    String? jobId,
    String? notes,
  }) async {
    return await post('/hr/candidates/$candidateId/save', {
      if (jobId != null) 'jobId': jobId,
      if (notes != null) 'notes': notes,
    });
  }

  Future<Map<String, dynamic>> unsaveCandidate(String candidateId) async {
    return await delete('/hr/candidates/$candidateId/save');
  }

  Future<Map<String, dynamic>> getSavedCandidates() async {
    return await get('/hr/saved-candidates');
  }

  Future<Map<String, dynamic>> getHRNotifications() async {
    return await get('/hr/notifications');
  }

  Future<Map<String, dynamic>> markNotificationAsRead(
    String notificationId,
  ) async {
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

  Future<Map<String, dynamic>> matchCVsToJob(String jobId) async {
    return await post('/ml/match-cvs', {'jobId': jobId});
  }

  // ============================================
  // ML / ANALYSIS ENDPOINTS
  // ============================================

  Future<Map<String, dynamic>> analyzeJobForUser(String jobId) async {
    return await get(
      '/ml/analyze-job/$jobId',
      timeout: const Duration(seconds: 30),
    );
  }

  // ============================================
  // CHAT ENDPOINTS
  // ============================================

  Future<Map<String, dynamic>> startChat({
    required String candidateId,
    required String jobId,
  }) async {
    return await post('/chat/start', {
      'candidateId': candidateId,
      'jobId': jobId,
    });
  }

  Future<Map<String, dynamic>> getHRChats() async {
    return await get('/chat/hr');
  }

  Future<Map<String, dynamic>> getCandidateChats() async {
    return await get('/chat/candidate');
  }

  Future<Map<String, dynamic>> getChatMessages(String chatId) async {
    return await get('/chat/$chatId');
  }

  Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String content,
  }) async {
    return await post('/chat/$chatId/message', {'content': content});
  }

  Future<Map<String, dynamic>> updateApplicationStatus({
    required String candidateId,
    required String jobId,
    required String status,
    String? notes,
  }) async {
    return await put('/chat/application/$candidateId/$jobId/status', {
      'status': status,
      if (notes != null) 'notes': notes,
    });
  }
}
