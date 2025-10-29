import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:book_club_app/models/comment.dart';// adjust path if your Comment model is elsewhere

class CommentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Comment>> getComments(String postId) async {
    final response = await _supabase
        .from('comments')
        .select(', profiles!comments_user_id_fkey()')
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    return (response as List).map((json) => Comment.fromJson(json)).toList();
  }

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
        .select(', profiles!comments_user_id_fkey()')
        .single();

    // Increment comments count
    await _supabase.rpc('increment_comments', params: {'post_id': postId});

    return Comment.fromJson(response);
  }

  Future<void> deleteComment(String commentId, String postId) async {
    await _supabase.from('comments').delete().eq('id', commentId);

    // Decrement comments count
    await _supabase.rpc('decrement_comments', params: {'post_id': postId});
  }
}
