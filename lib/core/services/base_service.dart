// Generic class for api calls

import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:link_up/core/services/storage.dart';
import 'package:link_up/core/constants/endpoints.dart';

class BaseService {
  Future<Response> post(String endpoint, Map<String, dynamic>? body,
      Map<String, dynamic>? routeParameters) async {
    final token = await getToken();
    // Replace route parameters in the endpoint if provided
    String finalEndpoint = endpoint;
    if (routeParameters != null) {
      routeParameters.forEach((key, value) {
        finalEndpoint = finalEndpoint.replaceAll(':$key', value.toString());
      });
    }
    final uri = Uri.parse('${ExternalEndPoints.baseUrl}$finalEndpoint');
    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: 10));
    return response;
  }

  Future<Response> put(String endpoint, Map<String, dynamic> body) async {
    final token = await getToken();
    final uri = Uri.parse('${ExternalEndPoints.baseUrl}$endpoint');
    final response = await http
        .put(
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

  Future<Response> get(String endpoint,
      {Map<String, String>? queryParameters,
      Map<String, dynamic>? routeParameters}) async {
    final token = await getToken();

    // Replace route parameters in the endpoint if provided
    String finalEndpoint = endpoint;
    if (routeParameters != null) {
      routeParameters.forEach((key, value) {
        finalEndpoint = finalEndpoint.replaceAll(':$key', value.toString());
      });
    }

    Uri uri = Uri.parse('${ExternalEndPoints.baseUrl}$finalEndpoint');
    if (queryParameters != null) {
      uri = uri.replace(
        queryParameters: queryParameters,
      );
    }

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 10));

    return response;
  }

  Future<Response> delete(
      String endpoint, Map<String, dynamic>? routeParameters) async {
    final token = await getToken();
    // Replace route parameters in the endpoint if provided
    String finalEndpoint = endpoint;
    if (routeParameters != null) {
      routeParameters.forEach((key, value) {
        finalEndpoint = finalEndpoint.replaceAll(':$key', value.toString());
      });
    }
    final uri = Uri.parse('${ExternalEndPoints.baseUrl}$finalEndpoint');
    final response = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 10));
    return response;
  }
}

final baseServiceProvider = Provider<BaseService>((ref) => BaseService());
