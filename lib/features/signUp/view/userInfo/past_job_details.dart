import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/signUp/viewModel/view_model.dart';
import 'package:link_up/features/signUp/state/past_job_details_state.dart';

class PastJobDetails extends ConsumerWidget {
  const PastJobDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _formKey = GlobalKey<FormState>();
    final pastJobDetailsState = ref.watch(pastJobDetailsProvider);
    final pastJobDetailsNotifier = ref.read(pastJobDetailsProvider.notifier);
    final pastjobsprovider = ref.watch(pastJobDetailsViewModelProvider);

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
                  if (pastJobDetailsState.amStudent)
                    const Text('Yes')
                  else
                    const Text('No'),
                  Checkbox(
                    value: pastJobDetailsState.amStudent,
                    onChanged: (value) {
                      pastJobDetailsNotifier.toggleStudentStatus();
                    },
                    checkColor: Colors.blue,
                  )
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
                      controller: pastJobDetailsState.locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(),
                        ),
                      ),
                    ),
                    if (pastJobDetailsState.amStudent) ...[
                      SizedBox(
                        height: 20.h,
                      ),
                      TextFormField(
                        controller: pastJobDetailsState.schoolController,
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
                        controller: pastJobDetailsState.startDateController,
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                          suffixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                        ),
                        readOnly: true,
                        onTap: () async {
                          await pastjobsprovider.pickDate(context);
                          if (pastjobsprovider.selectedDate != null) {
                            pastJobDetailsNotifier.updateStartDate(
                                "${pastjobsprovider.selectedDate!.day}/${pastjobsprovider.selectedDate!.month}/${pastjobsprovider.selectedDate!.year}");
                          }
                        },
                      ),
                    ] else ...[
                      SizedBox(
                        height: 20.h,
                      ),
                      TextFormField(
                        controller: pastJobDetailsState.pastJobTitleController,
                        focusNode: pastJobDetailsState.pastJobTitleFocusNode,
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
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 400),
                        opacity:
                            pastJobDetailsState.showJobLocationField ? 1 : 0,
                        child: Visibility(
                          visible: pastJobDetailsState.showJobLocationField,
                          child: TextFormField(
                            controller:
                                pastJobDetailsState.pastJobLocationController,
                            decoration: const InputDecoration(
                              labelText: 'Past Job Company',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(
                      height: 240.h,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.push('/signup/verification');
                      },
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
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
