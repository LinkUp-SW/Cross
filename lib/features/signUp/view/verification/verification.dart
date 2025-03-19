import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/signUp/viewModel/verification_provider.dart';
import 'package:link_up/features/signUp/state/verfication_state.dart';

class Verification extends ConsumerStatefulWidget {
  const Verification({super.key});

  @override
  ConsumerState<Verification> createState() => _VerificationState();
}

class _VerificationState extends ConsumerState<Verification> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final verificationState = ref.watch(verficationProvider);
    final verificationNotifier = ref.read(verficationProvider.notifier);

    // Listen for state changes and handle navigation or error messages
    ref.listen<VerificationState>(verficationProvider, (previous, next) {
      if (next is VerificationSuccess) {
        context.push('/signup/pastjobs'); // Navigate to the next page
      } else if (next is VerificationFailure) {
        // Show an error message if verification fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
      }
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Enter the code sent to your phone",
                style: TextStyle(fontSize: 25),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'To finish creating your account, please enter the verification code sent to your phone',
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 5,
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Verification Code',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(),
                        ),
                      ),
                      validator: (value) =>
                          verificationNotifier.validateCode(value),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Didn’t receive the code?',
                      style: TextStyle(fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    TextButton(
                      onPressed: () async {
                        await verificationNotifier.resendCode();
                      },
                      child: verificationState is ResendCodeLoading
                          ? const CircularProgressIndicator()
                          : const Text('Resend Code'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await verificationNotifier.verifyCode(
                            _codeController.text,
                          );
                        }
                      },
                      child: verificationState is VerificationLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
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
