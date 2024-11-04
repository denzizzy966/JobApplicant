// lib/screens/applicant_list_screen.dart
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/applicant.dart';
import '../models/applicant_status.dart';
import '../services/database_service.dart';
import '../widgets/custom_button.dart';
import 'add_applicant/personal_info_screen.dart';
import 'applicant_detail_screen.dart';

class ApplicantListScreen extends StatefulWidget {
  const ApplicantListScreen({Key? key}) : super(key: key);

  @override
  State<ApplicantListScreen> createState() => _ApplicantListScreenState();
}

class _ApplicantListScreenState extends State<ApplicantListScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final _searchController = TextEditingController();
  List<Applicant> _filteredApplicants = [];
  String _searchQuery = '';
  bool _showHidden = false;
  String? _selectedPosition;
  ApplicantStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _updateFilteredList();
  }

  void _updateFilteredList() {
    var applicants = _databaseService.getAllApplicants(includeHidden: _showHidden);

    // Filter berdasarkan pencarian
    if (_searchQuery.isNotEmpty) {
      applicants = applicants.where((applicant) {
        final fullName = '${applicant.firstName} ${applicant.lastName}'.toLowerCase();
        final position = applicant.position.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return fullName.contains(query) || position.contains(query);
      }).toList();
    }

    // Filter berdasarkan posisi
    if (_selectedPosition != null) {
      applicants = applicants.where((applicant) => 
        applicant.position == _selectedPosition
      ).toList();
    }

    // Filter berdasarkan status
    if (_selectedStatus != null) {
      applicants = applicants.where((applicant) => 
        applicant.status == _selectedStatus
      ).toList();
    }

    setState(() {
      _filteredApplicants = applicants;
    });
  }

  List<String> _getUniquePositions() {
    final positions = _databaseService
        .getAllApplicants()
        .map((a) => a.position)
        .toSet()
        .toList();
    positions.sort();
    return positions;
  }

  @override
  Widget build(BuildContext context) {
    final positions = _getUniquePositions();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pelamar'),
        backgroundColor: AppColors.primary,
        actions: [
          // Toggle hidden applicants
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showHidden = !_showHidden;
                _updateFilteredList();
              });
            },
            icon: Icon(
              _showHidden ? Icons.visibility : Icons.visibility_off,
              color: Colors.white,
            ),
            label: Text(
              _showHidden ? 'Sembunyikan Hidden' : 'Tampilkan Hidden',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari pelamar...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _updateFilteredList();
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Filter Row
                Row(
                  children: [
                    // Position Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedPosition,
                        decoration: InputDecoration(
                          hintText: 'Filter Posisi',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Semua Posisi'),
                          ),
                          ...positions.map((position) => DropdownMenuItem(
                            value: position,
                            child: Text(position),
                          )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedPosition = value;
                            _updateFilteredList();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Status Filter
                    Expanded(
                      child: DropdownButtonFormField<ApplicantStatus>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          hintText: 'Filter Status',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Semua Status'),
                          ),
                          ...ApplicantStatus.values.map((status) => DropdownMenuItem(
                            value: status,
                            child: Row(
                              children: [
                                Icon(
                                  StatusHelper.getStatusIcon(status),
                                  size: 16,
                                  color: StatusHelper.getStatusColor(status),
                                ),
                                const SizedBox(width: 8),
                                Text(status.label),
                              ],
                            ),
                          )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                            _updateFilteredList();
                          });
                        },
                      ),
                    ),
                  ],
                ),

                // Results count
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Menampilkan ${_filteredApplicants.length} pelamar',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    if (_selectedPosition != null || _selectedStatus != null)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedPosition = null;
                            _selectedStatus = null;
                            _updateFilteredList();
                          });
                        },
                        child: const Text('Reset Filter'),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Applicant List
          Expanded(
            child: _filteredApplicants.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredApplicants.length,
                    itemBuilder: (context, index) =>
                        _buildApplicantCard(_filteredApplicants[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PersonalInfoScreen(),
            ),
          ).then((_) => _updateFilteredList());
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isEmpty && _selectedPosition == null && _selectedStatus == null
                ? Icons.people_outline
                : Icons.filter_list,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty && _selectedPosition == null && _selectedStatus == null
                ? 'Belum ada pelamar'
                : 'Tidak ada pelamar yang sesuai filter',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantCard(Applicant applicant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: applicant.isHidden ? Colors.grey : AppColors.primary,
          child: Text(
            applicant.firstName[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                '${applicant.firstName} ${applicant.lastName}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: applicant.isHidden ? Colors.grey : Colors.black,
                ),
              ),
            ),
            if (applicant.isHidden)
              const Icon(Icons.visibility_off, size: 16, color: Colors.grey),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(applicant.position),
            const SizedBox(height: 4),
            _buildStatusBadge(applicant.status),
          ],
        ),
        onTap: () => _showApplicantDetail(applicant),
        trailing: PopupMenuButton<String>(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Text('Lihat Detail'),
            ),
            PopupMenuItem(
              value: 'status',
              child: Row(
                children: [
                  const Icon(Icons.sync, size: 20),
                  const SizedBox(width: 8),
                  const Text('Ubah Status'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'visibility',
              child: Row(
                children: [
                  Icon(
                    applicant.isHidden ? Icons.visibility : Icons.visibility_off,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(applicant.isHidden ? 'Tampilkan' : 'Sembunyikan'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Hapus', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleMenuAction(value, applicant),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ApplicantStatus status) {
    final color = StatusHelper.getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            StatusHelper.getStatusIcon(status),
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showApplicantDetail(Applicant applicant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApplicantDetailScreen(applicant: applicant),
      ),
    ).then((_) => _updateFilteredList());
  }

  void _handleMenuAction(String action, Applicant applicant) async {
    switch (action) {
      case 'view':
        _showApplicantDetail(applicant);
        break;
      case 'status':
        _showStatusChangeDialog(applicant);
        break;
      case 'visibility':
        await _databaseService.toggleHideApplicant(applicant.id);
        _updateFilteredList();
        break;
      case 'delete':
        _showDeleteConfirmation(applicant);
        break;
    }
  }

  void _showStatusChangeDialog(Applicant applicant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ApplicantStatus.values.map((status) {
            final color = StatusHelper.getStatusColor(status);
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: Icon(
                  StatusHelper.getStatusIcon(status),
                  color: color,
                  size: 20,
                ),
              ),
              title: Text(status.label),
              subtitle: Text(status.description),
              selected: applicant.status == status,
              onTap: () async {
                await _databaseService.updateApplicantStatus(
                  applicant.id,
                  status,
                );
                _updateFilteredList();
                if (mounted) Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Applicant applicant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pelamar'),
        content: Text(
          'Anda yakin ingin menghapus data ${applicant.firstName} ${applicant.lastName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await _databaseService.deleteApplicant(applicant.id);
              _updateFilteredList();
              if (mounted) Navigator.pop(context);
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
}