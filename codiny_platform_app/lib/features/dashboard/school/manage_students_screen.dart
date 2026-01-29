import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/school_repository.dart';
import '../../../data/models/school/school_student.dart';
import '../../../state/session/session_controller.dart';
import '../../../shared/ui/staggered_animation.dart';

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen>
    with TickerProviderStateMixin, StaggeredAnimationMixin {
  final SchoolRepository _repo = SchoolRepository();
  List<SchoolStudent> _students = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    initAnimations(sectionCount: 10);
    _loadStudents();
  }

  @override
  void dispose() {
    disposeAnimations();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final session = context.read<SessionController>();
      final token = session.token;
      if (token == null) throw Exception('Not authenticated');

      final students = await _repo.getStudents(token: token);
      setState(() {
        _students = students;
        _loading = false;
      });
      // Start animations after data loads
      startAnimations();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Students'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStudents,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_students.isEmpty) {
      return const Center(
        child: Text('No students yet'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStudents,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final student = _students[index];
          final isActive = student.hasActiveSubscription;

          return buildAnimatedSection(index, Card(
            child: ListTile(
              title: Text(student.name),
              subtitle: Text(
                isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: isActive ? Colors.green : Colors.red,
                ),
              ),
              trailing: isActive
                  ? const Icon(Icons.check, color: Colors.green)
                  : ElevatedButton(
                      onPressed: () => _confirmActivation(student),
                      child: const Text('Activate'),
                    ),
            ),
          ));
        },
      ),
    );
  }

  void _confirmActivation(SchoolStudent student) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Activate Subscription'),
        content: Text(
          'Activate 30 days for ${student.name}?\n\n'
          'You earn 20 DT\n'
          'You owe 30 DT to platform',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _activateStudent(student);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _activateStudent(SchoolStudent student) async {
    try {
      final session = context.read<SessionController>();
      final token = session.token;
      if (token == null) throw Exception('Not authenticated');

      await _repo.activateStudent(token: token, studentId: student.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${student.name} activated!')),
        );
        _loadStudents(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }
}
