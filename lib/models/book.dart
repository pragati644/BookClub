class Book {
  final String id;
  final String userId;
  final String title;
  final String author;
  final String? coverUrl;
  final int totalPages;
  final int currentPage;
  final BookStatus status;
  final DateTime? startedDate;
  final DateTime? completedDate;
  final int? rating;
  final String? notes;
  final DateTime createdAt;

  Book({
    required this.id,
    required this.userId,
    required this.title,
    required this.author,
    this.coverUrl,
    required this.totalPages,
    this.currentPage = 0,
    this.status = BookStatus.wantToRead,
    this.startedDate,
    this.completedDate,
    this.rating,
    this.notes,
    required this.createdAt,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      coverUrl: json['cover_url'] as String?,
      totalPages: json['total_pages'] as int,
      currentPage: json['current_page'] as int? ?? 0,
      status: BookStatus.fromString(json['status'] as String? ?? 'want_to_read'),
      startedDate: json['started_date'] != null 
          ? DateTime.parse(json['started_date'] as String) 
          : null,
      completedDate: json['completed_date'] != null
          ? DateTime.parse(json['completed_date'] as String)
          : null,
      rating: json['rating'] as int?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'author': author,
      'cover_url': coverUrl,
      'total_pages': totalPages,
      'current_page': currentPage,
      'status': status.value,
      'started_date': startedDate?.toIso8601String(),
      'completed_date': completedDate?.toIso8601String(),
      'rating': rating,
      'notes': notes,
    };
  }

  double get progress => totalPages > 0 ? (currentPage / totalPages) * 100 : 0;

  Book copyWith({
    String? title,
    String? author,
    String? coverUrl,
    int? totalPages,
    int? currentPage,
    BookStatus? status,
    DateTime? startedDate,
    DateTime? completedDate,
    int? rating,
    String? notes,
  }) {
    return Book(
      id: id,
      userId: userId,
      title: title ?? this.title,
      author: author ?? this.author,
      coverUrl: coverUrl ?? this.coverUrl,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      status: status ?? this.status,
      startedDate: startedDate ?? this.startedDate,
      completedDate: completedDate ?? this.completedDate,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}

enum BookStatus {
  reading,
  completed,
  wantToRead;

  String get value {
    switch (this) {
      case BookStatus.reading:
        return 'reading';
      case BookStatus.completed:
        return 'completed';
      case BookStatus.wantToRead:
        return 'want_to_read';
    }
  }

  String get displayName {
    switch (this) {
      case BookStatus.reading:
        return 'Reading';
      case BookStatus.completed:
        return 'Completed';
      case BookStatus.wantToRead:
        return 'Want to Read';
    }
  }

  static BookStatus fromString(String status) {
    switch (status) {
      case 'reading':
        return BookStatus.reading;
      case 'completed':
        return BookStatus.completed;
      case 'want_to_read':
        return BookStatus.wantToRead;
      default:
        return BookStatus.wantToRead;
    }
  }
}