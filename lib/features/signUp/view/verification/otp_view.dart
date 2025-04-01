import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/signUp/state/otp_state.dart';
import 'package:link_up/features/signUp/viewModel/otp_provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpView extends ConsumerStatefulWidget {
  const OtpView({super.key});

  @override
  ConsumerState<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends ConsumerState<OtpView> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Call sendOtp after the widget tree has finished building
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(otpProvider.notifier).sendOtp();
    });
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpProvider);
    final otpNotifier = ref.read(otpProvider.notifier);

    ref.listen<OtpState>(otpProvider, (previous, next) {
      if (next is OtpSuccess) {
        context.push('/login');
      } else if (next is OtpError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
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
                image: AssetImage('assets/images/Logo.png'),
                height: 100,
                width: 100,
              ),
              const Text(
                "Enter the OTP sent to your email",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10.h,
              ),
              const Text(
                'Enter OTP',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(
                height: 10.h,
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PinCodeTextField(
                        key: const Key('otp_text_field'),
                        appContext: context,
                        length: 6,
                        controller: _otpController,
                        onChanged: (value) {},
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(5),
                          fieldHeight: 50,
                          fieldWidth: 40,
                          activeFillColor: Colors.white,
                          activeColor: Colors.blue,
                          selectedFillColor: Colors.white,
                          selectedColor: Colors.blue,
                          inactiveFillColor: Colors.white,
                          inactiveColor: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      TextButton(
                        key: const Key('resend_otp_button'),
                        onPressed: otpState is OtpLoading
                            ? null
                            : () {
                                otpNotifier.sendOtp();
                                _otpController.clear();
                              },
                        child: const Text('Resend OTP ?'),
                        style: const ButtonStyle(
                          overlayColor:
                              WidgetStatePropertyAll(Colors.transparent),
                          foregroundColor: WidgetStatePropertyAll(
                            Colors.blue,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        key: const Key('verify_otp_button'),
                        onPressed: otpState is OtpLoading
                            ? null
                            : () async {
                                await otpNotifier
                                    .verifyOtp(_otpController.text);
                                _otpController.clear();
                              },
                        child: otpState is OtpLoading
                            ? const CircularProgressIndicator()
                            : const Text('Verify OTP'),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
