class Helper {
  static String getRoleName(String role) {
    switch (role) {
      case "admin":
        return "Admin";
      case "vendor":
        return "Vendor";
      case "booker":
        return "Booker";
      default:
        return "User";
    }
  }

  static String getRoleDescription(String role) {
    switch (role) {
      case "admin":
        return "Administrator";
      case "vendor":
        return "Venue Owner";
      case "booker":
        return "Sports Player";
      default:
        return "";
    }
  }
}
