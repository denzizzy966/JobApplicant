// lib/screens/add_applicant/education_screen.dart
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/applicant.dart';
import '../../models/education.dart';
import '../../services/database_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/step_progress_indicator.dart';
import 'work_experience_screen.dart';

class EducationScreen extends StatefulWidget {
  final Applicant applicant;
  final bool isEditMode;

  const EducationScreen({
    Key? key,
    required this.applicant,
    this.isEditMode = false,
  }) : super(key: key);

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final List<Education> _educationList = [];
  final _formKey = GlobalKey<FormState>();
  final _schoolController = TextEditingController();
  final _degreeController = TextEditingController();
  final _fieldController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool isEditMode = false;

  void _addEducation() {
    if (_formKey.currentState!.validate() && _startDate != null && _endDate != null) {
      setState(() {
        _educationList.add(
          Education(
            school: _schoolController.text,
            degree: _degreeController.text,
            fieldOfStudy: _fieldController.text,
            startDate: _startDate!.toIso8601String(),
            endDate: _endDate!.toIso8601String(),
          ),
        );
      });

      // Clear form
      _schoolController.clear();
      _degreeController.clear();
      _fieldController.clear();
      _startDate = null;
      _endDate = null;
    }
  }

  void _handleContinue() {
    final updatedApplicant = widget.applicant.copyWith(
      education: _educationList,
    );

    if (widget.isEditMode) {
      // Jika mode edit, simpan perubahan dan kembali
      _saveChanges(updatedApplicant);
    } else {
      // Jika mode tambah baru, lanjut ke work experience
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkExperienceScreen(
            applicant: updatedApplicant,
            isEditMode: false,
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
        title: Text(isEditMode ? 'Edit Pendidikan' : 'Pendidikan'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          if (!isEditMode)
            Container(
              color: AppColors.primary,
              padding: const EdgeInsets.only(bottom: 20),
              child: const StepProgressIndicator(
                currentStep: ApplicationStep.education,
              ),
            ),
      Expanded(
        child:SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Added Education List
              if (_educationList.isNotEmpty) ...[
                const Text(
                  'Added Education',
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
                  itemCount: _educationList.length,
                  itemBuilder: (context, index) {
                    final education = _educationList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(education.school),
                        subtitle: Text('${education.degree} in ${education.fieldOfStudy}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _educationList.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Add Education Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Education',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'School/University',
                      hint: 'Enter school name',
                      controller: _schoolController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter school name';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      label: 'Degree',
                      hint: 'Enter degree',
                      controller: _degreeController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter degree';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      label: 'Field of Study',
                      hint: 'Enter field of study',
                      controller: _fieldController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter field of study';
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
                      text: 'Add Education',
                      onPressed: _addEducation,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Continue',
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
                    education: _educationList,          // Menggunakan list pendidikan yang sudah diupdate
                    workExperience: widget.applicant.workExperience,
                    status: widget.applicant.status,
                    isHidden: widget.applicant.isHidden,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkExperienceScreen(
                        applicant: updatedApplicant,
                        isEditMode: widget.isEditMode,
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