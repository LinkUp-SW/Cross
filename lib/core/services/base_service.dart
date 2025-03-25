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
  Map<String, String> headers = {};

  Future<Response> post(String endpoint, Map<String, dynamic> body) async {
    final token = await getToken();
    final uri = Uri.parse('${ExternalEndPoints.baseUrl}$endpoint');
    headers['Content-Type'] = 'application/json';
    headers['Authorization'] = 'Bearer $token';
    final response = await http
        .post(uri, headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 10));
    updateCookie(response);
    return response;
  }

  Future<Response> put(String endpoint, Map<String, dynamic> body) async {
    final token = await getToken();
    final uri = Uri.parse('${ExternalEndPoints.baseUrl}$endpoint');
    headers['Content-Type'] = 'application/json';
    headers['Authorization'] = 'Bearer $token';
    final response = await http
        .put(
          uri,
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));
    updateCookie(response);
    return response;
  }

  Future<Response> get(
      String endpoint, Map<String, String>? queryParameters) async {
    final token = await getToken();
    final uri = Uri.parse('${ExternalEndPoints.baseUrl}$endpoint').replace(
      queryParameters: queryParameters,
    );
    headers['Content-Type'] = 'application/json';
    headers['Authorization'] = 'Bearer $token';
    final response = await http
        .get(
          uri,
          headers: headers,
        )
        .timeout(const Duration(seconds: 10));
    updateCookie(response);
    return response;
  }

  Future<Response> delete(String endpoint) async {
    final token = await getToken();
    final uri = Uri.parse('${ExternalEndPoints.baseUrl}$endpoint');
    headers['Content-Type'] = 'application/json';
    headers['Authorization'] = 'Bearer $token';
    final response = await http
        .delete(
          uri,
          headers: headers,
        )
        .timeout(const Duration(seconds: 10));
    updateCookie(response);
    return response;
  }

  void updateCookie(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers['cookie'] =
          (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }
}

final baseServiceProvider = Provider<BaseService>((ref) => BaseService());
