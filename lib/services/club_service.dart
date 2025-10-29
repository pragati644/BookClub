import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:book_club_app/models/club_post.dart';
import 'package:book_club_app/models/comment.dart';
class ClubService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch all posts
  Future<List<ClubPost>> getAllPosts({String? currentUserId}) async {
    var query = _supabase
        .from('club_posts')
        .select('*, profiles!club_posts_user_id_fkey(*)')
        .order('created_at', ascending: false);

    final response = await query;

    List<ClubPost> posts =
        (response as List).map((json) => ClubPost.fromJson(json)).toList();

    // Check liked posts
    if (currentUserId != null) {
      final likedPosts = await _supabase
          .from('likes')
          .select('post_id')
          .eq('user_id', currentUserId);

      final likedPostIds =
          (likedPosts as List).map((e) => e['post_id'] as String).toSet();

      posts = posts
          .map(
              (post) => post.copyWith(isLiked: likedPostIds.contains(post.id)))
          .toList();
    }

    return posts;
  }

  // Create a post
  Future<ClubPost> createPost({
    required String userId,
    required String content,
    String? bookId,
  }) async {
    final response = await _supabase
        .from('club_posts')
        .insert({
          'user_id': userId,
          'content': content,
          'book_id': bookId,
        })
        .select('*, profiles!club_posts_user_id_fkey(*)')
        .single();

    return ClubPost.fromJson(response);
  }

  // Delete post
  Future<void> deletePost(String postId) async {
    await _supabase.from('club_posts').delete().eq('id', postId);
  }

  // Like post
  Future<void> likePost(String postId, String userId) async {
    await _supabase.from('likes').insert({
      'post_id': postId,
      'user_id': userId,
    });

    await _supabase.rpc('increment_likes', params: {'post_id': postId});
  }

  // Unlike post
  Future<void> unlikePost(String postId, String userId) async {
    await _supabase
        .from('likes')
        .delete()
        .eq('post_id', postId)
        .eq('user_id', userId);

    await _supabase.rpc('decrement_likes', params: {'post_id': postId});
  }

  // Get all comments for a post
  Future<List<Comment>> getPostComments(String postId) async {
    final response = await _supabase
        .from('comments')
        .select('*, profiles!comments_user_id_fkey(*)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    return (response as List).map((json) => Comment.fromJson(json)).toList();
  }

  // ✅ Add comment to a post
  Future<Comment> addComment({
    required String postId,
    required String userId,
    required String content,
  }) async {
    final response = await _supabase
        .from('comments')
        .insert({
          'post_id': postId,
          'user_id': userId,
          'content': content,
        })
        .select('*, profiles!comments_user_id_fkey(*)')
        .single();

    return Comment.fromJson(response);
  }
}
