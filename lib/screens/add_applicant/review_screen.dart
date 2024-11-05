// lib/screens/add_applicant/review_screen.dart
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/applicant.dart';
import '../../services/database_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/step_progress_indicator.dart';
import '../applicant_list_screen.dart';

class ReviewScreen extends StatelessWidget {
  final Applicant applicant;
  final DatabaseService _databaseService = DatabaseService();

  ReviewScreen({
    Key? key,
    required this.applicant,
  }) : super(key: key);

  String _formatDate(String isoString) {
    final date = DateTime.parse(isoString);
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Aplikasi'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.only(bottom: 20),
            child: const StepProgressIndicator(
              currentStep: ApplicationStep.review,
            ),
          ),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Personal Information',
              [
                _buildInfoRow('Name', '${applicant.firstName} ${applicant.lastName}'),
                _buildInfoRow('Email', applicant.email),
                _buildInfoRow('Birth Date', _formatDate(applicant.birthDate)),
                _buildInfoRow('Position', applicant.position),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Education',
              applicant.education.map((edu) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('School', edu.school),
                  _buildInfoRow('Degree', edu.degree),
                  _buildInfoRow('Field of Study', edu.fieldOfStudy),
                  _buildInfoRow(
                    'Period',
                    '${_formatDate(edu.startDate)} - ${_formatDate(edu.endDate)}',
                  ),
                  const Divider(height: 24),
                ],
              )).toList(),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Work Experience',
              applicant.workExperience.map((exp) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Company', exp.company),
                  _buildInfoRow('Position', exp.position),
                  _buildInfoRow(
                    'Period',
                    '${_formatDate(exp.startDate)} - ${_formatDate(exp.endDate)}',
                  ),
                  _buildInfoRow('Description', exp.description),
                  const Divider(height: 24),
                ],
              )).toList(),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Submit Application',
              onPressed: () async {
                // Save to database
                await _databaseService.addApplicant(applicant);

                // Show success dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Success'),
                    content: const Text(
                      'Your application has been submitted successfully.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Navigate back to list screen
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const ApplicantListScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
          ),
        ),
        ],
      )
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}