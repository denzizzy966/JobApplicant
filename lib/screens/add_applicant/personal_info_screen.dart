// lib/screens/add_applicant/personal_info_screen.dart
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/applicant.dart';
import '../../models/applicant_status.dart';
import '../../models/social_media.dart';
import '../../services/database_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/social_media_editor.dart';
import '../../widgets/social_media_display.dart';
import '../../widgets/step_progress_indicator.dart';
import 'education_screen.dart';
import 'package:intl/intl.dart';

class PersonalInfoScreen extends StatefulWidget {
  final Applicant? applicant; // null untuk mode tambah baru

  const PersonalInfoScreen({
    Key? key,
    this.applicant,
  }) : super(key: key);

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _positionController;
  late TextEditingController _addressController;
  DateTime? _birthDate;
  bool isEditMode = false;
  List<SocialMedia> _socialMedia = [];

  @override
  void initState() {
    super.initState();
    isEditMode = widget.applicant != null;
    _initializeControllers();
    _initializeSocialMedia();
  }

  void _initializeControllers() {
    // Initialize controllers with existing data if in edit mode
    _firstNameController =
        TextEditingController(text: widget.applicant?.firstName ?? '');
    _lastNameController =
        TextEditingController(text: widget.applicant?.lastName ?? '');
    _emailController =
        TextEditingController(text: widget.applicant?.email ?? '');
    _phoneController =
        TextEditingController(text: widget.applicant?.phone ?? '');
    _positionController =
        TextEditingController(text: widget.applicant?.position ?? '');
    _addressController =
        TextEditingController(text: widget.applicant?.address ?? '');

    if (isEditMode && widget.applicant?.birthDate != null) {
      _birthDate = DateTime.parse(widget.applicant!.birthDate);
    }
  }

  void _initializeSocialMedia() {
    if (widget.applicant != null) {
      _socialMedia = List.from(widget.applicant!.socialMedia);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[\d-]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate() && _birthDate != null) {
      // Debug print
      print('Social Media count: ${_socialMedia.length}');
      for (var sm in _socialMedia) {
        print('Social Media: ${sm.type.label} - ${sm.username}');
      }
      final updatedApplicant = Applicant(
        id: widget.applicant?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        birthDate: _birthDate!.toIso8601String(),
        position: _positionController.text,
        education: widget.applicant?.education ?? [],
        workExperience: widget.applicant?.workExperience ?? [],
        status: widget.applicant?.status ?? ApplicantStatus.pending,
        socialMedia: _socialMedia, // Add this
        isHidden: widget.applicant?.isHidden ?? false,
      );

      print('Applicant social media count: ${updatedApplicant.socialMedia.length}');

      if (isEditMode) {
        // Jika mode edit, simpan perubahan dan kembali
        _saveChanges(updatedApplicant);
      } else {
        // Jika mode tambah baru, lanjut ke education screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EducationScreen(
              applicant: updatedApplicant,
              isEditMode: false,
            ),
          ),
        );
      }
    }
  }

  void _saveChanges(Applicant updatedApplicant) async {
    await _databaseService.updateApplicant(updatedApplicant);
    if (mounted) {
      Navigator.pop(context); // Kembali ke detail screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            isEditMode ? 'Edit Personal Information' : 'Personal Information',style:TextStyle(color:Colors.white)),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          if (!isEditMode) // Tampilkan hanya jika mode tambah baru
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const StepProgressIndicator(
                currentStep: ApplicationStep.details,
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form Fields
                      CustomTextField(
                        label: 'First Name',
                        hint: 'Enter first name',
                        controller: _firstNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'First name is required';
                          }
                          return null;
                        },
                      ),

                      CustomTextField(
                        label: 'Last Name',
                        hint: 'Enter last name',
                        controller: _lastNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Last name is required';
                          }
                          return null;
                        },
                      ),

                      CustomTextField(
                        label: 'Email',
                        hint: 'Enter email address',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),

                      CustomTextField(
                        label: 'Phone',
                        hint: 'Enter phone number',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: _validatePhone,
                      ),

                      CustomTextField(
                        label: 'Position Applied',
                        hint: 'Enter position',
                        controller: _positionController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Position is required';
                          }
                          return null;
                        },
                      ),

                      CustomTextField(
                        label: 'Address',
                        hint: 'Enter address',
                        controller: _addressController,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Address is required';
                          }
                          return null;
                        },
                      ),

                      // Birth Date Picker
                      const Text(
                        'Birth Date',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _birthDate == null
                                  ? Colors.red
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _birthDate == null
                                    ? 'Select birth date'
                                    : DateFormat('dd MMMM yyyy')
                                        .format(_birthDate!),
                                style: TextStyle(
                                  color: _birthDate == null
                                      ? Colors.grey
                                      : AppColors.text,
                                ),
                              ),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                      if (_birthDate == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Birth date is required',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      SocialMediaEditor(
                        socialMedia: _socialMedia,
                        onChanged: (updatedSocialMedia) {
                          setState(() {
                            _socialMedia = updatedSocialMedia;
                          });
                        },
                      ),

                      const SizedBox(height: 32),

                      // Submit Button
                      CustomButton(
                        text: isEditMode ? 'Save Changes' : 'Continue',
                        onPressed: _handleSubmit,
                      ),

                      if (isEditMode) ...[
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Cancel',
                          onPressed: () => Navigator.pop(context),
                          isOutlined: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
