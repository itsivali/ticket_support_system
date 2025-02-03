import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dateFormat = DateFormat('MMM d, y');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('MMM d, y HH:mm');
  
  // Format date only
  static String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return _dateFormat.format(date);
  }

  // Format time only
  static String formatTime(DateTime? time) {
    if (time == null) return 'N/A';
    return _timeFormat.format(time);
  }

  // Format full date and time
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return _dateTimeFormat.format(dateTime);
  }

  // Get relative time (e.g., "2 hours ago")
  static String getRelativeTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  // Format duration (e.g., "2h 30m")
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  // Get remaining time until date
  static String getRemainingTime(DateTime? endDate) {
    if (endDate == null) return 'N/A';
    
    final now = DateTime.now();
    if (endDate.isBefore(now)) return 'Expired';
    
    final difference = endDate.difference(now);
    return formatDuration(difference);
  }

  // Format work hours (e.g., "09:00 - 17:00")
  static String formatWorkHours(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'N/A';
    return '${_timeFormat.format(start)} - ${_timeFormat.format(end)}';
  }

  // Get day name
  static String getDayName(int day) {
    switch (day) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Invalid day';
    }
  }
}