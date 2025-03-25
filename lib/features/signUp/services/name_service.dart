import 'package:link_up/features/signUp/model/name_model.dart';

class NameService {
  String? name;

  bool? setName(NameModel name) {
    try {
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
