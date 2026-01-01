import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/environment.dart';
import '../models/exam/exam_models.dart';

class ExamRepository {
  final String baseUrl = Environment.baseUrl;

  Future<Map<String, dynamic>> getExamQuestions(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/exams/questions'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'questions': (data['questions'] as List)
            .map((q) => ExamQuestion.fromJson(q))
            .toList(),
        'time_limit_minutes': data['time_limit_minutes'],
        'passing_score': data['passing_score'],
      };
    } else {
      throw Exception('Failed to fetch exam questions');
    }
  }

  Future<ExamSession> startExam(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/exams/start'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ExamSession.fromJson(data['session']);
    } else {
      throw Exception('Failed to start exam');
    }
  }

  Future<Map<String, dynamic>> submitExam({
    required String token,
    required String sessionId,
    required List<ExamAnswer> answers,
    required int timeTakenSeconds,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/exams/submit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'session_id': sessionId,
        'answers': answers.map((a) => a.toJson()).toList(),
        'time_taken_seconds': timeTakenSeconds,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['result'];
    } else {
      throw Exception('Failed to submit exam');
    }
  }

  Future<List<ExamResult>> getExamHistory(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/exams/history'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['exams'] as List)
          .map((e) => ExamResult.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to fetch exam history');
    }
  }

  Future<Map<String, dynamic>> getExamDetails(String token, String examId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/exams/$examId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'exam': ExamResult.fromJson(data['exam']),
        'answers': (data['answers'] as List)
            .map((a) => ExamDetailedAnswer.fromJson(a))
            .toList(),
      };
    } else {
      throw Exception('Failed to fetch exam details');
    }
  }
}
