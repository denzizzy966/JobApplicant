// lib/services/export_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/applicant.dart';

class ExportService {
  // Export to JSON
  Future<String> exportToJson(List<Applicant> applicants) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/applicants.json');
    
    final jsonList = applicants.map((a) => a.toMap()).toList();
    final jsonString = jsonEncode(jsonList);
    
    await file.writeAsString(jsonString);
    return file.path;
  }

  // Export to Excel
  Future<String> exportToExcel(List<Applicant> applicants) async {
    final excel = Excel.createExcel();
    final sheet = excel['Applicants'];

    // Add headers
    sheet.appendRow([
      'ID',
      'First Name',
      'Last Name',
      'Email',
      'Birth Date',
      'Position',
      'Education',
      'Work Experience'
    ]);

    // Add data
    for (var applicant in applicants) {
      sheet.appendRow([
        applicant.id,
        applicant.firstName,
        applicant.lastName,
        applicant.email,
        applicant.birthDate,
        applicant.position,
        applicant.education.map((e) => '${e.degree} in ${e.fieldOfStudy} at ${e.school}').join('; '),
        applicant.workExperience.map((e) => '${e.position} at ${e.company}').join('; '),
      ]);
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/applicants.xlsx');
    
    await file.writeAsBytes(excel.encode()!);
    return file.path;
  }

  // Export to PDF
  Future<String> exportToPdf(List<Applicant> applicants) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Applicants List', style: pw.TextStyle(fontSize: 24)),
            ),
            pw.SizedBox(height: 20),
            ...applicants.map((applicant) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${applicant.firstName} ${applicant.lastName}',
                        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text('Position: ${applicant.position}'),
                      pw.Text('Email: ${applicant.email}'),
                      pw.Text('Birth Date: ${applicant.birthDate}'),
                      pw.SizedBox(height: 10),
                      pw.Text('Education:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ...applicant.education.map((edu) => pw.Text(
                        '- ${edu.degree} in ${edu.fieldOfStudy} at ${edu.school}',
                      )),
                      pw.SizedBox(height: 10),
                      pw.Text('Work Experience:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ...applicant.workExperience.map((exp) => pw.Text(
                        '- ${exp.position} at ${exp.company}',
                      )),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
              ],
            )).toList(),
          ];
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/applicants.pdf');
    
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }
}