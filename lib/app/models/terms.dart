import 'package:cloud_firestore/cloud_firestore.dart';

class Terms {
  final String id;
  final String title;
  final String content;
  final String version; // e.g. 1.0.0
  final Timestamp? updatedAt;

  Terms({
    required this.id,
    required this.title,
    required this.content,
    required this.version,
    required this.updatedAt,
  });

  factory Terms.fromMap(String id, Map<String, dynamic> data) {
    return Terms(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      version: data['version'] ?? '1.0.0',
      updatedAt: data['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'version': version,
      'updatedAt': updatedAt,
    };
  }
}
