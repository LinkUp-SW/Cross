import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/logIn/state/forgot_password_state.dart';
import 'package:link_up/features/logIn/viewModel/forgot_password_view_model.dart';
import 'package:link_up/shared/functions.dart';

class ForgotPasswordView extends ConsumerStatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  ConsumerState<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends ConsumerState<ForgotPasswordView> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final forgotPasswordState = ref.watch(forgotPasswordProvider);
    final forgotPasswordNotifier = ref.read(forgotPasswordProvider.notifier);

    ref.listen<ForgotPasswordState>(forgotPasswordProvider, (previous, next) {
      if (next is ForgotPasswordSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email sent successfully'),
          ),
        );
        context.push('/login');
      } else if (next is ForgotPasswordFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error),
          ),
        );
      }
    });

    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Image(
                width: 100,
                height: 100,
                image: AssetImage('assets/images/Logo.png'),
              ),
              const Text(
                'Forgot Password',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 5.h,
              ),
              SizedBox(
                height: 5.h,
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        key: const Key('emailTextField'),
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                        ),
                        validator: (value) => validateEmail(value),
                      ),
                      SizedBox(
                        height: 30.h,
                      ),
                      ElevatedButton(
                        key: const Key('sendEmailButton'),
                        onPressed: () {
                          if (_formKey.currentState?.validate() != false) {
                            forgotPasswordNotifier
                                .forgotPassword(_emailController.text);
                          }
                          _emailController.clear();
                        },
                        child: forgotPasswordState is ForgotPasswordLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Send Email',
                                style: TextStyle(fontSize: 20),
                              ),
                      ),
                    ],
                  )),
              SizedBox(
                height: 5.h,
              ),
            ],
          ))),
    );
  }
}
