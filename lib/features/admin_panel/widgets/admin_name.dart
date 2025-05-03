import 'package:flutter/material.dart';
import 'package:link_up/features/admin_panel/model/users_model.dart';
class AdminNameDialog extends StatelessWidget {
  const AdminNameDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return AlertDialog(
      title: Text('Enter Admin Details'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter first name' : null,
              ),
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter last name' : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter email';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Enter valid email';
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value == null || value.length < 6
                    ? 'Password must be 6+ chars'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newUser = UserModel(
                profileImageUrl: 'https://i.pravatar.cc/150?u=${emailController.text}', // Random avatar
                firstName: firstNameController.text,
                lastName: lastNameController.text,
                email: emailController.text,
                password: passwordController.text, // Optional: store or ignore
                id: DateTime.now().millisecondsSinceEpoch, // unique ID
                type: 'Admin',
              );
              Navigator.of(context).pop(newUser);
            }
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}

Future<UserModel?> showAdminNameDialog(BuildContext context) async {
  return await showDialog<UserModel>(
    context: context,
    builder: (context) => const AdminNameDialog(),
  );
}
