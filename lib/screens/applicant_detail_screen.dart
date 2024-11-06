// lib/screens/applicant_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../models/applicant.dart';
import '../models/applicant_status.dart';
import '../services/database_service.dart';
import '../widgets/social_media_display.dart';
import '../widgets/social_media_editor.dart';
import 'add_applicant/personal_info_screen.dart';
import 'add_applicant/education_screen.dart';
import 'add_applicant/work_experience_screen.dart';

class ApplicantDetailScreen extends StatefulWidget {
  final Applicant applicant;

  const ApplicantDetailScreen({
    Key? key,
    required this.applicant,
  }) : super(key: key);

  @override
  State<ApplicantDetailScreen> createState() => _ApplicantDetailScreenState();
}

class _ApplicantDetailScreenState extends State<ApplicantDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();
  late Applicant _applicant;

  @override
  void initState() {
    super.initState();
    _applicant = widget.applicant;
  }

  String _formatDate(String isoString) {
    final date = DateTime.parse(isoString);
    return DateFormat('dd MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Pelamar',
          style: TextStyle(color:Colors.white),),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit,
              color:Colors.white),
            onPressed: _showEditOptions,
          ),
          _buildMoreMenu(),
        ],
      ),
      body: SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          if (StatusHelper.canMoveToNextStatus(_applicant.status))
            _buildStatusActions(),  // Tambahkan di sini
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPersonalInfo(),
                const SizedBox(height: 16),
                _buildEducationInfo(),
                const SizedBox(height: 16),
                _buildWorkExperience(),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildHeader() {
    final color = StatusHelper.getStatusColor(_applicant.status);
    final icon = StatusHelper.getStatusIcon(_applicant.status);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: _applicant.isHidden ? Colors.grey : AppColors.primary,
            child: Text(
              _applicant.firstName[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${_applicant.firstName} ${_applicant.lastName}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _applicant.isHidden ? Colors.grey : Colors.black,
            ),
          ),
          Text(
            _applicant.position,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Text(
                  _applicant.status.label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (_applicant.isHidden) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility_off, size: 16, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    'Hidden',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

Widget _buildStatusActions() {
  final nextStatus = StatusHelper.getNextStatus(_applicant.status);
  
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        if (nextStatus != null) ...[
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: StatusHelper.getStatusColor(nextStatus).withOpacity(1.0),
                foregroundColor: StatusHelper.getStatusColor(nextStatus),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: Icon(StatusHelper.getStatusIcon(nextStatus)),
              label: Text('Lanjut ke ${nextStatus.label}', style:TextStyle(color:Colors.white)),
              onPressed: () async {
                await _databaseService.updateApplicantStatus(_applicant.id, nextStatus);
                setState(() {
                  _applicant = _applicant.copyWith(status: nextStatus);
                });
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (_applicant.status != ApplicantStatus.rejected)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(1.0),
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.cancel),
            label: const Text('Tidak Lolos',style:TextStyle(color:Colors.white)),
            onPressed: () async {
              await _databaseService.updateApplicantStatus(
                _applicant.id, 
                ApplicantStatus.rejected
              );
              setState(() {
                _applicant = _applicant.copyWith(status: ApplicantStatus.rejected);
              });
            },
          ),
      ],
    ),
  );
}


  Widget _buildMoreMenu() {
    return PopupMenuButton<String>(
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'status',
          child: Text('Ubah Status'),
        ),
        PopupMenuItem(
          value: 'visibility',
          child: Text(_applicant.isHidden ? 'Tampilkan' : 'Sembunyikan'),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Text(
            'Hapus',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
      onSelected: (value) async {
        switch (value) {
          case 'status':
            _showStatusChangeDialog();
            break;
          case 'visibility':
            await _databaseService.toggleHideApplicant(_applicant.id);
            setState(() {
              _applicant = _applicant.copyWith(isHidden: !_applicant.isHidden);
            });
            break;
          case 'delete':
            _showDeleteConfirmation();
            break;
        }
      },
    );
  }

  Widget _buildPersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Informasi Pribadi', Icons.person),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoItem('Email', _applicant.email, Icons.email),
                _buildInfoItem('Tanggal Lahir', _formatDate(_applicant.birthDate), Icons.cake),
                _buildInfoItem('Posisi', _applicant.position, Icons.work),
                if (_applicant.socialMedia.isNotEmpty) ...[
                const Divider(height: 24),
                const Text(
                  'Social Media',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                SocialMediaDisplay(
                  socialMedia: _applicant.socialMedia,
                  isCompact: true,
                ),
              ],
              ],
            ),
          ),
        ),
        if (_applicant.socialMedia.isNotEmpty) ...[
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SocialMediaDisplay(
              socialMedia: _applicant.socialMedia,
            ),
          ),
        ),
      ],
      ],
    );
  }

  Widget _buildEducationInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Pendidikan', Icons.school),
        if (_applicant.education.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Tidak ada data pendidikan'),
            ),
          )
        else
          ..._applicant.education.map((edu) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        edu.school,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${edu.degree} - ${edu.fieldOfStudy}'),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatDate(edu.startDate)} - ${_formatDate(edu.endDate)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  Widget _buildWorkExperience() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Pengalaman Kerja', Icons.work),
        if (_applicant.workExperience.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Tidak ada data pengalaman kerja'),
            ),
          )
        else
          ..._applicant.workExperience.map((exp) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exp.position,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(exp.company),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatDate(exp.startDate)} - ${_formatDate(exp.endDate)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      if (exp.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(exp.description),
                      ],
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              Text(value),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.person, color: AppColors.primary),
            title: const Text('Edit Data Pribadi'),
            onTap: () {
              Navigator.pop(context);
              _editPersonalInfo();
            },
          ),
          ListTile(
            leading: const Icon(Icons.school, color: AppColors.primary),
            title: const Text('Edit Pendidikan'),
            onTap: () {
              Navigator.pop(context);
              _editEducation();
            },
          ),
          ListTile(
            leading: const Icon(Icons.work, color: AppColors.primary),
            title: const Text('Edit Pengalaman Kerja'),
            onTap: () {
              Navigator.pop(context);
              _editWorkExperience();
            },
          ),
        ],
      ),
    );
  }

  void _showStatusChangeDialog() {
    final currentStatusColor = StatusHelper.getStatusColor(_applicant.status);
    final currentStatusIcon = StatusHelper.getStatusIcon(_applicant.status);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ApplicantStatus.values.map((status) {
            final color = StatusHelper.getStatusColor(status);
            final icon = StatusHelper.getStatusIcon(status);
            
            return ListTile(
              title: Text(status.label),
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color),
              ),
              selected: _applicant.status == status,
              onTap: () async {
                await _databaseService.updateApplicantStatus(_applicant.id, status);
                setState(() {
                  _applicant = _applicant.copyWith(status: status);
                });
                if (mounted) Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Aplikasi'),
        content: const Text('Anda yakin ingin menghapus aplikasi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await _databaseService.deleteApplicant(_applicant.id);
              if (mounted) {
                Navigator.pop(context); // Tutup dialog
                Navigator.pop(context); // Kembali ke list
              }
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _editPersonalInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalInfoScreen(applicant: _applicant),
      ),
    ).then(_refreshData);
  }

  void _editEducation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EducationScreen(
          applicant: _applicant,
          isEditMode: true,
        ),
      ),
    ).then(_refreshData);
  }

  void _editWorkExperience() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkExperienceScreen(
          applicant: _applicant,
          isEditMode: true,
        ),
      ),
    ).then(_refreshData);
  }

  void _refreshData(_) async {
    final updatedApplicant = _databaseService.getApplicantById(_applicant.id);
    if (updatedApplicant != null) {
      setState(() {
        _applicant = updatedApplicant;
      });
    }
  }
}