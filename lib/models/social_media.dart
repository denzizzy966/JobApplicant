// lib/models/social_media.dart

enum SocialMediaType {
  facebook('Facebook', 'https://facebook.com/'),
  instagram('Instagram', 'https://instagram.com/'),
  twitter('Twitter', 'https://twitter.com/'),
  github('GitHub', 'https://github.com/'),
  linkedin('LinkedIn', 'https://linkedin.com/in/'),
  website('Personal Website', '');

  final String label;
  final String baseUrl;
  const SocialMediaType(this.label, this.baseUrl);
}

class SocialMedia {
  final String id;
  final SocialMediaType type;
  final String username;
  final String? url;

  SocialMedia({
    required this.id,
    required this.type,
    required this.username,
    this.url,
  });

  String get fullUrl {
    if (type == SocialMediaType.website) {
      return url ?? username;
    }
    return '${type.baseUrl}$username';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'username': username,
      'url': url,
    };
  }

  factory SocialMedia.fromMap(Map<String, dynamic> map) {
    return SocialMedia(
      id: map['id'],
      type: SocialMediaType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => SocialMediaType.website,
      ),
      username: map['username'],
      url: map['url'],
    );
  }
}