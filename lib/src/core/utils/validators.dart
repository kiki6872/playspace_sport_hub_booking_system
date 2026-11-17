class Validators {
  // Required Field
  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "This field is required";
    }
    return null;
  }

  // Email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your email";
    }

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');

    if (!emailRegex.hasMatch(value)) {
      return "Invalid email address";
    }

    return null;
  }

  // Password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your password";
    }

    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }

    return null;
  }

  // Phone Number
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter phone number";
    }

    if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value)) {
      return "Invalid phone number";
    }

    return null;
  }

  // Price
  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter a price";
    }

    if (double.tryParse(value) == null) {
      return "Invalid price";
    }

    return null;
  }
}
