import '../services/auth_service.dart';
import '../../state/session/session_controller.dart';
import '../models/user.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  // ================== LOGIN ==================
  Future<void> login({
    required String identifier,
    required String password,
    required SessionController session,
  }) async {
    final response = await _authService.login(
      identifier: identifier,
      password: password,
    );

    // 🔐 Extract data
    final token = response['accessToken'] as String;
    final userJson = response['user'] as Map<String, dynamic>;

    final user = User.fromJson(userJson);

    // ✅ Save session (ONE place)
    session.setSession(user, token);
  }

  // ================== REGISTER ==================
  Future<void> register({
    required String name,
    required String identifier,
    required String password,
    required SessionController session,
  }) async {
    await _authService.register(
      name: name,
      identifier: identifier,
      password: password,
    );

    // 🔁 Auto-login after register
    await login(
      identifier: identifier,
      password: password,
      session: session,
    );
  }
}

