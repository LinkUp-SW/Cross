import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/core/constants/constantvariables.dart';
import 'package:link_up/features/signUp/viewModel/past_job_details_provider.dart';
import 'package:country_state_city_pro/country_state_city_pro.dart';
import 'package:link_up/features/signUp/state/past_job_details_state.dart';
import 'package:link_up/features/signUp/widgets/widgets.dart';

class PastJobDetails extends ConsumerStatefulWidget {
  const PastJobDetails({super.key});

  @override
  ConsumerState<PastJobDetails> createState() => _PastJobDetailsState();
}

class _PastJobDetailsState extends ConsumerState<PastJobDetails> {
  bool amStudent = true;

  @override
  Widget build(BuildContext context) {
    final schoolController = TextEditingController();
    final startDateController = TextEditingController();
    final pastJobTitleController = TextEditingController();
    final pastJobCompanyController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final countryController = TextEditingController();
    final stateController = TextEditingController();
    final cityController = TextEditingController();
    final pastJobDetailsState = ref.watch(pastJobDetailProvider);
    final pastJobDetailsNotifier = ref.read(pastJobDetailProvider.notifier);

    ref.listen<PastJobDetailsState>(pastJobDetailProvider, (previous, next) {
      if (next is PastJobDetailsSuccess) {
        context.go('/signup/otp');
      } else if (next is PastJobDetailsError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.error)));
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                        Text(amStudent ? 'Yes' : 'No'),
                        SizedBox(
                          width: 10.w,
                        ),
                        Switch(
                          key: const Key('studentSwitch'),
                          value: amStudent,
                          onChanged: (value) {
                            setState(() {
                              amStudent = value;
                            });
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
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CountryStateCityPicker(
                      key: const Key('countryStateCityPicker'),
                      city: cityController,
                      state: stateController,
                      country: countryController,
                      textFieldDecoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(),
                        ),
                        labelStyle: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      dialogColor: Theme.of(context).colorScheme.primary,
                    ),
                    if (amStudent) ...[
                      SizedBox(
                        height: 15.h,
                      ),
                      AutocompleteSearchInput(
                        controller: schoolController,
                        label: 'School',
                        searchType: SearchType.school,
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      TextFormField(
                        key: const Key('startDateTextField'),
                        controller: startDateController,
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
                            startDateController.text =
                                "${pastJobDetailsNotifier.selectedDate!.day}/${pastJobDetailsNotifier.selectedDate!.month}/${pastJobDetailsNotifier.selectedDate!.year}";
                          }
                        },
                      ),
                    ] else ...[
                      SizedBox(
                        height: 15.h,
                      ),
                      DropdownButtonFormField<String>(
                        key: const Key('pastJobTitleDropdown'),
                        decoration: const InputDecoration(
                          labelText: 'Past Job Type',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                        ),
                        items: jobTypes.map((title) {
                          return DropdownMenuItem<String>(
                            value: title,
                            child: Text(title),
                          );
                        }).toList(),
                        onChanged: (value) {
                          pastJobTitleController.text = value ?? '';
                        },
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      AutocompleteSearchInput(
                        controller: pastJobCompanyController,
                        label: 'Past Job Company',
                        searchType: SearchType.company,
                      ),
                    ],
                    SizedBox(
                      height: 100.h,
                    ),
                    ElevatedButton(
                      key: const Key('continueButton'),
                      onPressed: pastJobDetailsState is PastJobDetailsLoading
                          ? null
                          : () {
                              pastJobDetailsNotifier.setData(
                                amStudent,
                                countryController.text,
                                cityController.text,
                                pastJobTitleController.text,
                                pastJobCompanyController.text,
                                schoolController.text,
                                startDateController.text,
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
