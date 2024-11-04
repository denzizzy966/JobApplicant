// lib/models/applicant_status.dart

import 'package:flutter/material.dart';

enum ApplicantStatus {
  pending('Pending', 'Lamaran sedang dalam proses review'),
  interviewStage1('Interview Tahap 1', 'Pelamar akan mengikuti interview pertama'),
  interviewStage2('Interview Tahap 2', 'Pelamar akan mengikuti interview lanjutan'),
  interviewStage3('Interview Tahap 3', 'Pelamar akan mengikuti interview final'),
  passed('Lolos Seleksi Interview', 'Pelamar telah lolos seluruh tahapan interview'),
  rejected('Tidak Lolos', 'Pelamar tidak memenuhi kriteria yang dibutuhkan');

  final String label;
  final String description;
  const ApplicantStatus(this.label, this.description);
}

class StatusHelper {
  static Color getStatusColor(ApplicantStatus status) {
    switch (status) {
      case ApplicantStatus.pending:
        return Colors.grey;
      case ApplicantStatus.interviewStage1:
        return Colors.blue;
      case ApplicantStatus.interviewStage2:
        return Colors.orange;
      case ApplicantStatus.interviewStage3:
        return Colors.purple;
      case ApplicantStatus.passed:
        return Colors.green;
      case ApplicantStatus.rejected:
        return Colors.red;
    }
  }

  static IconData getStatusIcon(ApplicantStatus status) {
    switch (status) {
      case ApplicantStatus.pending:
        return Icons.hourglass_empty;
      case ApplicantStatus.interviewStage1:
        return Icons.looks_one;
      case ApplicantStatus.interviewStage2:
        return Icons.looks_two;
      case ApplicantStatus.interviewStage3:
        return Icons.looks_3;
      case ApplicantStatus.passed:
        return Icons.check_circle;
      case ApplicantStatus.rejected:
        return Icons.cancel;
    }
  }

  // Helper untuk mendapatkan status berikutnya
  static ApplicantStatus? getNextStatus(ApplicantStatus currentStatus) {
    switch (currentStatus) {
      case ApplicantStatus.pending:
        return ApplicantStatus.interviewStage1;
      case ApplicantStatus.interviewStage1:
        return ApplicantStatus.interviewStage2;
      case ApplicantStatus.interviewStage2:
        return ApplicantStatus.interviewStage3;
      case ApplicantStatus.interviewStage3:
        return ApplicantStatus.passed;
      default:
        return null;
    }
  }
  
  // Helper untuk mengecek apakah status bisa diubah ke status berikutnya
  static bool canMoveToNextStatus(ApplicantStatus currentStatus) {
    return currentStatus != ApplicantStatus.passed && 
           currentStatus != ApplicantStatus.rejected;
  }

  // Helper untuk mendapatkan daftar status yang tersedia berdasarkan status saat ini
  static List<ApplicantStatus> getAvailableStatuses(ApplicantStatus currentStatus) {
    if (currentStatus == ApplicantStatus.passed || 
        currentStatus == ApplicantStatus.rejected) {
      return [currentStatus];
    }

    final List<ApplicantStatus> availableStatuses = [];
    ApplicantStatus? nextStatus = currentStatus;

    while (nextStatus != null) {
      availableStatuses.add(nextStatus);
      nextStatus = getNextStatus(nextStatus);
    }
    
    // Tambahkan opsi reject
    availableStatuses.add(ApplicantStatus.rejected);
    
    return availableStatuses;
  }
}