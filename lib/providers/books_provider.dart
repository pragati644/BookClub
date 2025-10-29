import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_club_app/models/book.dart';
import 'package:book_club_app/services/book_service.dart';
import 'package:book_club_app/providers/auth_provider.dart';

final bookServiceProvider = Provider((ref) => BookService());

final userBooksProvider = FutureProvider<List<Book>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  
  return await ref.watch(bookServiceProvider).getUserBooks(user.id);
});

final readingBooksProvider = FutureProvider<List<Book>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  
  return await ref.watch(bookServiceProvider).getBooksByStatus(user.id, BookStatus.reading);
});

final completedBooksProvider = FutureProvider<List<Book>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  
  return await ref.watch(bookServiceProvider).getBooksByStatus(user.id, BookStatus.completed);
});

final readingStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};
  
  return await ref.watch(bookServiceProvider).getReadingStats(user.id);
});

class BooksNotifier extends StateNotifier<AsyncValue<List<Book>>> {
  final BookService _bookService;
  final String userId;

  BooksNotifier(this._bookService, this.userId) : super(const AsyncValue.loading()) {
    loadBooks();
  }

  Future<void> loadBooks() async {
    try {
      state = const AsyncValue.loading();
      final books = await _bookService.getUserBooks(userId);
      state = AsyncValue.data(books);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addBook(Book book) async {
    try {
      await _bookService.addBook(book);
      await loadBooks();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBook(Book book) async {
    try {
      await _bookService.updateBook(book);
      await loadBooks();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteBook(String bookId) async {
    try {
      await _bookService.deleteBook(bookId);
      await loadBooks();
    } catch (e) {
      rethrow;
    }
  }
}

final booksNotifierProvider = StateNotifierProvider.family<BooksNotifier, AsyncValue<List<Book>>, String>((ref, userId) {
  return BooksNotifier(ref.watch(bookServiceProvider), userId);
});