import 'dart:convert';

class ErrorHandler {
  static String getErrorMessage(String responseBody) {
    try {
      var decoded = json.decode(responseBody);
      if (decoded.containsKey('message')) return decoded['message'];

      // Laravel Validation Errors
      if (decoded.containsKey('errors')) {
        Map errors = decoded['errors'];
        return errors.values.first[0]; // Return the first error message
      }

      return 'An unexpected error occurred';
    } catch (e) {
      return 'Server error. Please try again.';
    }
  }
}
