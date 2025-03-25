import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/signUp/viewModel/past_job_details_provider.dart';

import 'package:link_up/features/signUp/state/past_job_details_state.dart';

class PastJobDetails extends ConsumerWidget {
  const PastJobDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _locationController = TextEditingController();
    final _schoolController = TextEditingController();
    final _startDateController = TextEditingController();
    final _pastJobTitleController = TextEditingController();
    final _pastJobTitleFocusNode = FocusNode();
    final _pastJobCompanyController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    final pastJobDetailsState = ref.watch(pastJobDetailProvider);
    final pastJobDetailsNotifier = ref.read(pastJobDetailProvider.notifier);
    bool amStudent = pastJobDetailsState is Student;

    ref.listen<PastJobDetailsState>(pastJobDetailProvider, (previous, next) {
      if (next is PastJobDetailsSuccess) {
        context.go('/signup/otp');
      } else if (next is PastJobDetailsError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.error)));
      }
    });

    ref.listen<PastJobDetailsState>(pastJobDetailProvider, (previous, next) {
      if (next is Job) {
        amStudent = false;
      } else if (next is Student) {
        amStudent = true;
      }
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Image(
                image: AssetImage('assets/images/Logo.png'),
                height: 100,
                width: 100,
              ),
              const Text(
                "Your Profile helps you discover new people and opportunities",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    'are you a student?',
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (amStudent) const Text('Yes') else const Text('No'),
                        SizedBox(
                          width: 10.w,
                        ),
                        Switch(
                          value: pastJobDetailsState is Student,
                          onChanged: (value) {
                            pastJobDetailsNotifier.toggleStudentStatus();
                          },
                          activeColor: Colors.blue,
                          activeTrackColor: Colors.blue,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.white,
                        ),
                      ])
                ],
              ),
              SizedBox(
                height: 20.h,
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(),
                        ),
                      ),
                    ),
                    if (amStudent) ...[
                      SizedBox(
                        height: 20.h,
                      ),
                      TextFormField(
                        controller: _schoolController,
                        decoration: const InputDecoration(
                          labelText: 'School/University',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      TextFormField(
                        controller: _startDateController,
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                          suffixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                        ),
                        readOnly: true,
                        onTap: () async {
                          await pastJobDetailsNotifier.pickDate(context);
                          if (pastJobDetailsNotifier.selectedDate != null) {
                            _startDateController.text =
                                "${pastJobDetailsNotifier.selectedDate!.day}/${pastJobDetailsNotifier.selectedDate!.month}/${pastJobDetailsNotifier.selectedDate!.year}";
                          }
                        },
                      ),
                    ] else ...[
                      SizedBox(
                        height: 20.h,
                      ),
                      TextFormField(
                        controller: _pastJobTitleController,
                        focusNode: _pastJobTitleFocusNode,
                        decoration: const InputDecoration(
                          labelText: 'Past Job Title',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      TextFormField(
                        controller: _pastJobCompanyController,
                        decoration: const InputDecoration(
                          labelText: 'Past Job Company',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(
                      height: 190.h,
                    ),
                    ElevatedButton(
                      onPressed: pastJobDetailsState is PastJobDetailsLoading
                          ? null
                          : () {
                              pastJobDetailsNotifier.setData(
                                _locationController.text,
                                _pastJobTitleController.text,
                                _pastJobCompanyController.text,
                                _schoolController.text,
                                _startDateController.text,
                              );
                            },
                      child: pastJobDetailsState is PastJobDetailsLoading
                          ? const CircularProgressIndicator()
                          : const Text('Continue',
                              style: TextStyle(fontSize: 20)),
                    )
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
