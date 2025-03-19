//api hits and response data transfere

import 'package:link_up/features/logIn/model/model.dart';
import 'package:http/http.dart' as http;

class LogInService {
  Future<bool> logIn(LogInModel logInModel) async {
    ///var response = await http.post(url, body: {'email':logInModel.email, 'password':logInModel.password});
    //if (response.statusCode == 200) {
    //  return true;
    //} else {
    //  throw Exception('Failed to log in');
    //}
    await Future.delayed(Duration(seconds: 2));
    if (logInModel.email == 'awadyoussef431@gmail.com' &&
        logInModel.password == '1234567YoussefAwad') {
      return true;
    } else {
      throw Exception('Invalid credentials');
    }
  }
}
