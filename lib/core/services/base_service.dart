// Generic class for api calls

import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:link_up/core/services/storage.dart';
import 'package:link_up/core/constants/endpoints.dart';


// Add put/patch and delete methods
class BaseService {
  Future<Response> post(String endpoint, Map<String, dynamic> body) async {
    final token = await getToken();
    final uri = Uri.parse('${ExternalEndPoints.baseUrl}$endpoint');
    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));
    return response;
  }

  Future<Response> get(String endpoint) async {
    final token = await getToken();
    final uri = Uri.parse('${ExternalEndPoints.baseUrl}$endpoint');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    ).timeout(const Duration(seconds: 10));
    return response;
  }
}

final baseServiceProvider = Provider<BaseService>((ref) => BaseService());