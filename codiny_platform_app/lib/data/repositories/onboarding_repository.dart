import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student/student_access.dart';

class OnboardingRepository {
  final String baseUrl;

  OnboardingRepository({this.baseUrl = 'http://localhost:3000'});

  /// Get student's current access status
  Future<AccessStatusResponse> getAccessStatus({required String token}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/students/me/access'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return AccessStatusResponse.fromJson(data);
    } else {
      throw Exception('Failed to load access status: ${response.body}');
    }
  }

  /// Choose access method (independent or school_linked)
  Future<Map<String, dynamic>> chooseAccessMethod({
    required String token,
    required String accessMethod, // 'independent' or 'school_linked'
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/students/onboarding/choose-method'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'access_method': accessMethod,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to choose access method: ${response.body}');
    }
  }

  /// Link student to a school
  Future<Map<String, dynamic>> linkSchool({
    required String token,
    required String schoolId,
    required String schoolName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/students/onboarding/link-school'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'school_id': schoolId,
        'school_name': schoolName,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to link school: ${response.body}');
    }
  }

  /// Complete payment and activate subscription
  Future<Map<String, dynamic>> completePayment({
    required String token,
    required String paymentId,
    required String subscriptionType, // 'monthly', 'yearly', 'lifetime'
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/students/onboarding/complete-payment'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'payment_id': paymentId,
        'subscription_type': subscriptionType,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to complete payment: ${response.body}');
    }
  }

  /// Get school request status
  Future<Map<String, dynamic>> getSchoolRequestStatus({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/students/me/school-request-status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get school request status: ${response.body}');
    }
  }

  /// Change access method
  Future<Map<String, dynamic>> changeAccessMethod({
    required String token,
    required String newMethod, // 'independent' or 'school_linked'
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/students/change-access-method'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'new_method': newMethod,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to change access method: ${response.body}');
    }
  }

  /// Choose permit type (A, B, or C)
  Future<Map<String, dynamic>> choosePermitType({
    required String token,
    required String permitType, // 'A', 'B', or 'C'
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/students/onboarding/choose-permit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'permit_type': permitType,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to choose permit type: ${response.body}');
    }
  }
}
