import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/logIn/services/service.dart';
import 'package:link_up/features/logIn/widgets/widgets.dart';
import 'package:link_up/features/logIn/viewModel/view_model.dart';
import 'package:link_up/features/logIn/state/state.dart';
import 'package:link_up/shared/functions.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _rememberMe = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obsureText = true;

  @override
  Widget build(BuildContext context) {
    final logInState = ref.watch(logInProvider);
    final logInNotifier = ref.read(logInProvider.notifier);

    ref.listen<LogInState>(logInProvider, (previous, next) {
      if (next is LogInSuccessState) {
        context.pushReplacement('/');
      } else if (next is LogInErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
        _emailController.clear();
        _passwordController.clear();
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
                width: 100,
                height: 100,
                image: AssetImage('assets/images/Logo.png'),
              ),
              const Text(
                'Sign In',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
              SizedBox(
                height: 5.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back!',
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(
                    width: 2.w,
                  ),
                  TextButton(
                    onPressed: () {
                      context.push('/signup');
                    },
                    child: const Text('Join LinkUp'),
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: ElevatedButton(
                        onPressed: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/google.png',
                              height: 25,
                              width: 25,
                            ),
                            SizedBox(
                              width: 5.w,
                            ),
                            const Text(
                              'Sign in with Google',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            )
                          ],
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: ElevatedButton(
                        onPressed: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/facebook.png',
                              height: 25,
                              width: 25,
                            ),
                            SizedBox(
                              width: 5.w,
                            ),
                            const Text(
                              'Sign in with Facebook',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            )
                          ],
                        )),
                  )
                ],
              ),
              const DividerWithText(text: 'or'),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          hintText: 'Email or Phone Number'),
                      validator: validateEmail,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obsureText,
                      decoration: InputDecoration(
                          hintText: 'Password',
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obsureText = !_obsureText;
                                });
                              },
                              icon: Icon(!_obsureText
                                  ? Icons.visibility
                                  : Icons.visibility_off))),
                      validator: validatePassword,
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(
                                checkColor: Colors.blue,
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value!;
                                  });
                                }),
                            const Text(
                              'Remember me',
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                        TextButton(
                            onPressed: () {},
                            child: const Text('Forgot Password?')),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                logInNotifier.logIn(
                                  _emailController.text,
                                  _passwordController.text,
                                );
                              }
                            },
                            child: logInState is LogInLoadingState
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Continue',
                                    style: TextStyle(fontSize: 15),
                                  )),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
