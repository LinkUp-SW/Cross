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
