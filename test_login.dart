import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = 'http://192.168.1.7:5000/api';
  const String email = 'baraawael7901@gmail.com';
  const String password = 'password123';

  print('🔐 Attempting login with:');
  print('Email: $email');
  print('Password: $password');
  print('URL: $baseUrl/auth/login');

  try {
    final response = await http
        .post(
          Uri.parse('$baseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 10));

    print('\n📊 Response Status: ${response.statusCode}');
    print('📝 Response Body:');
    print(response.body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('\n✅ Login successful!');
      print('User Role: ${data['user']?['role']}');
      print('Token: ${data['token']?.substring(0, 50)}...');
    } else {
      print('\n❌ Login failed');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}
