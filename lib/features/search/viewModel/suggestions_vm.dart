import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/search/model/suggestions_model.dart';

class SuggestionsProvider extends StateNotifier<Map<String, dynamic>> {
  SuggestionsProvider() : super({"suggestions": [], "value": ""});

  void setValue(String value) {
    state['value'] = value;
  }

  Future<void> getSuggestions(String value) {
    final BaseService service = BaseService();
    return service.get('api/v1/search/suggestions?query=:query',
        queryParameters: {'query': value}).then((value) {
      if (value.statusCode == 200) {
        final body = jsonDecode(value.body);
        final temp = body['suggestions'] as List<dynamic>;
        if (temp.isEmpty) {
          state['suggestions'].clear();
          return;
        }
        state['suggestions'].clear();
        state['suggestions'].addAll(temp
            .map((e) => SuggestionsModel.fromJson(e))
            .toList()
            .cast<SuggestionsModel>());
      }
    }).catchError((error) {
      log(error.toString());
    });
  }

  void clearSuggestions() {
    state['value'] = '';
    state['suggestions'].clear();
  }
}

final suggestionsProvider =
    StateNotifierProvider<SuggestionsProvider, Map<String, dynamic>>(
  (ref) => SuggestionsProvider(),
);
