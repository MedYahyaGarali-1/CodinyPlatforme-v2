class ExamQuestion {
  final String id;
  final int questionNumber;
  final String questionText;
  final String? imageUrl;
  final String optionA;
  final String optionB;
  final String optionC;

  ExamQuestion({
    required this.id,
    required this.questionNumber,
    required this.questionText,
    this.imageUrl,
    required this.optionA,
    required this.optionB,
    required this.optionC,
  });

  factory ExamQuestion.fromJson(Map<String, dynamic> json) {
    return ExamQuestion(
      id: json['id'],
      questionNumber: json['question_number'],
      questionText: json['question_text'],
      imageUrl: json['image_url'],
      optionA: json['option_a'],
      optionB: json['option_b'],
      optionC: json['option_c'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_number': questionNumber,
      'question_text': questionText,
      'image_url': imageUrl,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
    };
  }

  bool hasThreeOptions() {
    return optionC != 'N/A' && optionC.isNotEmpty;
  }
}

class ExamSession {
  final String id;
  final DateTime startedAt;
  final int totalQuestions;

  ExamSession({
    required this.id,
    required this.startedAt,
    required this.totalQuestions,
  });

  factory ExamSession.fromJson(Map<String, dynamic> json) {
    return ExamSession(
      id: json['id'],
      startedAt: DateTime.parse(json['started_at']),
      totalQuestions: json['total_questions'],
    );
  }
}

class ExamResult {
  final String id;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final double score;
  final bool passed;
  final int timeTakenSeconds;

  ExamResult({
    required this.id,
    required this.startedAt,
    this.completedAt,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.score,
    required this.passed,
    required this.timeTakenSeconds,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      id: json['id'],
      startedAt: DateTime.parse(json['started_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      totalQuestions: json['total_questions'] ?? 0,
      correctAnswers: json['correct_answers'] ?? 0,
      wrongAnswers: json['wrong_answers'] ?? 0,
      score: json['score'] != null ? double.parse(json['score'].toString()) : 0.0,
      passed: json['passed'] ?? false,
      timeTakenSeconds: json['time_taken_seconds'] ?? 0,
    );
  }

  String getFormattedTime() {
    final minutes = timeTakenSeconds ~/ 60;
    final seconds = timeTakenSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String getGrade() {
    if (score >= 90) return 'ممتاز';
    if (score >= 80) return 'جيد جداً';
    if (score >= 76.67) return 'جيد';
    return 'راسب';
  }
}

class ExamAnswer {
  final String questionId;
  final String studentAnswer;

  ExamAnswer({
    required this.questionId,
    required this.studentAnswer,
  });

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'student_answer': studentAnswer,
    };
  }
}

class ExamDetailedAnswer {
  final String id;
  final String studentAnswer;
  final bool isCorrect;
  final DateTime answeredAt;
  final int questionNumber;
  final String questionText;
  final String? imageUrl;
  final String optionA;
  final String optionB;
  final String optionC;
  final String correctAnswer;

  ExamDetailedAnswer({
    required this.id,
    required this.studentAnswer,
    required this.isCorrect,
    required this.answeredAt,
    required this.questionNumber,
    required this.questionText,
    this.imageUrl,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.correctAnswer,
  });

  factory ExamDetailedAnswer.fromJson(Map<String, dynamic> json) {
    return ExamDetailedAnswer(
      id: json['id'],
      studentAnswer: json['student_answer'] ?? '',
      isCorrect: json['is_correct'] ?? false,
      answeredAt: DateTime.parse(json['answered_at']),
      questionNumber: json['question_number'],
      questionText: json['question_text'],
      imageUrl: json['image_url'],
      optionA: json['option_a'],
      optionB: json['option_b'],
      optionC: json['option_c'],
      correctAnswer: json['correct_answer'],
    );
  }
}
