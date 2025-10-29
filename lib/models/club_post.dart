import 'package:book_club_app/models/user_profile.dart';

class ClubPost {
  final String id;
  final String userId;
  final String? bookId;
  final String content;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final UserProfile? userProfile;
  final bool? isLiked;

  ClubPost({
    required this.id,
    required this.userId,
    this.bookId,
    required this.content,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    this.userProfile,
    this.isLiked,
  });

  factory ClubPost.fromJson(Map<String, dynamic> json) {
    return ClubPost(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      bookId: json['book_id'] as String?,
      content: json['content'] as String,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      userProfile: json['profiles'] != null 
          ? UserProfile.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
      isLiked: json['is_liked'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'book_id': bookId,
      'content': content,
      'likes_count': likesCount,
      'comments_count': commentsCount,
    };
  }

  ClubPost copyWith({
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
  }) {
    return ClubPost(
      id: id,
      userId: userId,
      bookId: bookId,
      content: content,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt,
      userProfile: userProfile,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}