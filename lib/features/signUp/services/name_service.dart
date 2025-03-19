import 'package:link_up/features/signUp/model/name_model.dart';

class NameService {
  String? name;

  Future<bool?> setName(NameModel name) async {
    try {
      await Future.delayed(Duration(seconds: 1));

      this.name = '${name.firstName!} ${name.lastName!}';
      return true;
    } catch (e) {
      return false;
    }
  }

  String? getName() {
    return name;
  }
}
