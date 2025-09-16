//dev Url
const String finalUrl = "https://monitor.poojaratele.com/api";

class Auth {
  static String? email;
  static String? password;
  static String? accestoken;

  static Map<String, String>? commonHeader = {
    'Authorization': 'Bearer ${Auth.accestoken}',
    'Accept': 'application/json',
    "Content-Type": "application/json",
    "Connection": "application/json",
  };
}
