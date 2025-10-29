import 'package:intl/intl.dart';

class Helpers {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(date);
  }

  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${difference.inDays / 365 > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${difference.inDays / 30 > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  static int calculateReadingProgress(int currentPage, int totalPages) {
    if (totalPages == 0) return 0;
    return ((currentPage / totalPages) * 100).round();
  }

  static String getBookCoverPlaceholder(String title) {
    // Generate a color based on title
    final colors = [
      'FF6B6B',
      '4ECDC4',
      '45B7D1',
      'FFA07A',
      '98D8C8',
      'F7DC6F',
      'BB8FCE',
      '85C1E2',
    ];
    final index = title.length % colors.length;
    return 'https://via.placeholder.com/400x600/${colors[index]}/FFFFFF?text=${Uri.encodeComponent(title)}';
  }
}