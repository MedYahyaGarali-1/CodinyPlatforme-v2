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

class _ExamTakingScreenState extends State<ExamTakingScreen>
    with TickerProviderStateMixin {
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
  // ignore: unused_field
  int _passingScore = 23; // Used for reference
  Timer? _timer;
  int _secondsRemaining = 45 * 60;
  DateTime? _startTime;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _questionAnimController;
  late Animation<double> _questionAnimation;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    
    // Pulse animation for timer when critical
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Question transition animation
    _questionAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _questionAnimation = CurvedAnimation(
      parent: _questionAnimController,
      curve: Curves.easeOut,
    );
    _questionAnimController.forward();
    
    _loadExamAndStart();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _questionAnimController.dispose();
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
          // Start pulse animation when time is critical (< 1 min)
          if (_secondsRemaining < 60 && !_pulseController.isAnimating) {
            _pulseController.repeat(reverse: true);
          }
        } else {
          _timer?.cancel();
          _pulseController.stop();
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
      _questionAnimController.reset();
      setState(() {
        _currentQuestionIndex++;
      });
      _questionAnimController.forward();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _questionAnimController.reset();
      setState(() {
        _currentQuestionIndex--;
      });
      _questionAnimController.forward();
    }
  }

  void _goToQuestion(int index) {
    _questionAnimController.reset();
    setState(() {
      _currentQuestionIndex = index;
    });
    _questionAnimController.forward();
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
    // Check if ALL questions are answered
    final unansweredCount = _questions.length - _answers.length;
    
    if (unansweredCount > 0) {
      // Find the first unanswered question
      int firstUnansweredIndex = 0;
      for (int i = 0; i < _questions.length; i++) {
        if (!_answers.containsKey(_questions[i].id)) {
          firstUnansweredIndex = i;
          break;
        }
      }
      
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'لا يمكن التسليم',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'يجب عليك الإجابة على جميع الأسئلة قبل تسليم الاختبار.\n\n'
            'لديك $unansweredCount سؤال بدون إجابة.',
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Go to first unanswered question
                _goToQuestion(firstUnansweredIndex);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'الذهاب للسؤال',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.green.shade700,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'تأكيد التسليم',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'لقد أجبت على جميع الأسئلة (${_questions.length} سؤال).\n\n'
          'هل أنت متأكد من تسليم الاختبار؟',
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'مراجعة الإجابات',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'تسليم الاختبار',
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 16),
            ),
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
      });
      
      if (!mounted) return;
      
      // Show user-friendly error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'فشل تسليم الاختبار',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'حدث خطأ أثناء تسليم الاختبار.\n\n'
            'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.',
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _submitExam(); // Retry submission
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'إعادة المحاولة',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }
  }

  Color _getTimeColor() {
    if (_secondsRemaining < 60) return Colors.red; // Less than 1 minute
    if (_secondsRemaining < 300) return Colors.orange; // Less than 5 minutes
    return const Color(0xFF4CAF50); // Green
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [const Color(0xFF1a1a2e), const Color(0xFF0f0f1a)]
                  : [Colors.blue.shade50, Colors.white],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('جاري تحميل الاختبار...', textDirection: TextDirection.rtl),
              ],
            ),
          ),
        ),
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
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [const Color(0xFF1a1a2e), const Color(0xFF0f0f1a)]
                  : [Colors.blue.shade50, Colors.white],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('جاري تسليم الاختبار...', 
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('مغادرة', textDirection: TextDirection.rtl),
              ),
            ],
          ),
        );
        return leave ?? false;
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0f0f1a) : Colors.grey[50],
        appBar: _buildAppBar(isDark, answeredCount),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [const Color(0xFF1a1a2e), const Color(0xFF16213e), const Color(0xFF0f0f1a)]
                  : [Colors.blue.shade50.withOpacity(0.5), Colors.purple.shade50.withOpacity(0.3), Colors.grey[50]!],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
          child: Column(
            children: [
              // Enhanced Progress Bar
              _buildProgressBar(isDark, answeredCount),
              
              // Main content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: FadeTransition(
                    opacity: _questionAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(_questionAnimation),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Question Card
                          _buildQuestionCard(currentQuestion, isDark),
                          const SizedBox(height: 20),
                          
                          // Answer Options
                          _buildAnswerOption('A', currentQuestion.optionA, currentAnswer, isDark),
                          const SizedBox(height: 12),
                          _buildAnswerOption('B', currentQuestion.optionB, currentAnswer, isDark),
                          const SizedBox(height: 12),
                          if (currentQuestion.hasThreeOptions())
                            _buildAnswerOption('C', currentQuestion.optionC, currentAnswer, isDark),
                          
                          const SizedBox(height: 24),
                          
                          // Bookmark Button
                          _buildBookmarkButton(isDark),
                          
                          const SizedBox(height: 24),
                          
                          // Navigation Buttons
                          _buildNavigationButtons(isDark, answeredCount),
                          
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, int answeredCount) {
    final timeColor = _getTimeColor();
    final isCritical = _secondsRemaining < 60;
    
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.close_rounded,
          color: isDark ? Colors.white : const Color(0xFF1D1E33),
        ),
        onPressed: () async {
          final leave = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('تحذير', textDirection: TextDirection.rtl),
              content: const Text(
                'إذا غادرت الآن، سيتم إلغاء الاختبار.\nهل أنت متأكد؟',
                textDirection: TextDirection.rtl,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('البقاء'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('مغادرة'),
                ),
              ],
            ),
          );
          if (leave == true && mounted) Navigator.pop(context);
        },
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Question counter with circular progress
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 45,
                height: 45,
                child: CircularProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _questions.length,
                  strokeWidth: 3,
                  backgroundColor: isDark ? Colors.white24 : Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF667eea)),
                ),
              ),
              Text(
                '${_currentQuestionIndex + 1}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1D1E33),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Text(
            '/ ${_questions.length}',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white60 : Colors.grey[600],
            ),
          ),
        ],
      ),
      actions: [
        // Timer with animation
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: isCritical ? 1 + (_pulseController.value * 0.1) : 1,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [timeColor, timeColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: timeColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCritical ? Icons.alarm : Icons.timer_outlined,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatTime(_secondsRemaining),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        // Question navigator button
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.grid_view_rounded,
              color: isDark ? Colors.white : const Color(0xFF1D1E33),
              size: 20,
            ),
          ),
          onPressed: _showQuestionNavigator,
          tooltip: 'قائمة الأسئلة',
        ),
      ],
    );
  }

  Widget _buildProgressBar(bool isDark, int answeredCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: answeredCount / _questions.length,
              backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation(Color(0xFF667eea)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          // Answered count text
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'تم الإجابة على ',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : Colors.grey[600],
                ),
              ),
              Text(
                '$answeredCount',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF667eea),
                ),
              ),
              Text(
                ' من ${_questions.length} سؤال',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(ExamQuestion question, bool isDark) {
    final isMarked = _markedForReview.contains(_currentQuestionIndex);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E2E), const Color(0xFF252540)]
              : [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Question text
                Text(
                  question.questionText,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1D1E33),
                    height: 1.5,
                  ),
                ),
                
                // Question image
                if (question.imageUrl != null && question.imageUrl!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _showFullScreenImage(question.imageUrl!),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 220),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Image.asset(
                              'assets/exam_images/${question.imageUrl}',
                              fit: BoxFit.contain,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white10 : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.image_not_supported_rounded,
                                      size: 48,
                                      color: isDark ? Colors.white38 : Colors.grey[400],
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Zoom indicator
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.zoom_in, color: Colors.white, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      'اضغط للتكبير',
                                      style: TextStyle(color: Colors.white, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Bookmark indicator on card
          if (isMarked)
            Positioned(
              top: 0,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: const Icon(Icons.bookmark, color: Colors.white, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/exam_images/$imageUrl',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerOption(String letter, String text, String? selectedAnswer, bool isDark) {
    final isSelected = selectedAnswer == letter;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectAnswer(letter),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF667eea).withOpacity(0.15),
                        const Color(0xFF764ba2).withOpacity(0.1),
                      ],
                    )
                  : null,
              color: isSelected ? null : (isDark ? const Color(0xFF1E1E2E) : Colors.white),
              border: Border.all(
                color: isSelected ? const Color(0xFF667eea) : (isDark ? Colors.white24 : Colors.grey[300]!),
                width: isSelected ? 2.5 : 1.5,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF667eea).withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                // Letter badge
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          )
                        : null,
                    color: isSelected ? null : (isDark ? Colors.white12 : Colors.grey[100]),
                    shape: BoxShape.circle,
                    border: isSelected ? null : Border.all(
                      color: isDark ? Colors.white24 : Colors.grey[300]!,
                    ),
                  ),
                  child: Center(
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 22)
                        : Text(
                            letter,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.grey[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                // Answer text
                Expanded(
                  child: Text(
                    text,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? const Color(0xFF667eea)
                          : (isDark ? Colors.white : Colors.grey[800]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarkButton(bool isDark) {
    final isMarked = _markedForReview.contains(_currentQuestionIndex);
    
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggleMarkForReview,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isMarked
                    ? Colors.orange.withOpacity(0.15)
                    : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isMarked ? Colors.orange : (isDark ? Colors.white24 : Colors.grey[300]!),
                  width: isMarked ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isMarked ? 'تم وضع علامة للمراجعة' : 'وضع علامة للمراجعة',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: isMarked ? Colors.orange : (isDark ? Colors.white60 : Colors.grey[600]),
                      fontWeight: isMarked ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isMarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      key: ValueKey(isMarked),
                      color: isMarked ? Colors.orange : (isDark ? Colors.white60 : Colors.grey[500]),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(bool isDark, int answeredCount) {
    final isFirstQuestion = _currentQuestionIndex == 0;
    final isLastQuestion = _currentQuestionIndex == _questions.length - 1;
    final allAnswered = answeredCount == _questions.length;
    
    return Column(
      children: [
        // Previous / Next buttons
        Row(
          children: [
            // Previous button
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: !isFirstQuestion
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: ElevatedButton(
                  onPressed: isFirstQuestion ? null : _previousQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF2A2A40) : Colors.white,
                    foregroundColor: isDark ? Colors.white : const Color(0xFF1D1E33),
                    disabledBackgroundColor: isDark ? Colors.white10 : Colors.grey[100],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isDark ? Colors.white24 : Colors.grey[300]!,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'السابق',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isFirstQuestion
                              ? (isDark ? Colors.white30 : Colors.grey[400])
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: isFirstQuestion
                            ? (isDark ? Colors.white30 : Colors.grey[400])
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Next button
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: !isLastQuestion
                      ? const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        )
                      : null,
                  boxShadow: !isLastQuestion
                      ? [
                          BoxShadow(
                            color: const Color(0xFF667eea).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: ElevatedButton(
                  onPressed: isLastQuestion ? null : _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledBackgroundColor: isDark ? Colors.white10 : Colors.grey[100],
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back_rounded,
                        color: isLastQuestion
                            ? (isDark ? Colors.white30 : Colors.grey[400])
                            : Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'التالي',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isLastQuestion
                              ? (isDark ? Colors.white30 : Colors.grey[400])
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        
        // Submit button - only show when ALL questions are answered
        if (allAnswered) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF11998e).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _submitExam,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'تسليم الاختبار',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.check_circle_outline, color: Colors.white),
                ],
              ),
            ),
          ),
        ] else if (isLastQuestion) ...[
          // Show hint and button to go to unanswered questions
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.orange.withOpacity(0.15) : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'أجب على جميع الأسئلة (${_questions.length - answeredCount} متبقي) للتسليم',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _goToFirstUnanswered,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                    label: const Text(
                      'الذهاب للأسئلة غير المجابة',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _goToFirstUnanswered() {
    for (int i = 0; i < _questions.length; i++) {
      if (!_answers.containsKey(_questions[i].id)) {
        // Navigate without popping (since we're not in a dialog)
        _questionAnimController.reset();
        setState(() {
          _currentQuestionIndex = i;
        });
        _questionAnimController.forward();
        return;
      }
    }
  }

  void _showQuestionNavigator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                  : [Colors.white, Colors.grey.shade50],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'قائمة الأسئلة',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1D1E33),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_answers.length} / ${_questions.length} تم الإجابة',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white60 : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Legend
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.grey[200]!,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildLegend(const Color(0xFF667eea), 'الحالي', isDark),
                          _buildLegend(const Color(0xFF11998e), 'تم الإجابة', isDark),
                          _buildLegend(Colors.orange, 'للمراجعة', isDark),
                          _buildLegend(isDark ? Colors.white24 : Colors.grey[300]!, 'لم يتم', isDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Grid
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final question = _questions[index];
                    final isAnswered = _answers.containsKey(question.id);
                    final isMarked = _markedForReview.contains(index);
                    final isCurrent = index == _currentQuestionIndex;
                    
                    List<Color> gradientColors;
                    if (isCurrent) {
                      gradientColors = [const Color(0xFF667eea), const Color(0xFF764ba2)];
                    } else if (isMarked) {
                      gradientColors = [Colors.orange, Colors.deepOrange];
                    } else if (isAnswered) {
                      gradientColors = [const Color(0xFF11998e), const Color(0xFF38ef7d)];
                    } else {
                      gradientColors = isDark 
                          ? [Colors.white12, Colors.white10]
                          : [Colors.grey[200]!, Colors.grey[100]!];
                    }
                    
                    final hasStatus = isCurrent || isMarked || isAnswered;
                    
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _goToQuestion(index),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: hasStatus
                                ? [
                                    BoxShadow(
                                      color: gradientColors.first.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: hasStatus
                                      ? Colors.white
                                      : (isDark ? Colors.white54 : Colors.grey[700]),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (isMarked && !isCurrent)
                                const Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Icon(
                                    Icons.bookmark,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                            ],
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

  Widget _buildLegend(Color color, String label, bool isDark) {
    return Row(
      children: [
        Text(
          label,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white70 : Colors.grey[700],
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }
}
