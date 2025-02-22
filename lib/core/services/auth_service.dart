
// Un
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/core/constants/endpoints.dart';

class AuthService {
  final BaseService _baseService;

  const AuthService(this._baseService);
  
  Future<Response> getPostLogin() async {
    return (await _baseService.get(ExternalEndPoints.postLoginEndpoint));
  }
}

final authService = Provider<AuthService>(
  (ref) => AuthService(ref.read(baseServiceProvider)),
);