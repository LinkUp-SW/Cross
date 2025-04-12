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