import 'package:flutter/material.dart';
import '../../data/models/exam/exam_models.dart';
import '../../data/repositories/exam_repository.dart';

class ExamReviewScreen extends StatefulWidget {
  final String token;
  final String examId;

  const ExamReviewScreen({
    Key? key,
    required this.token,
    required this.examId,
  }) : super(key: key);

  @override
  State<ExamReviewScreen> createState() => _ExamReviewScreenState();
}

class _ExamReviewScreenState extends State<ExamReviewScreen> {
  final ExamRepository _examRepo = ExamRepository();
  
  bool _isLoading = true;
  String? _error;
  
  ExamResult? _exam;
  List<ExamDetailedAnswer> _answers = [];
  int _currentIndex = 0;
  String _filter = 'all'; // all, correct, wrong

  @override
  void initState() {
    super.initState();
    _loadExamDetails();
  }

  Future<void> _loadExamDetails() async {
    try {
      final data = await _examRepo.getExamDetails(widget.token, widget.examId);
      setState(() {
        _exam = data['exam'] as ExamResult;
        _answers = data['answers'] as List<ExamDetailedAnswer>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'فشل تحميل تفاصيل الاختبار: $e';
        _isLoading = false;
      });
    }
  }

  List<ExamDetailedAnswer> get _filteredAnswers {
    if (_filter == 'correct') {
      return _answers.where((a) => a.isCorrect).toList();
    } else if (_filter == 'wrong') {
      return _answers.where((a) => !a.isCorrect).toList();
    }
    return _answers;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('جاري التحميل...', textDirection: TextDirection.rtl)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('خطأ', textDirection: TextDirection.rtl)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!, textDirection: TextDirection.rtl),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('رجوع', textDirection: TextDirection.rtl),
              ),
            ],
          ),
        ),
      );
    }

    final filteredAnswers = _filteredAnswers;
    if (filteredAnswers.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('مراجعة الإجابات', textDirection: TextDirection.rtl),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inbox, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'لا توجد أسئلة بهذا الفلتر',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _filter = 'all';
                    _currentIndex = 0;
                  });
                },
                child: const Text('عرض الكل', textDirection: TextDirection.rtl),
              ),
            ],
          ),
        ),
      );
    }

    final currentAnswer = filteredAnswers[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('مراجعة الإجابات', textDirection: TextDirection.rtl),
            Text(
              'السؤال ${_currentIndex + 1}/${filteredAnswers.length}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filter = value;
                _currentIndex = 0;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(
                      _filter == 'all' ? Icons.check : Icons.circle_outlined,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('كل الأسئلة', textDirection: TextDirection.rtl),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'correct',
                child: Row(
                  children: [
                    Icon(
                      _filter == 'correct' ? Icons.check : Icons.circle_outlined,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('الصحيحة فقط', textDirection: TextDirection.rtl),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'wrong',
                child: Row(
                  children: [
                    Icon(
                      _filter == 'wrong' ? Icons.check : Icons.circle_outlined,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('الخاطئة فقط', textDirection: TextDirection.rtl),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentIndex + 1) / filteredAnswers.length,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              currentAnswer.isCorrect ? Colors.green : Colors.red,
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Result indicator
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: currentAnswer.isCorrect
                          ? Colors.green[50]
                          : Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: currentAnswer.isCorrect
                            ? Colors.green
                            : Colors.red,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          currentAnswer.isCorrect
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: currentAnswer.isCorrect
                              ? Colors.green
                              : Colors.red,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          currentAnswer.isCorrect
                              ? 'إجابة صحيحة'
                              : 'إجابة خاطئة',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: currentAnswer.isCorrect
                                ? Colors.green[800]
                                : Colors.red[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Question text
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'السؤال رقم ${currentAnswer.questionNumber}',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentAnswer.questionText,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Question image
                  if (currentAnswer.imageUrl != null && currentAnswer.imageUrl!.isNotEmpty)
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/exam_images/${currentAnswer.imageUrl}',
                          height: 200,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.image_not_supported, size: 64),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Answer options
                  _buildReviewOption(
                    'A',
                    currentAnswer.optionA,
                    currentAnswer.studentAnswer,
                    currentAnswer.correctAnswer,
                  ),
                  const SizedBox(height: 12),
                  _buildReviewOption(
                    'B',
                    currentAnswer.optionB,
                    currentAnswer.studentAnswer,
                    currentAnswer.correctAnswer,
                  ),
                  const SizedBox(height: 12),
                  if (currentAnswer.optionC != 'N/A')
                    _buildReviewOption(
                      'C',
                      currentAnswer.optionC,
                      currentAnswer.studentAnswer,
                      currentAnswer.correctAnswer,
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Explanation
                  if (!currentAnswer.isCorrect)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.lightbulb, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'الإجابة الصحيحة:',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getOptionText(currentAnswer.correctAnswer, currentAnswer),
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87, // Better contrast
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _currentIndex > 0
                        ? () {
                            setState(() {
                              _currentIndex--;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('السابق', textDirection: TextDirection.rtl),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _currentIndex < filteredAnswers.length - 1
                        ? () {
                            setState(() {
                              _currentIndex++;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('التالي', textDirection: TextDirection.rtl),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewOption(
    String letter,
    String text,
    String studentAnswer,
    String correctAnswer,
  ) {
    final isStudentAnswer = studentAnswer == letter;
    final isCorrectAnswer = correctAnswer == letter;
    
    Color? backgroundColor;
    Color? borderColor;
    
    if (isCorrectAnswer) {
      backgroundColor = Colors.green[50];
      borderColor = Colors.green;
    } else if (isStudentAnswer && !isCorrectAnswer) {
      backgroundColor = Colors.red[50];
      borderColor = Colors.red;
    } else {
      backgroundColor = Colors.white;
      borderColor = Colors.grey[300];
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor!,
          width: isCorrectAnswer || isStudentAnswer ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCorrectAnswer
                  ? Colors.green
                  : isStudentAnswer
                      ? Colors.red
                      : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCorrectAnswer
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : isStudentAnswer
                      ? const Icon(Icons.close, color: Colors.white, size: 20)
                      : Text(
                          letter,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87, // Better contrast
                          ),
                        ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isCorrectAnswer || isStudentAnswer
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: Colors.black87, // Ensure good contrast
              ),
            ),
          ),
          if (isCorrectAnswer)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'صحيح',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (isStudentAnswer && !isCorrectAnswer)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'إجابتك',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getOptionText(String letter, ExamDetailedAnswer answer) {
    switch (letter) {
      case 'A':
        return answer.optionA;
      case 'B':
        return answer.optionB;
      case 'C':
        return answer.optionC;
      default:
        return '';
    }
  }
}
