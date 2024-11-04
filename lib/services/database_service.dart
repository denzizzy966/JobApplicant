// lib/services/database_service.dart

import '../models/applicant.dart';
import '../models/applicant_status.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final List<Applicant> _applicants = [];

  List<Applicant> getAllApplicants({bool includeHidden = false}) {
    if (includeHidden) {
      return List.from(_applicants);
    }
    return _applicants.where((applicant) => !applicant.isHidden).toList();
  }

  Future<void> addApplicant(Applicant applicant) async {
    _applicants.add(applicant);
  }

  Future<void> updateApplicant(Applicant applicant) async {
    final index = _applicants.indexWhere((a) => a.id == applicant.id);
    if (index != -1) {
      _applicants[index] = applicant;
    }
  }

  Future<void> toggleHideApplicant(String id) async {
    final index = _applicants.indexWhere((a) => a.id == id);
    if (index != -1) {
      final applicant = _applicants[index];
      _applicants[index] = applicant.copyWith(isHidden: !applicant.isHidden);
    }
  }

  Future<void> updateApplicantStatus(String id, ApplicantStatus status) async {
    final index = _applicants.indexWhere((a) => a.id == id);
    if (index != -1) {
      final applicant = _applicants[index];
      _applicants[index] = applicant.copyWith(status: status);
    }
  }

  Applicant? getApplicantById(String id) {
    try {
      return _applicants.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteApplicant(String id) async {
    _applicants.removeWhere((a) => a.id == id);
  }
}