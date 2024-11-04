// lib/providers/applicant_provider.dart

import 'package:flutter/foundation.dart';
import '../models/applicant.dart';
import '../services/database_service.dart';

class ApplicantProvider extends ChangeNotifier {
  final _databaseService = DatabaseService();
  List<Applicant> _applicants = [];
  Applicant? _currentApplicant;

  List<Applicant> get applicants => _applicants;
  Applicant? get currentApplicant => _currentApplicant;

  // Initialize provider
  Future<void> loadApplicants() async {
    _applicants = _databaseService.getAllApplicants();
    notifyListeners();
  }

  // Add new applicant
  Future<void> addApplicant(Applicant applicant) async {
    await _databaseService.addApplicant(applicant);
    await loadApplicants();
  }

  // Update existing applicant
  Future<void> updateApplicant(Applicant applicant) async {
    await _databaseService.updateApplicant(applicant);
    await loadApplicants();
  }

  // Delete applicant
  Future<void> deleteApplicant(String id) async {
    await _databaseService.deleteApplicant(id);
    await loadApplicants();
  }

  // Set current applicant for editing
  void setCurrentApplicant(Applicant? applicant) {
    _currentApplicant = applicant;
    notifyListeners();
  }

  // Clear current applicant
  void clearCurrentApplicant() {
    _currentApplicant = null;
    notifyListeners();
  }
}