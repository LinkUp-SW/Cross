//the page ui only and try avoiding any logic here

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/logIn/widgets/widgets.dart';
import 'package:link_up/features/signUp/viewModel/view_model.dart';

class SigningupView extends ConsumerStatefulWidget {
  const SigningupView({super.key});

  @override
  ConsumerState<SigningupView> createState() => _SigningupViewState();
}

class _SigningupViewState extends ConsumerState<SigningupView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obsureText = true;

  @override
  Widget build(BuildContext context) {
    final signingUpViewModel = ref.watch(signingUpViewModelprovider);

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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email or Phone Number',
                        hintText: 'Enter your email or Phone Number',
                      ),
                      validator: signingUpViewModel.validateEmail,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      controller: _passwordController,
                      obscureText: _obsureText,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        suffixIcon: IconButton(
                          icon: Icon(_obsureText
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _obsureText = !_obsureText;
                            });
                          },
                        ),
                      ),
                      validator: signingUpViewModel.validatePassword,
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Clear the form fields
                              context.push('/signup/usersname');
                            }
                            _emailController.clear();
                            _passwordController.clear();
                          },
                          child: const Text(
                            "Join",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                    const DividerWithText(text: 'or'),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/google.png',
                            height: 25,
                            width: 25,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          const Text(
                            'Sign in with Google',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/facebook.png',
                            height: 25,
                            width: 25,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          const Text(
                            'Sign in with Facebook',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
