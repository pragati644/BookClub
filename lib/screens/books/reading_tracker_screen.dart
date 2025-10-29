import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_club_app/models/book.dart';
import 'package:book_club_app/providers/auth_provider.dart';
import 'package:book_club_app/providers/books_provider.dart';
import 'package:book_club_app/utils/constants.dart';
import 'package:book_club_app/screens/books/add_book_screen.dart';
class ReadingTrackerScreen extends ConsumerStatefulWidget {
  const ReadingTrackerScreen({super.key});

  @override
  ConsumerState<ReadingTrackerScreen> createState() => _ReadingTrackerScreenState();
}

class _ReadingTrackerScreenState extends ConsumerState<ReadingTrackerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final booksAsync = ref.watch(userBooksProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reading Tracker'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Reading'),
            Tab(text: 'Completed'),
            Tab(text: 'Want to Read'),
          ],
        ),
      ),
      body: booksAsync.when(
        data: (books) {
          final readingBooks =
              books.where((b) => b.status == BookStatus.reading).toList();
          final completedBooks =
              books.where((b) => b.status == BookStatus.completed).toList();
          final wantToReadBooks =
              books.where((b) => b.status == BookStatus.wantToRead).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookList(readingBooks, user?.id ?? ''),
              _buildBookList(completedBooks, user?.id ?? ''),
              _buildBookList(wantToReadBooks, user?.id ?? ''),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddBookScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBookList(List<Book> books, String userId) {
    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No books yet',
              style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddBookScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add a Book'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(userBooksProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return _BookListTile(
            book: book,
            userId: userId,
            onTap: () => _showBookDetailsBottomSheet(context, book, userId),
          );
        },
      ),
    );
  }

  void _showBookDetailsBottomSheet(BuildContext context, Book book, String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BookDetailsSheet(book: book, userId: userId),
    );
  }
}

class _BookListTile extends ConsumerWidget {
  final Book book;
  final String userId;
  final VoidCallback onTap;

  const _BookListTile({
    required this.book,
    required this.userId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                book.coverUrl ??
                    'https://via.placeholder.com/100x150/6366F1/FFFFFF?text=${Uri.encodeComponent(book.title)}',
                width: 60,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 90,
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.book),
                  );
                },
              ),
            ),
            const SizedBox(width: AppSizes.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (book.status == BookStatus.reading) ...[
                    LinearProgressIndicator(
                      value: book.progress / 100,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${book.currentPage} / ${book.totalPages} pages (${book.progress.toStringAsFixed(0)}%)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ] else if (book.status == BookStatus.completed) ...[
                    Row(
                      children: [
                        const Icon(Icons.check_circle,
                            size: 16, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text(
                          '${book.totalPages} pages',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      '${book.totalPages} pages',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _BookDetailsSheet extends ConsumerStatefulWidget {
  final Book book;
  final String userId;
  const _BookDetailsSheet({required this.book, required this.userId});

  @override
  ConsumerState<_BookDetailsSheet> createState() => _BookDetailsSheetState();
}

class _BookDetailsSheetState extends ConsumerState<_BookDetailsSheet> {
  late int _currentPage;
  final _pageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentPage = widget.book.currentPage;
    _pageController.text = _currentPage.toString();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _updateProgress() async {
    final newPage = int.tryParse(_pageController.text);
    if (newPage == null || newPage < 0 || newPage > widget.book.totalPages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid page number'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final updatedBook = widget.book.copyWith(
        currentPage: newPage,
        status: newPage >= widget.book.totalPages
            ? BookStatus.completed
            : BookStatus.reading,
        completedDate: newPage >= widget.book.totalPages ? DateTime.now() : null,
      );

      await ref
          .read(booksNotifierProvider(widget.userId).notifier)
          .updateBook(updatedBook);

      ref.invalidate(userBooksProvider);
      ref.invalidate(readingBooksProvider);
      ref.invalidate(readingStatsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Progress updated!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteBook() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: const Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref
            .read(booksNotifierProvider(widget.userId).notifier)
            .deleteBook(widget.book.id);

        ref.invalidate(userBooksProvider);
        ref.invalidate(readingBooksProvider);
        ref.invalidate(readingStatsProvider);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Book deleted'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Book Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      color: AppColors.primary,
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddBookScreen(bookToEdit: widget.book),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: AppColors.error,
                      onPressed: _deleteBook,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.book.title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'by ${widget.book.author}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            if (widget.book.status == BookStatus.reading) ...[
              const Text(
                'Update Progress',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Current Page',
                        suffixText: '/ ${widget.book.totalPages}',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _updateProgress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                    ),
                    child: const Text('Update'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: widget.book.progress / 100,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                color: AppColors.primary,
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.book.progress.toStringAsFixed(0)}% complete',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],

            if (widget.book.notes != null && widget.book.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Notes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                widget.book.notes!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
