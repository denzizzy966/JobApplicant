// lib/widgets/social_media_display.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/social_media.dart';
import '../constants/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialMediaDisplay extends StatelessWidget {
  final List<SocialMedia> socialMedia;
  final bool isCompact;

  const SocialMediaDisplay({
    Key? key,
    required this.socialMedia,
    this.isCompact = false,
  }) : super(key: key);

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

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (socialMedia.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isCompact) ...[
          const Text(
            'Social Media',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
        ],
        isCompact ? _buildCompactView() : _buildDetailedView(),
      ],
    );
  }

  Widget _buildCompactView() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: socialMedia.map((sm) => InkWell(
        onTap: () => _launchUrl(sm.fullUrl),
        child: Icon(
          _getIconForType(sm.type),
          color: AppColors.primary,
          size: 24,
        ),
      )).toList(),
    );
  }

  Widget _buildDetailedView() {
    return Column(
      children: socialMedia.map((sm) => Card(
        margin: const EdgeInsets.only(bottom: 8),
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
            icon: const Icon(Icons.open_in_new),
            onPressed: () => _launchUrl(sm.fullUrl),
          ),
        ),
      )).toList(),
    );
  }
}