import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/signUp/state/name_state.dart';
import 'package:link_up/features/signUp/viewModel/name_provider.dart';

class NamingPage extends ConsumerStatefulWidget {
  const NamingPage({super.key});

  @override
  ConsumerState<NamingPage> createState() => _NamingPageState();
}

class _NamingPageState extends ConsumerState<NamingPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final nameState = ref.watch(nameProvider);
    final nameNotifier = ref.read(nameProvider.notifier);

    // Move ref.listen to the build method
    ref.listen<NameState>(nameProvider, (previous, next) {
      if (next is NameValid) {
        context.push('/signup/getphone'); // Navigate to the next page
      } else if (next is NameInvalid) {
        // Show an error message if the name is invalid
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
              const SizedBox(height: 10),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        hintText: 'Enter your first name',
                      ),
                      validator: (value) =>
                          nameNotifier.validateName(value, "First Name"),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        hintText: 'Enter your last name',
                      ),
                      validator: (value) =>
                          nameNotifier.validateName(value, "Last Name"),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await nameNotifier.setName(
                            _firstNameController.text,
                            _lastNameController.text,
                          );
                        }
                      },
                      child: nameState is NameLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Next'),
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