import 'dart:convert';
import 'dart:html' as html;

abstract class LuaBridge {
  static Future<void> post(
      String callback, Map<String, dynamic> message) async {
        
    print("====== Sent to LUA ========");
    print(message);
    print("===========================");

    final url = "https://qs-adminmenu/$callback";

    await html.window.fetch(url, {
      "method": "POST",
      "headers": {"Content-Type": "application/json"},
      "body": jsonEncode(message)
    });
  }
}
