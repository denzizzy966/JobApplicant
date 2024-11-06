// lib/screens/add_applicant/work_experience_screen.dart
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/applicant.dart';
import '../../models/work_experience.dart';
import '../../services/database_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/step_progress_indicator.dart';
import 'review_screen.dart';

class WorkExperienceScreen extends StatefulWidget {
  final Applicant applicant;
  final bool isEditMode;

  const WorkExperienceScreen({
    Key? key,
    required this.applicant,
    this.isEditMode = false,
  }) : super(key: key);

  @override
  State<WorkExperienceScreen> createState() => _WorkExperienceScreenState();
}

class _WorkExperienceScreenState extends State<WorkExperienceScreen> {
  final List<WorkExperience> _experienceList = [];
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool isEditMode = false;

  void _addExperience() {
    if (_formKey.currentState!.validate() && _startDate != null && _endDate != null) {
      setState(() {
        _experienceList.add(
          WorkExperience(
            company: _companyController.text,
            position: _positionController.text,
            description: _descriptionController.text,
            startDate: _startDate!.toIso8601String(),
            endDate: _endDate!.toIso8601String(),
          ),
        );
      });

      // Clear form
      _companyController.clear();
      _positionController.clear();
      _descriptionController.clear();
      _startDate = null;
      _endDate = null;
    }
  }

  void _handleContinue() {
    
    print('WorkExp - Social Media count: ${widget.applicant.socialMedia.length}');

    final updatedApplicant = widget.applicant.copyWith(
      workExperience: _experienceList,
    );

    if (widget.isEditMode) {
      // Jika mode edit, simpan perubahan dan kembali
      _saveChanges(updatedApplicant);
    } else {
      // Jika mode tambah baru, lanjut ke review
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewScreen(
            applicant: updatedApplicant,
          ),
        ),
      );
    }
  }

  void _saveChanges(Applicant updatedApplicant) async {
    await _databaseService.updateApplicant(updatedApplicant);
    if (mounted) {
      Navigator.pop(context); // Kembali ke detail screen
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Pengalaman Kerja' : 'Pengalaman Kerja'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          if (!isEditMode)
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const StepProgressIndicator(
                currentStep: ApplicationStep.workHistory,
              ),
            ),
      Expanded(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Added Experience List
            if (_experienceList.isNotEmpty) ...[
              const Text(
                'Added Experience',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _experienceList.length,
                itemBuilder: (context, index) {
                  final experience = _experienceList[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(experience.position),
                      subtitle: Text(experience.company),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _experienceList.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            // Add Experience Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Experience',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Company',
                    hint: 'Enter company name',
                    controller: _companyController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter company name';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    label: 'Position',
                    hint: 'Enter position',
                    controller: _positionController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter position';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    label: 'Description',
                    hint: 'Enter job description',
                    controller: _descriptionController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter job description';
                      }
                      return null;
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Start Date',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _selectDate(context, true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _startDate == null
                                          ? 'Select date'
                                          : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                                      style: TextStyle(
                                        color: _startDate == null
                                            ? Colors.grey
                                            : AppColors.text,
                                      ),
                                    ),
                                    const Icon(Icons.calendar_today),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'End Date',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _selectDate(context, false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _endDate == null
                                          ? 'Select date'
                                          : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                                      style: TextStyle(
                                        color: _endDate == null
                                            ? Colors.grey
                                            : AppColors.text,
                                      ),
                                    ),
                                    const Icon(Icons.calendar_today),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Add Experience',
                    onPressed: _addExperience,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Continue to Review',
              onPressed: () {
                final updatedApplicant = Applicant(
                  id: widget.applicant.id,
                  firstName: widget.applicant.firstName,
                  lastName: widget.applicant.lastName,
                  email: widget.applicant.email,
                  phone: widget.applicant.phone,
                  address: widget.applicant.address,
                  birthDate: widget.applicant.birthDate,
                  position: widget.applicant.position,
                  education: widget.applicant.education,
                  workExperience: _experienceList, 
                  socialMedia: widget.applicant.socialMedia,
                  status: widget.applicant.status,
                  isHidden: widget.applicant.isHidden,
                );

                print('WorkExp - Updated Social Media count: ${updatedApplicant.socialMedia.length}');

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewScreen(
                      applicant: updatedApplicant,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        
            ),
          ),
        ],
      ),
    );
  }
}