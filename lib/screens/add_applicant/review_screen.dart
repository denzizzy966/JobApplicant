// lib/screens/add_applicant/review_screen.dart

import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/applicant.dart';
import '../../services/database_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/step_progress_indicator.dart';
import '../../models/social_media.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

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
    return DateFormat('dd MMMM yyyy').format(date);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
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

  // Tambahkan widget baru untuk menampilkan social media
  Widget _buildSocialMediaSection() {

    print('Review - Social Media count: ${applicant.socialMedia.length}');

    if (applicant.socialMedia.isEmpty) {
      return const SizedBox.shrink();
    }

     return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildSectionTitle('Social Media'),
      Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...applicant.socialMedia.map((social) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        social.type.label,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        social.type == SocialMediaType.website 
                          ? social.fullUrl 
                          : '@${social.username}',
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Aplikasi',style:TextStyle(color:Colors.white)),
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
                  // Personal Information
                  _buildSectionTitle('Personal Information'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow('Name', '${applicant.firstName} ${applicant.lastName}'),
                          _buildInfoRow('Email', applicant.email),
                          _buildInfoRow('Birth Date', _formatDate(applicant.birthDate)),
                          _buildInfoRow('Position', applicant.position),
                          _buildInfoRow('Phone', applicant.phone),
                          _buildInfoRow('Address', applicant.address),
                        ],
                      ),
                    ),
                  ),

                  // Education
                  _buildSectionTitle('Education'),
                  if (applicant.education.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No education data added'),
                      ),
                    )
                  else
                    ...applicant.education.map((edu) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('School', edu.school),
                            _buildInfoRow('Degree', edu.degree),
                            _buildInfoRow('Field of Study', edu.fieldOfStudy),
                            _buildInfoRow(
                              'Period',
                              '${_formatDate(edu.startDate)} - ${_formatDate(edu.endDate)}',
                            ),
                          ],
                        ),
                      ),
                    )),

                  // Work History
                  _buildSectionTitle('Work History'),
                  if (applicant.workExperience.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No work experience added'),
                      ),
                    )
                  else
                    ...applicant.workExperience.map((exp) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Company', exp.company),
                            _buildInfoRow('Position', exp.position),
                            _buildInfoRow(
                              'Period',
                              '${_formatDate(exp.startDate)} - ${_formatDate(exp.endDate)}',
                            ),
                            if (exp.description.isNotEmpty)
                              _buildInfoRow('Description', exp.description),
                          ],
                        ),
                      ),
                    )),

                  // Social Media Section
                  _buildSocialMediaSection(),

                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Submit Application',
                    onPressed: () => _showSubmitDialog(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSubmitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Application'),
        content: const Text(
          'Are you sure you want to submit this application? Please review all information carefully.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _databaseService.addApplicant(applicant);
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ApplicantListScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}