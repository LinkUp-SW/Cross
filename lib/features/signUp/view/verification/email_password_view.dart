//the page ui only and try avoiding any logic here

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/logIn/widgets/widgets.dart';
import 'package:link_up/features/signUp/state/email_password_state.dart';
import 'package:link_up/features/signUp/viewModel/email_password_provider.dart';
import 'package:link_up/shared/functions.dart';

class EmailPasswordView extends ConsumerStatefulWidget {
  const EmailPasswordView({super.key});

  @override
  ConsumerState<EmailPasswordView> createState() => _EmailPasswordViewState();
}

class _EmailPasswordViewState extends ConsumerState<EmailPasswordView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obsureText = true;

  @override
  Widget build(BuildContext context) {
    final emailPasswordState = ref.watch(emailPasswordProvider);
    final emailPasswordNotifier = ref.read(emailPasswordProvider.notifier);

    ref.listen<EmailPasswordState>(emailPasswordProvider, (previous, next) {
      if (next is EmailPasswordValid) {
        context.push('/signup/usersname');
      } else if (next is EmailPasswordInvalid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage)),
        );
      }
    });

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
                    key: const Key('signInButton'),
                    onPressed: () {
                      context.push('/login');
                    },
                    child: const Text('Sign In'),
                    style: const ButtonStyle(
                      overlayColor: WidgetStatePropertyAll(Colors.transparent),
                      foregroundColor: WidgetStatePropertyAll(
                        Colors.blue,
                      ),
                    ),
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
                      key: const Key('emailTextField'),
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email or Phone Number',
                        hintText: 'Enter your email or Phone Number',
                      ),
                      validator: (value) => validateEmail(value),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      key: const Key('passwordTextField'),
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
                      validator: (value) => validatePassword(value),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          key: const Key('signUpButton'),
                          onPressed: emailPasswordState is LoadingEmailPassword
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    // Clear the form fields
                                    await emailPasswordNotifier.verifyEmail(
                                        _emailController.text,
                                        _passwordController.text);
                                  }
                                  _emailController.clear();
                                  _passwordController.clear();
                                },
                          child: emailPasswordState is LoadingEmailPassword
                              ? const CircularProgressIndicator()
                              : const Text('Sign Up',
                                  style: TextStyle(fontSize: 20)),
                        ),
                      ],
                    ),
                    const DividerWithText(text: 'or'),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      key: const Key('googleSignInButton'),
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
                      key: const Key('facebookSignInButton'),
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
