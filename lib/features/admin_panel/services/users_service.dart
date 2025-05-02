import 'package:link_up/core/services/base_service.dart';
import 'package:link_up/features/admin_panel/model/users_model.dart';

class UserService  extends BaseService {
  Future<List<UserModel>> fetchUsers() async {
    return [
      UserModel(
        id: 1,
        firstName: 'Alice',
        lastName: 'Smith',
        email: 'alice@example.com',
        profileImageUrl: 'https://i.pravatar.cc/150?img=5',
        type: 'Admin',
      ),
    ];
  }

  Future<void> addUser(UserModel user) async {
    // Pretend to save
    await Future.delayed(Duration(milliseconds: 300));
  }

  Future<void> deleteUser(int id) async {
    // Pretend to delete
    await Future.delayed(Duration(milliseconds: 300));
  }
}
