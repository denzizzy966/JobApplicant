// lib/utils/status_helper.dart
import 'package:flutter/material.dart';
import '../models/applicant_status.dart';

Color getStatusColor(ApplicantStatus status) {
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