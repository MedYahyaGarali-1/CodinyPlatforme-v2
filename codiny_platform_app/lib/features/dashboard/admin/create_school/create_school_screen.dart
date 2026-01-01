import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/shared/layout/base_scaffold.dart';
import '/data/repositories/admin_repository.dart';
import '/core/utils/validators.dart';
import '/state/session/session_controller.dart';
import '/shared/ui/input_field.dart';
import '/shared/ui/snackbar_helper.dart';

class CreateSchoolScreen extends StatefulWidget {
  const CreateSchoolScreen({super.key});

  @override
  State<CreateSchoolScreen> createState() => _CreateSchoolScreenState();
}

class _CreateSchoolScreenState extends State<CreateSchoolScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final session = context.read<SessionController>();

      await AdminRepository().createSchool(
        name: _nameController.text,
        identifier: _identifierController.text,
        password: _passwordController.text,
        token: session.token, // ✅ required
      );

      if (!mounted) return;

      SnackBarHelper.showSuccess(context, 'Auto-école created successfully');

      Navigator.pop(context, true); // 👈 return success
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Create Auto-école',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ProInputField(
              labelText: 'School name',
              hintText: 'Enter school name',
              controller: _nameController,
              validator: Validators.name,
              prefixIcon: Icons.school,
            ),
            const SizedBox(height: 16),

            ProInputField(
              labelText: 'Email or phone',
              hintText: 'Enter email or phone number',
              controller: _identifierController,
              validator: Validators.emailOrPhone,
              prefixIcon: Icons.contact_mail,
            ),
            const SizedBox(height: 16),

            ProInputField(
              labelText: 'Initial password',
              hintText: 'Enter password',
              controller: _passwordController,
              obscureText: true,
              validator: Validators.password,
              prefixIcon: Icons.lock,
            ),
            const SizedBox(height: 32),

            FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _loading
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : const Text('Create Auto-école'),
            ),
          ],
        ),
      ),
    );
  }
}


