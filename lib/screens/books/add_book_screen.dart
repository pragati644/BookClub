import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_club_app/models/book.dart';
import 'package:book_club_app/providers/auth_provider.dart';
import 'package:book_club_app/providers/books_provider.dart';
import 'package:book_club_app/utils/constants.dart';
import 'package:book_club_app/widgets/custom_button.dart';

class AddBookScreen extends ConsumerStatefulWidget {
  final Book? bookToEdit;

  const AddBookScreen({super.key, this.bookToEdit});

  @override
  ConsumerState<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends ConsumerState<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _totalPagesController = TextEditingController();
  final _currentPageController = TextEditingController();
  final _coverUrlController = TextEditingController();
  final _notesController = TextEditingController();
  
  BookStatus _selectedStatus = BookStatus.wantToRead;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.bookToEdit != null) {
      _titleController.text = widget.bookToEdit!.title;
      _authorController.text = widget.bookToEdit!.author;
      _totalPagesController.text = widget.bookToEdit!.totalPages.toString();
      _currentPageController.text = widget.bookToEdit!.currentPage.toString();
      _coverUrlController.text = widget.bookToEdit!.coverUrl ?? '';
      _notesController.text = widget.bookToEdit!.notes ?? '';
      _selectedStatus = widget.bookToEdit!.status;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _totalPagesController.dispose();
    _currentPageController.dispose();
    _coverUrlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final book = Book(
        id: widget.bookToEdit?.id ?? '',
        userId: user.id,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        totalPages: int.parse(_totalPagesController.text),
        currentPage: int.parse(_currentPageController.text),
        coverUrl: _coverUrlController.text.trim().isEmpty 
            ? null 
            : _coverUrlController.text.trim(),
        status: _selectedStatus,
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
        startedDate: _selectedStatus == BookStatus.reading ? DateTime.now() : null,
        completedDate: _selectedStatus == BookStatus.completed ? DateTime.now() : null,
        createdAt: widget.bookToEdit?.createdAt ?? DateTime.now(),
      );

      if (widget.bookToEdit != null) {
        await ref.read(booksNotifierProvider(user.id).notifier).updateBook(book);
      } else {
        await ref.read(booksNotifierProvider(user.id).notifier).addBook(book);
      }

      ref.invalidate(userBooksProvider);
      ref.invalidate(readingBooksProvider);
      ref.invalidate(readingStatsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.bookToEdit != null 
                ? 'Book updated successfully' 
                : 'Book added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
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
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.bookToEdit != null ? 'Edit Book' : 'Add New Book'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Book Title *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter book title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              // Author
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: 'Author *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter author name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              // Total Pages
              TextFormField(
                controller: _totalPagesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Total Pages *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter total pages';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              // Current Page
              TextFormField(
                controller: _currentPageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Current Page',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final currentPage = int.tryParse(value);
                    final totalPages = int.tryParse(_totalPagesController.text);
                    if (currentPage == null) {
                      return 'Please enter a valid number';
                    }
                    if (totalPages != null && currentPage > totalPages) {
                      return 'Current page cannot exceed total pages';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              // Status
              const Text(
                'Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              Wrap(
                spacing: 8,
                children: BookStatus.values.map((status) {
                  return ChoiceChip(
                    label: Text(status.displayName),
                    selected: _selectedStatus == status,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedStatus = status);
                      }
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.1),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: _selectedStatus == status 
                          ? AppColors.primary 
                          : AppColors.textSecondary,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              // Cover URL
              TextFormField(
                controller: _coverUrlController,
                decoration: InputDecoration(
                  labelText: 'Cover Image URL (Optional)',
                  hintText: 'https://example.com/cover.jpg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Add your thoughts about this book...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              // Save Button
              CustomButton(
                text: widget.bookToEdit != null ? 'Update Book' : 'Add Book',
                onPressed: _handleSave,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}