import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:book_club_app/models/book.dart';
class BookService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Book>> getUserBooks(String userId) async {
    final response = await _supabase
        .from('books')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Book.fromJson(json)).toList();
  }

  Future<List<Book>> getBooksByStatus(String userId, BookStatus status) async {
    final response = await _supabase
        .from('books')
        .select()
        .eq('user_id', userId)
        .eq('status', status.value)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Book.fromJson(json)).toList();
  }

  Future<Book> addBook(Book book) async {
    final response = await _supabase
        .from('books')
        .insert(book.toJson())
        .select()
        .single();

    return Book.fromJson(response);
  }

  Future<void> updateBook(Book book) async {
    await _supabase
        .from('books')
        .update(book.toJson())
        .eq('id', book.id);
  }

  Future<void> deleteBook(String bookId) async {
    await _supabase.from('books').delete().eq('id', bookId);
  }

  Future<void> updateReadingProgress({
    required String bookId,
    required String userId,
    required int pagesRead,
  }) async {
    await _supabase.from('reading_progress').insert({
      'book_id': bookId,
      'user_id': userId,
      'pages_read': pagesRead,
      'date': DateTime.now().toIso8601String().split('T')[0],
    });
  }

  Future<Map<String, dynamic>> getReadingStats(String userId) async {
    final books = await getUserBooks(userId);
    
    final totalBooks = books.length;
    final readingBooks = books.where((b) => b.status == BookStatus.reading).length;
    final completedBooks = books.where((b) => b.status == BookStatus.completed).length;
    
    int totalPagesRead = 0;
    for (var book in books) {
      if (book.status == BookStatus.completed) {
        totalPagesRead += book.totalPages;
      } else {
        totalPagesRead += book.currentPage;
      }
    }

    return {
      'total_books': totalBooks,
      'reading': readingBooks,
      'completed': completedBooks,
      'total_pages_read': totalPagesRead,
    };
  }
}