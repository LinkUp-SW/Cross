import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:link_up/features/signUp/viewModel/phone_number_provider.dart';
import 'package:link_up/features/signUp/state/phone_number_state.dart';

class GetPhoneNumber extends ConsumerStatefulWidget {
  const GetPhoneNumber({super.key});

  @override
  ConsumerState<GetPhoneNumber> createState() => _GetPhoneNumberState();
}

class _GetPhoneNumberState extends ConsumerState<GetPhoneNumber> {
  final _formKey = GlobalKey<FormState>();
  String? _countryCode;
  String? _phoneNumber;
  String? _countryName;

  @override
  Widget build(BuildContext context) {
    final phoneNumberState = ref.watch(phoneNumberProvider);
    final phoneNumberNotifier = ref.read(phoneNumberProvider.notifier);

    // Listen for state changes and handle navigation or error messages
    ref.listen<PhoneNumberState>(phoneNumberProvider, (previous, next) {
      if (next is PhoneNumberValid) {
        context.push('/signup/pastjobs'); // Navigate to the next page
      } else if (next is PhoneNumberInvalid) {
        // Show an error message if the phone number is invalid
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage)),
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
                "Just a quick Security Check",
                style: TextStyle(
                  fontSize: 25,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'As an extra security step, we need to verify your phone number',
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10,
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IntlPhoneField(
                      key: const Key('phoneNumberField'),
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(),
                        ),
                      ),
                      initialCountryCode: 'EG',
                      onChanged: (phone) {
                        _countryCode = phone.countryCode;
                        _phoneNumber = phone.number;
                      },
                      validator: (value) {
                        if (value == null || value.number.isEmpty) {
                          return "Please enter a valid phone number";
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    ElevatedButton(
                      key: const Key('submitButton'),
                      onPressed: phoneNumberState is LoadingPhoneNumber
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                if (_countryCode != null &&
                                    _phoneNumber != null) {
                                  await phoneNumberNotifier.setPhoneNumber(
                                    _countryCode!,
                                    _phoneNumber!,
                                  );
                                }
                              }
                            },
                      child: phoneNumberState is LoadingPhoneNumber
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
