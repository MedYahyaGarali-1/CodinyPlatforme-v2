import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/exam/exam_models.dart';
import '../../data/repositories/exam_repository.dart';
import 'exam_results_screen.dart';

class ExamTakingScreen extends StatefulWidget {
  final String token;

  const ExamTakingScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<ExamTakingScreen> createState() => _ExamTakingScreenState();
}

class _ExamTakingScreenState extends State<ExamTakingScreen> {
  final ExamRepository _examRepo = ExamRepository();
  
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  
  List<ExamQuestion> _questions = [];
  ExamSession? _session;
  Map<String, String> _answers = {}; // questionId -> answer (A/B/C)
  Set<int> _markedForReview = {};
  int _currentQuestionIndex = 0;
  
  int _timeLimitMinutes = 45;
  int _passingScore = 23;
  Timer? _timer;
  int _secondsRemaining = 45 * 60;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _loadExamAndStart();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadExamAndStart() async {
    try {
      // Get questions
      final questionsData = await _examRepo.getExamQuestions(widget.token);
      
      // Start session
      final session = await _examRepo.startExam(widget.token);
      
      setState(() {
        _questions = questionsData['questions'] as List<ExamQuestion>;
        _timeLimitMinutes = questionsData['time_limit_minutes'];
        _passingScore = questionsData['passing_score'];
        _session = session;
        _secondsRemaining = _timeLimitMinutes * 60;
        _isLoading = false;
      });
      
      _startTimer();
    } catch (e) {
      setState(() {
        _error = 'فشل تحميل الاختبار: $e';
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
          _autoSubmitExam();
        }
      });
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _selectAnswer(String answer) {
    setState(() {
      _answers[_questions[_currentQuestionIndex].id] = answer;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _goToQuestion(int index) {
    setState(() {
      _currentQuestionIndex = index;
    });
    Navigator.pop(context); // Close the navigator drawer/dialog
  }

  void _toggleMarkForReview() {
    setState(() {
      if (_markedForReview.contains(_currentQuestionIndex)) {
        _markedForReview.remove(_currentQuestionIndex);
      } else {
        _markedForReview.add(_currentQuestionIndex);
      }
    });
  }

  Future<void> _submitExam() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد التسليم', textDirection: TextDirection.rtl),
        content: Text(
          'هل أنت متأكد من تسليم الاختبار؟\n'
          'لقد أجبت على ${_answers.length} من ${_questions.length} سؤال.',
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء', textDirection: TextDirection.rtl),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('تسليم', textDirection: TextDirection.rtl),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _performSubmit();
    }
  }

  Future<void> _autoSubmitExam() async {
    await _performSubmit();
  }

  Future<void> _performSubmit() async {
    setState(() {
      _isSubmitting = true;
    });

    _timer?.cancel();

    try {
      final timeTaken = DateTime.now().difference(_startTime!).inSeconds;
      
      final answersToSubmit = _questions.map((q) {
        return ExamAnswer(
          questionId: q.id,
          studentAnswer: _answers[q.id] ?? '', // Empty if not answered
        );
      }).toList();

      final result = await _examRepo.submitExam(
        token: widget.token,
        sessionId: _session!.id,
        answers: answersToSubmit,
        timeTakenSeconds: timeTaken,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ExamResultsScreen(
            token: widget.token,
            result: result,
            examId: _session!.id,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _error = 'فشل تسليم الاختبار: $e';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_error!)),
      );
    }
  }

  Color _getTimeColor() {
    if (_secondsRemaining < 300) return Colors.red; // Less than 5 minutes
    if (_secondsRemaining < 600) return Colors.orange; // Less than 10 minutes
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('جاري التحميل...', textDirection: TextDirection.rtl)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _questions.isEmpty) {
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

    if (_isSubmitting) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('جاري تسليم الاختبار...', textDirection: TextDirection.rtl),
            ],
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final currentAnswer = _answers[currentQuestion.id];
    final answeredCount = _answers.length;

    return WillPopScope(
      onWillPop: () async {
        final leave = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تحذير', textDirection: TextDirection.rtl),
            content: const Text(
              'إذا غادرت الآن، سيتم إلغاء الاختبار.\nهل أنت متأكد؟',
              textDirection: TextDirection.rtl,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('البقاء', textDirection: TextDirection.rtl),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('مغادرة', textDirection: TextDirection.rtl),
              ),
            ],
          ),
        );
        return leave ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'السؤال ${_currentQuestionIndex + 1}/${_questions.length}',
                style: const TextStyle(fontSize: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getTimeColor(),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, size: 20, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(_secondsRemaining),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: _showQuestionNavigator,
              tooltip: 'قائمة الأسئلة',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / _questions.length,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 16),
              
              // Answered count
              Text(
                'تم الإجابة على $answeredCount من ${_questions.length} سؤال',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              
              // Question text
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    currentQuestion.questionText,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Question image
              if (currentQuestion.imageUrl != null && currentQuestion.imageUrl!.isNotEmpty)
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/exam_images/${currentQuestion.imageUrl}',
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
              _buildOption('A', currentQuestion.optionA, currentAnswer),
              const SizedBox(height: 12),
              _buildOption('B', currentQuestion.optionB, currentAnswer),
              const SizedBox(height: 12),
              if (currentQuestion.hasThreeOptions())
                _buildOption('C', currentQuestion.optionC, currentAnswer),
              
              const SizedBox(height: 24),
              
              // Mark for review button
              OutlinedButton.icon(
                onPressed: _toggleMarkForReview,
                icon: Icon(
                  _markedForReview.contains(_currentQuestionIndex)
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                ),
                label: Text(
                  _markedForReview.contains(_currentQuestionIndex)
                      ? 'إزالة من المراجعة'
                      : 'وضع علامة للمراجعة',
                  textDirection: TextDirection.rtl,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _markedForReview.contains(_currentQuestionIndex)
                      ? Colors.orange
                      : Colors.grey,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Navigation buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _currentQuestionIndex > 0 ? _previousQuestion : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('السابق', textDirection: TextDirection.rtl),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _currentQuestionIndex < _questions.length - 1
                          ? _nextQuestion
                          : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('التالي', textDirection: TextDirection.rtl),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Submit button
              if (_currentQuestionIndex == _questions.length - 1 || answeredCount == _questions.length)
                ElevatedButton(
                  onPressed: _submitExam,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text(
                    'تسليم الاختبار',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(String letter, String text, String? selectedAnswer) {
    final isSelected = selectedAnswer == letter;
    
    return InkWell(
      onTap: () => _selectAnswer(letter),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
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
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black87, // Ensure good contrast
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuestionNavigator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'قائمة الأسئلة',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLegend(Colors.blue, 'الحالي'),
                  _buildLegend(Colors.green, 'تم الإجابة'),
                  _buildLegend(Colors.orange, 'للمراجعة'),
                  _buildLegend(Colors.grey[300]!, 'لم يتم الإجابة'),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final question = _questions[index];
                    final isAnswered = _answers.containsKey(question.id);
                    final isMarked = _markedForReview.contains(index);
                    final isCurrent = index == _currentQuestionIndex;
                    
                    Color bgColor;
                    if (isCurrent) {
                      bgColor = Colors.blue;
                    } else if (isMarked) {
                      bgColor = Colors.orange;
                    } else if (isAnswered) {
                      bgColor = Colors.green;
                    } else {
                      bgColor = Colors.grey[300]!;
                    }
                    
                    return InkWell(
                      onTap: () => _goToQuestion(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isCurrent || isAnswered || isMarked
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
