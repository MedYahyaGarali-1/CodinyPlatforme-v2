import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/session/session_controller.dart';
import '../../../data/repositories/school_repository.dart';
import '../../../data/models/school/school_student.dart';

class SchoolExamReviewScreen extends StatefulWidget {
  final SchoolStudent student;
  final String examId;

  const SchoolExamReviewScreen({
    super.key,
    required this.student,
    required this.examId,
  });

  @override
  State<SchoolExamReviewScreen> createState() => _SchoolExamReviewScreenState();
}

class _SchoolExamReviewScreenState extends State<SchoolExamReviewScreen> {
  final SchoolRepository _schoolRepo = SchoolRepository();
  
  bool _isLoading = true;
  String? _error;
  
  Map<String, dynamic>? _exam;
  List<dynamic> _answers = [];
  int _currentIndex = 0;
  String _filter = 'all'; // all, correct, wrong

  @override
  void initState() {
    super.initState();
    _loadExamDetails();
  }

  Future<void> _loadExamDetails() async {
    try {
      final token = context.read<SessionController>().token;
      if (token == null) throw Exception('Not authenticated');

      final data = await _schoolRepo.getStudentExamDetails(
        token: token,
        studentId: widget.student.id.toString(),
        examId: widget.examId,
      );

      setState(() {
        _exam = data['exam'] as Map<String, dynamic>;
        _answers = data['answers'] as List<dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load exam details: $e';
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _filteredAnswers {
    if (_filter == 'correct') {
      return _answers.where((a) => a['is_correct'] == true).toList();
    } else if (_filter == 'wrong') {
      return _answers.where((a) => a['is_correct'] == false).toList();
    }
    return _answers;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('${widget.student.name} - Exam Review'),
        backgroundColor: colorScheme.surface,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Summary Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary,
                            colorScheme.secondary,
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatCard(
                                'Score',
                                '${_exam!['score'].toStringAsFixed(1)}%',
                                _exam!['passed'] ? Colors.green : Colors.red,
                              ),
                              _buildStatCard(
                                'Correct',
                                '${_exam!['correct_answers']}/${_exam!['total_questions']}',
                                Colors.green,
                              ),
                              _buildStatCard(
                                'Wrong',
                                '${_exam!['wrong_answers']}',
                                Colors.red,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _exam!['passed'] ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _exam!['passed'] ? 'PASSED ✓' : 'FAILED ✗',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Filter Buttons
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildFilterButton('All', 'all', _answers.length),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildFilterButton(
                              'Correct',
                              'correct',
                              _answers.where((a) => a['is_correct'] == true).length,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildFilterButton(
                              'Wrong',
                              'wrong',
                              _answers.where((a) => a['is_correct'] == false).length,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Question List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredAnswers.length,
                        itemBuilder: (context, index) {
                          final answer = _filteredAnswers[index];
                          return _buildQuestionCard(answer, index);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton(String label, String filterValue, int count) {
    final isSelected = _filter == filterValue;
    final theme = Theme.of(context);
    
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _filter = filterValue;
          _currentIndex = 0;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceVariant,
        foregroundColor: isSelected
            ? Colors.white
            : theme.colorScheme.onSurfaceVariant,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            '($count)',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> answer, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCorrect = answer['is_correct'] == true;
    final studentAnswer = answer['student_answer'] as String?;
    final correctAnswer = answer['correct_answer'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCorrect ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Question Number
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCorrect ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${answer['question_number']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          color: isCorrect ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isCorrect ? 'CORRECT' : 'WRONG',
                          style: TextStyle(
                            color: isCorrect ? Colors.green.shade800 : Colors.red.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Question Text
            Text(
              answer['question_text'] ?? 'Question',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            // Traffic Sign Image (if exists)
            if (answer['image_url'] != null && answer['image_url'] != '') ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  answer['image_url'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Options
            _buildOption('A', answer['option_a'], studentAnswer, correctAnswer),
            const SizedBox(height: 8),
            _buildOption('B', answer['option_b'], studentAnswer, correctAnswer),
            const SizedBox(height: 8),
            _buildOption('C', answer['option_c'], studentAnswer, correctAnswer),
            
            // Explanation (if available)
            if (answer['explanation'] != null && answer['explanation'] != '') ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        answer['explanation'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    String letter,
    String? text,
    String? studentAnswer,
    String correctAnswer,
  ) {
    final isStudentAnswer = letter == studentAnswer;
    final isCorrectAnswer = letter == correctAnswer;
    
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? icon;
    
    if (isCorrectAnswer) {
      backgroundColor = Colors.green.shade50;
      borderColor = Colors.green;
      textColor = Colors.green.shade900;
      icon = Icons.check_circle;
    } else if (isStudentAnswer) {
      backgroundColor = Colors.red.shade50;
      borderColor = Colors.red;
      textColor = Colors.red.shade900;
      icon = Icons.cancel;
    } else {
      backgroundColor = Colors.grey.shade50;
      borderColor = Colors.grey.shade300;
      textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: isStudentAnswer || isCorrectAnswer ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCorrectAnswer || isStudentAnswer
                  ? borderColor
                  : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                letter,
                style: TextStyle(
                  color: isCorrectAnswer || isStudentAnswer
                      ? Colors.white
                      : Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text ?? '',
              style: TextStyle(
                fontSize: 15,
                color: textColor,
                fontWeight: isStudentAnswer || isCorrectAnswer
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 8),
            Icon(icon, color: borderColor, size: 20),
          ],
        ],
      ),
    );
  }
}
