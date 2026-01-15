import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../../core/config/environment.dart';
import '../../main.dart';

class ApiService {
  final http.Client _client = http.Client();

  /// Handle authentication errors by redirecting to login
  void _handleAuthError(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      // Token expired or invalid - redirect to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = navigatorKey.currentContext;
        if (context != null) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      });
    }
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final uri = Uri.parse('${Environment.baseUrl}$path');

    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body ?? {}),
    );

    final contentType = response.headers['content-type'] ?? '';
    final rawBody = response.body;

    if (!contentType.contains('application/json')) {
      final preview = rawBody.length <= 300
          ? rawBody
          : rawBody.substring(0, min(300, rawBody.length));
      throw Exception(
        'Expected JSON from $uri but received: ${response.statusCode}\n$preview',
      );
    }

    final decoded = jsonDecode(rawBody);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    // Handle authentication errors
    _handleAuthError(response.statusCode);

    if (decoded is Map && decoded['message'] != null) {
      throw Exception(decoded['message']);
    }
    throw Exception('Request failed (${response.statusCode})');
  }

  Future<dynamic> get(
    String path, {
    String? token,
  }) async {
    final uri = Uri.parse('${Environment.baseUrl}$path');
    final headers = <String, String>{
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    // ignore: avoid_print
    print('GET $uri');

    final res = await _client.get(uri, headers: headers);

    final contentType = res.headers['content-type'] ?? '';
    final body = res.body;

    // ignore: avoid_print
    print('GET $uri -> ${res.statusCode} $contentType');

    if (!contentType.contains('application/json')) {
      final preview = body.length <= 300 ? body : body.substring(0, min(300, body.length));
      throw Exception('Expected JSON from $uri but received: ${res.statusCode}\n$preview');
    }

    final decoded = jsonDecode(body);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      // ignore: avoid_print
      print('GET $uri -> body: $decoded');
      return decoded;
    }

    // Handle authentication errors
    _handleAuthError(res.statusCode);

    if (decoded is Map && decoded['message'] != null) {
      throw Exception(decoded['message']);
    }

    throw Exception('Request failed (${res.statusCode})');
  }
}