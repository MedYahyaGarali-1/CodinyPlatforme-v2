import '../../core/utils/formatters.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api;

  AuthService({ApiService? api}) : _api = api ?? ApiService();

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    return await _api.post(
      '/auth/login',
      body: {
        'identifier': Formatters.normalize(identifier),
        'password': password,
      },
    );
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String identifier,
    required String password,
  }) async {
    return await _api.post(
      '/auth/register',
      body: {
        'name': Formatters.capitalizeName(name),
        'identifier': Formatters.normalize(identifier),
        'password': password,
      },
    );
  }
}
