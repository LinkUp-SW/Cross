import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/logIn/widgets/widgets.dart';
import 'package:link_up/features/logIn/viewModel/view_model.dart';

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
    final loginViewModel = ref.watch(loginViewModelProvider);

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
                    onPressed: () {},
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
                    child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            backgroundColor: Colors.transparent),
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
                                  color: Colors.black),
                            )
                          ],
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            backgroundColor: Colors.transparent),
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
                                color: Colors.black,
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
                      validator: loginViewModel.validateEmail,
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
                              icon: Icon(_obsureText
                                  ? Icons.visibility
                                  : Icons.visibility_off))),
                      validator: loginViewModel.validatePassword,
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
                                onChanged: (ref) {
                                  setState(() {
                                    _rememberMe = !_rememberMe;
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
                              _formKey.currentState!.reset();
                              if (_formKey.currentState!.validate()) {
                                context.pushReplacement('/');
                              }
                            },
                            child: const Text(
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
