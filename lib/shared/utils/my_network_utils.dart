String parseIntegerToCommaSeparatedString(int number) {
  final String numStr = number.toString();
  final StringBuffer result = StringBuffer();

  // Calculate where commas should be placed
  final int length = numStr.length;
  for (int i = 0; i < length; i++) {
    // Add comma every 3 digits from the right
    if (i > 0 && (length - i) % 3 == 0) {
      result.write(',');
    }
    result.write(numStr[i]);
  }

  return result.toString();
}

/// Calculates the difference in days between the given date string and today.
/// The date string should be in the format "YYYY-MM-DDTHH:MM:SS.ssss".
///
/// Returns a positive integer if the date is in the future,
/// a negative integer if the date is in the past,
/// or 0 if the date is today.
///
/// Then formats a day difference integer into a human-readable string.
///
/// Examples:
/// - 0 returns "Today"
/// - -1 returns "Yesterday"
/// - -2 returns "2 days ago"
/// - -7 returns "1 week ago"
/// - -30 returns "1 month ago"
/// - -365 returns "1 year ago"
String getDaysDifference(String dateString) {
  // Parse the input date string
  DateTime date;
  try {
    date = DateTime.parse(dateString);
  } catch (e) {
    throw FormatException('Invalid date format: $dateString');
  }

  // Get today's date (without time)
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Calculate the input date without time for comparison
  final inputDate = DateTime(date.year, date.month, date.day);

  // Calculate difference in days
  final difference = inputDate.difference(today).inDays;

  // Handle current day
  if (difference == 0) {
    return "today";
  }

  final absValue = difference.abs();

  // Days
  if (absValue == 1) {
    return "yesterday";
  }
  if (absValue < 7) {
    return "$absValue days ago";
  }

  // Weeks
  if (absValue < 30) {
    final weeks = (absValue / 7).floor();
    return weeks == 1 ? "1 week ago" : "$weeks weeks ago";
  }

  // Months
  if (absValue < 365) {
    final months = (absValue / 30).floor();
    return months == 1 ? "1 month ago" : "$months months ago";
  }

  // Years
  final years = (absValue / 365).floor();
  return years == 1 ? "1 year ago" : "$years years ago";
}
