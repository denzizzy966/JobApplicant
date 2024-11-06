// lib/widgets/social_media_editor.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/social_media.dart';
import '../constants/colors.dart';

class SocialMediaEditor extends StatefulWidget {
  final List<SocialMedia> socialMedia;
  final Function(List<SocialMedia>) onChanged;

  const SocialMediaEditor({
    Key? key,
    required this.socialMedia,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<SocialMediaEditor> createState() => _SocialMediaEditorState();
}

class _SocialMediaEditorState extends State<SocialMediaEditor> {
  late List<SocialMedia> _socialMedia;
  final _usernameController = TextEditingController();
  final _urlController = TextEditingController();
  SocialMediaType _selectedType = SocialMediaType.facebook;

  @override
  void initState() {
    super.initState();
    _socialMedia = List.from(widget.socialMedia);
  }

  void _addSocialMedia() {
    if (_usernameController.text.isEmpty) return;

    final newSocialMedia = SocialMedia(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedType,
      username: _usernameController.text,
      url: _selectedType == SocialMediaType.website ? _urlController.text : null,
    );

    setState(() {
      _socialMedia.add(newSocialMedia);
      widget.onChanged(_socialMedia);
      _usernameController.clear();
      _urlController.clear();
    });
  }

  void _removeSocialMedia(String id) {
    setState(() {
      _socialMedia.removeWhere((sm) => sm.id == id);
      widget.onChanged(_socialMedia);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Social Media',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Add new social media
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<SocialMediaType>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Platform',
                    border: OutlineInputBorder(),
                  ),
                  items: SocialMediaType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: _selectedType == SocialMediaType.website
                        ? 'Title'
                        : 'Username',
                    border: const OutlineInputBorder(),
                    prefixText: _selectedType == SocialMediaType.website
                        ? null
                        : _selectedType.baseUrl,
                  ),
                ),
                if (_selectedType == SocialMediaType.website) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _addSocialMedia,
                  icon: const Icon(Icons.add,color: Colors.white,),
                  label: const Text(
                    'Add Social Media',
                    style:TextStyle(color:Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // List of added social media
        if (_socialMedia.isNotEmpty) ...[
          const Text(
            'Added Social Media',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _socialMedia.length,
            itemBuilder: (context, index) {
              final sm = _socialMedia[index];
              return Card(
                child: ListTile(
                  leading: Icon(
                    _getIconForType(sm.type),
                    color: AppColors.primary,
                  ),
                  title: Text(sm.type.label),
                  subtitle: Text(
                    sm.type == SocialMediaType.website
                        ? sm.fullUrl
                        : '@${sm.username}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeSocialMedia(sm.id),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  IconData _getIconForType(SocialMediaType type) {
    switch (type) {
      case SocialMediaType.facebook:
        return FontAwesomeIcons.facebook;
      case SocialMediaType.instagram:
        return FontAwesomeIcons.instagram;
      case SocialMediaType.twitter:
        return FontAwesomeIcons.twitter;
      case SocialMediaType.github:
        return FontAwesomeIcons.github;
      case SocialMediaType.linkedin:
        return FontAwesomeIcons.linkedin;
      case SocialMediaType.website:
        return Icons.language;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _urlController.dispose();
    super.dispose();
  }
}