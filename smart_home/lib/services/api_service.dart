import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // اضافه کردن پکیج

class ApiService {
  static const String baseUrl = 'http://172.23.68.166:8180';
  static String username = '';
  static String password = '';

  // متد بررسی اتصال اینترنت (چندپلتفرمی)
  static Future<bool> _checkInternet() async {
    if (kIsWeb) {
      // نسخه وب
      return true;
    } else {
      // نسخه موبایل/دسکتاپ
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        // بررسی وجود اتصال Wi-Fi یا داده موبایل
        if (connectivityResult.contains(ConnectivityResult.mobile) ||
            connectivityResult.contains(ConnectivityResult.wifi)) {
         return true;
        }
        return false;
      } catch (e) {
        return false;
      }
    }
  }

  // متد اصلی ارسال درخواست
  static Future<dynamic> _sendRequest({
    required String endpoint,
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    // بررسی اتصال اینترنت
    if (!await _checkInternet()) {
      throw Exception('اتصال اینترنت برقرار نیست');
    }

    final uri = Uri.parse('$baseUrl/$endpoint');
    final headers = {
      'Authorization': 'Basic ${base64Encode(utf8.encode('$username:$password'))}',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      late http.Response response;
      final stopwatch = Stopwatch()..start();

      if (method == 'POST') {
        print('API Request: POST $uri\nBody: ${body ?? '{}'}');
        response = await http.post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(const Duration(seconds: 30));
      } else {
        print('API Request: GET $uri');
        response = await http.get(
          uri,
          headers: headers,
        ).timeout(const Duration(seconds: 30));
      }

      print('API Response (${stopwatch.elapsedMilliseconds}ms): ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final decoded = jsonDecode(response.body);
          return decoded is List ? decoded : _convertToMap(decoded);
        } catch (e) {
          return response.body;
        }
      } else if (response.statusCode == 401) {
        throw Exception('احراز هویت ناموفق - نام کاربری یا رمز عبور اشتباه است');
      } else {
        throw Exception('خطای سرور: کد وضعیت ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('زمان انتظار به پایان رسید');
    } on http.ClientException catch (e) {
      throw Exception('خطا در ارتباط با سرور: ${e.message}');
    } catch (e) {
      throw Exception('خطای ناشناخته: $e');
    }
  }

  // تست اعتبارسنجی (بهینه‌شده)
  static Future<bool> testCredentials({
    required String testUsername,
    required String testPassword,
  }) async {
    try {
      final tempUsername = username;
      final tempPassword = password;

      username = testUsername;
      password = testPassword;

      final response = await _sendRequest(endpoint: 'statistics');

      // ذخیره اعتبارات فقط در صورت موفقیت
      return true;
    } on Exception catch (e) {
      username = '';
      password = '';
      if (e.toString().contains('احراز هویت ناموفق')) {
        return false;
      }
      rethrow;
    }
  }

  // تبدیل پاسخ به Map
  static Map<String, dynamic> _convertToMap(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return {};
  }

  // سایر متدهای API
  static Future<Map<String, dynamic>> getStatus() async {
    final response = await _sendRequest(endpoint: 'statistics');
    return _convertToMap(response);
  }

  static Future<List<dynamic>> getLogs() async {
    final response = await _sendRequest(endpoint: 'logs');
    return response is List ? response : [];
  }

  static Future<Map<String, dynamic>> setTime(DateTime newTime) async {
    return await _sendRequest(
      endpoint: 'settime',
      method: 'POST',
      body: {
        'year': newTime.year,
        'month': newTime.month,
        'day': newTime.day,
        'hour': newTime.hour,
        'minute': newTime.minute,
        'second': newTime.second,
      },
    );
  }

  static Future<Map<String, dynamic>> sendConfig(Map<String, dynamic> config) async {
    if (config.isEmpty) {
      throw Exception('تنظیمات نمی‌تواند خالی باشد');
    }
    return await _sendRequest(
      endpoint: 'config',
      method: 'POST',
      body: config,
    );
  }

  static Future<Map<String, dynamic>> reboot() async {
    return await _sendRequest(
      endpoint: 'reboot',
      method: 'POST',
    );
  }
}