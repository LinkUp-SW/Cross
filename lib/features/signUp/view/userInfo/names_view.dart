import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/signUp/viewModel/view_model.dart';

class NamingPage extends ConsumerStatefulWidget {
  const NamingPage({super.key});

  @override
  ConsumerState<NamingPage> createState() => _NamingPageState();
}

class _NamingPageState extends ConsumerState<NamingPage> {
  bool _rememberMe = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obsureText = true;

  @override
  Widget build(BuildContext context) {
    final namingViewModel = ref.watch(namingViewModelProvider);
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Image(
                  image: AssetImage('assets/images/Logo.png'),
                  width: 100,
                  height: 100,
                ),
                const Text(
                  'Join LinkUp',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      'or',
                      style: TextStyle(fontSize: 15),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push('/login');
                      },
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                            labelText: 'First Name',
                            hintText: 'Enter your first name'),
                        validator: (value) =>
                            namingViewModel.validateName(value, 'First Name'),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                            labelText: 'Last Name',
                            hintText: 'Enter your last name'),
                        validator: (value) =>
                            namingViewModel.validateName(value, 'Last Name'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                              checkColor: Colors.blue,
                              value: _rememberMe,
                              onChanged: (ref) {
                                setState(() {
                                  _rememberMe = !_rememberMe;
                                });
                              }),
                          const Text(
                            'Remember me',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.push('/signup');
                          }
                        },
                        child: const Text('Next'),
                      )
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}
