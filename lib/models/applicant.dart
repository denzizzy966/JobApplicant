// lib/models/applicant.dart

import 'education.dart';
import 'social_media.dart';
import 'work_experience.dart';
import 'applicant_status.dart';  // Import ApplicantStatus dari file baru

class Applicant {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;      // Tambahkan field phone
  final String address;    // Tambahkan field address
  final String birthDate;
  final String position;
  final List<Education> education;
  final List<WorkExperience> workExperience;
  final List<SocialMedia> socialMedia;
  final ApplicantStatus status;
  final bool isHidden;

  Applicant({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.birthDate,
    required this.position,
    this.education = const [],
    this.workExperience = const [],
    this.socialMedia = const [], // Add this
    this.status = ApplicantStatus.pending,
    this.isHidden = false,
  });

  // Copy with method
  Applicant copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    String? birthDate,
    String? position,
    List<Education>? education,
    List<WorkExperience>? workExperience,
    List<SocialMedia>? socialMedia,
    ApplicantStatus? status,
    bool? isHidden,
  }) {
    return Applicant(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      birthDate: birthDate ?? this.birthDate,
      position: position ?? this.position,
      education: education ?? this.education,
      workExperience: workExperience ?? this.workExperience,
      socialMedia: socialMedia ?? this.socialMedia,
      status: status ?? this.status,
      isHidden: isHidden ?? this.isHidden,
    );
  }

  // ToMap method
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'birthDate': birthDate,
      'position': position,
      'education': education.map((e) => e.toMap()).toList(),
      'workExperience': workExperience.map((e) => e.toMap()).toList(),
      'socialMedia': socialMedia.map((sm) => sm.toMap()).toList(),
      'status': status.name,
      'isHidden': isHidden,
    };
  }

  // FromMap factory
  factory Applicant.fromMap(Map<String, dynamic> map) {
    return Applicant(
      id: map['id'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      birthDate: map['birthDate'] ?? '',
      position: map['position'] ?? '',
      education: List<Education>.from(
        map['education']?.map((x) => Education.fromMap(x)) ?? [],
      ),
      workExperience: List<WorkExperience>.from(
        map['workExperience']?.map((x) => WorkExperience.fromMap(x)) ?? [],
      ),
      socialMedia: List<SocialMedia>.from(
        map['socialMedia']?.map((x) => SocialMedia.fromMap(x)) ?? [],
      ),
      status: ApplicantStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ApplicantStatus.pending,
      ),
      isHidden: map['isHidden'] ?? false,
    );
  }
}