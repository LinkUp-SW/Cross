// Generic class for api calls

import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:link_up/core/services/storage.dart';
import 'package:link_up/core/constants/endpoints.dart';

class BaseService {
  Map<String, String> headers = {};

  Future<Response> post(String endpoint,
      {Map<String, dynamic>? body,
      Map<String, dynamic>? routeParameters}) async {
    try {
      final token = await getToken();
      String finalEndpoint = endpoint;
      if (routeParameters != null) {
        routeParameters.forEach((key, value) {
          finalEndpoint = finalEndpoint.replaceAll(':$key', value.toString());
        });
      }
      final uri = Uri.parse('${ExternalEndPoints.baseUrl}$finalEndpoint');
      headers['Content-Type'] = 'application/json';
      headers['Authorization'] = 'Bearer $token';
      final response = await http
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 10));
      updateCookie(response);
      return response;
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on http.ClientException catch (e) {
      throw Exception('Client error: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Response> put(String endpoint, Map<String, dynamic> body) async {
    try {
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
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on http.ClientException catch (e) {
      throw Exception('Client error: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Response> patch(String endpoint, {required Map<String, dynamic> body,Map<String,dynamic>? routeParameters}) async {
    try {
      final token = await getToken();
      String finalEndpoint = endpoint;
      if (routeParameters != null) {
        routeParameters.forEach((key, value) {
          finalEndpoint = finalEndpoint.replaceAll(':$key', value.toString());
        });
      }
      final uri = Uri.parse('${ExternalEndPoints.baseUrl}$finalEndpoint');
      headers['Content-Type'] = 'application/json';
      headers['Authorization'] = 'Bearer $token';
      final response = await http
          .patch(
            uri,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
      updateCookie(response);
      return response;
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on http.ClientException catch (e) {
      throw Exception('Client error: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Response> get(String endpoint,
      {Map<String, dynamic>? queryParameters,
      Map<String, dynamic>? routeParameters}) async {
    try {
      final token = await getToken();
      String finalEndpoint = endpoint;

      if (routeParameters != null) {
        routeParameters.forEach(
          (key, value) {
            finalEndpoint = finalEndpoint.replaceAll(
              ':$key',
              value.toString(),
            );
          },
        );
      }

      Uri uri = Uri.parse('${ExternalEndPoints.baseUrl}$finalEndpoint');

      if (queryParameters != null) {
        uri = uri.replace(
          queryParameters: queryParameters,
        );
      }

      headers['Authorization'] = 'Bearer $token';
      final response = await http
          .get(
            uri,
            headers: headers,
          )
          .timeout(
            const Duration(
              seconds: 10,
            ),
          );
      updateCookie(response);
      return response;
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on http.ClientException catch (e) {
      throw Exception('Client error: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Response> delete(
      String endpoint, Map<String, dynamic>? routeParameters,{Map<String, dynamic>? body}) async {
    try {
      final token = await getToken();
      String finalEndpoint = endpoint;
      if (routeParameters != null) {
        routeParameters.forEach((key, value) {
          finalEndpoint = finalEndpoint.replaceAll(':$key', value.toString());
        });
      }
      headers['Authorization'] = 'Bearer $token';
      headers['Content-Type'] = 'application/json';
      final uri = Uri.parse('${ExternalEndPoints.baseUrl}$finalEndpoint');
      final response = await http
          .delete(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 10));
      updateCookie(response);
      return response;
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on http.ClientException catch (e) {
      throw Exception('Client error: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  void updateCookie(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers['cookie'] =
          (index == -1) ? rawCookie : rawCookie.substring(0, index);

      final tokenMatch =
          RegExp(r'linkup_auth_token=([^;]+)').firstMatch(rawCookie);
      if (tokenMatch != null) {
        final token = tokenMatch.group(1);
        if (token != null && token.isNotEmpty) {
          storeToken(token);
        }
      }
    }
  }
}

final baseServiceProvider = Provider<BaseService>((ref) => BaseService());
