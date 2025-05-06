import 'package:flutter/material.dart';
import 'package:link_up/features/company_profile/widgets/create_card.dart';
import 'package:go_router/go_router.dart';

class CreateInstitute extends StatelessWidget {
  const CreateInstitute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Create a LinkUp Page',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Connect with clients, employees, and the LinkUp community. To get started, choose a page type.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                PageTypeCard(
                  imagePath: 'assets/images/company.png',
                  title: 'Company',
                  subtitle: 'Create a page for your company',
                  onTap: () {
                  GoRouter.of(context).push('/create-company');                     },
                ),
                const SizedBox(height: 20),
                PageTypeCard(
                  imagePath: 'assets/images/school.png',
                  title: 'School/University',
                  subtitle: 'Create a page for your school/university',
                  onTap: () {
                  GoRouter.of(context).push('/create-company');                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
