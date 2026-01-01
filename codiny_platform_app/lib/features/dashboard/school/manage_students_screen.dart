import 'package:flutter/material.dart';

class ManageStudentsScreen extends StatelessWidget {
  const ManageStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TEMP DATA (backend later)
    final students = [
      {
        'name': 'Ali Ben Salah',
        'active': true,
      },
      {
        'name': 'Youssef Trabelsi',
        'active': false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Students'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ➕ Add student button
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text('Add Student'),
              onPressed: () {
                _showAddStudentDialog(context);
              },
            ),

            const SizedBox(height: 16),

            // 📋 Students list
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  final isActive = student['active'] as bool;

                  return Card(
                    child: ListTile(
                      title: Text(student['name'] as String),
                      subtitle: Text(
                        isActive ? 'Active' : 'Expired',
                        style: TextStyle(
                          color: isActive ? Colors.green : Colors.red,
                        ),
                      ),
                      trailing: isActive
                          ? const Icon(Icons.check, color: Colors.green)
                          : ElevatedButton(
                              onPressed: () {
                                _confirmActivation(context);
                              },
                              child: const Text('Activate'),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- DIALOGS ----------------

  void _showAddStudentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            TextField(
              controller: phoneController,
              decoration:
                  const InputDecoration(labelText: 'Phone or Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Backend later
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Student added')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _confirmActivation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Activate Subscription'),
        content: const Text(
          'Activate 30 days for this student?\n\n'
          'You earn 20 DT\n'
          'You owe 30 DT to platform',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Backend later
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Subscription activated')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
