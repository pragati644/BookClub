import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_club_app/models/club_post.dart';
import 'package:book_club_app/models/comment.dart';
import 'package:book_club_app/services/club_service.dart';
import 'package:book_club_app/providers/auth_provider.dart';
final clubServiceProvider = Provider((ref) => ClubService());

final allPostsProvider = FutureProvider<List<ClubPost>>((ref) async {
  final user = ref.watch(currentUserProvider);
  return await ref.watch(clubServiceProvider).getAllPosts(currentUserId: user?.id);
});

final postCommentsProvider = FutureProvider.family<List<Comment>, String>((ref, postId) async {
  return await ref.watch(clubServiceProvider).getPostComments(postId);
});

class PostsNotifier extends StateNotifier<AsyncValue<List<ClubPost>>> {
  final ClubService _clubService;
  final String? currentUserId;

  PostsNotifier(this._clubService, this.currentUserId) : super(const AsyncValue.loading()) {
    loadPosts();
  }

  Future<void> loadPosts() async {
    try {
      state = const AsyncValue.loading();
      final posts = await _clubService.getAllPosts(currentUserId: currentUserId);
      state = AsyncValue.data(posts);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createPost({
    required String userId,
    required String content,
    String? bookId,
  }) async {
    try {
      await _clubService.createPost(
        userId: userId,
        content: content,
        bookId: bookId,
      );
      await loadPosts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _clubService.deletePost(postId);
      await loadPosts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleLike(String postId, String userId, bool isLiked) async {
    try {
      if (isLiked) {
        await _clubService.unlikePost(postId, userId);
      } else {
        await _clubService.likePost(postId, userId);
      }
      await loadPosts();
    } catch (e) {
      rethrow;
    }
  }
}

final postsNotifierProvider = StateNotifierProvider<PostsNotifier, AsyncValue<List<ClubPost>>>((ref) {
  final user = ref.watch(currentUserProvider);
  return PostsNotifier(ref.watch(clubServiceProvider), user?.id);
});