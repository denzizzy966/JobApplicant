// lib/widgets/search_filter_bar.dart

import 'package:flutter/material.dart';
import '../constants/colors.dart';

class SearchFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String? selectedPosition;
  final String? sortBy;
  final List<String> positions;
  final Function(String) onSearch;
  final Function(String?) onPositionFilter;
  final Function(String?) onSort;

  const SearchFilterBar({
    Key? key,
    required this.searchController,
    this.selectedPosition,
    this.sortBy,
    required this.positions,
    required this.onSearch,
    required this.onPositionFilter,
    required this.onSort,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search applicants...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.primary,
            ),
            onChanged: onSearch,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Position filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedPosition,
                  decoration: InputDecoration(
                    hintText: 'Filter by position',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.primary,
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All positions'),
                    ),
                    ...positions.map((position) => DropdownMenuItem(
                      value: position,
                      child: Text(position),
                    )),
                  ],
                  onChanged: onPositionFilter,
                ),
              ),
              const SizedBox(width: 16),
              // Sort dropdown
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: sortBy,
                  decoration: InputDecoration(
                    hintText: 'Sort by',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.primary,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: null,
                      child: Text('Default'),
                    ),
                    DropdownMenuItem(
                      value: 'name',
                      child: Text('Name'),
                    ),
                    DropdownMenuItem(
                      value: 'position',
                      child: Text('Position'),
                    ),
                    DropdownMenuItem(
                      value: 'date',
                      child: Text('Date'),
                    ),
                  ],
                  onChanged: onSort,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}