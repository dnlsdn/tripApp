import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationMethods {
  final String serverKey =
      "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDqklQBX5VZcPim\n/SSnyQR63w9WSWv1nLc3K6TSslwZGfqR743dweAMe9rQrT7NL/Z+1ZHvqnY8FKhE\nuxBXGXfIXVHG4QFyvF/EpStFY8O1gOLN7kDqHPJkEEHn2rSy0M1lPEgAzHWP2nTp\n9t9el8t9tK0UNP+p8WxwW7JrY/VLZjvc98TZ8uQrn+FRHecYdv2tZ7Juli3m+aK7\npognWFfYKIZJ7VeEbsTZ7x4rF9XKiPkvhORGXAi6i7i+D/rl+srnBqBmK8kRCvA/\nQYm9XDzyfjgN4xZVcD1+uPsrvMinEdeeOvZoDmF6ZzzWcLvunnRLVUGh7J+AE31h\nhE0imkL3AgMBAAECggEAIL8OxSZP1i2kOMOsI1Q3sOOE45naXW5kUWphVxyZKNPs\nnATiPCv9mCCOOoWE9+YTNj+gYOHeIaMMnpOyw0YF583HRclRh2/uuqgIM2arAqKc\nhv0UyNoDqJ5wZOquQSxPECvrLVldrBhmK+dP5YexW7omU2TWsCXI6qKSdNV+f+jg\nRcIi3ZZCs+OntTf2IFVkFxrpcvdwkkg5MDDCnsESNNUSAw1nSe2q/FwpBSUdN3mn\ntFqtiLnAjjSAiDyYXhHADDV+YajEwPzfcrqiOTNYLriAPsfUociXtDHzwHUC38wG\nTtEpWMySYxAM/pDNevHaHpqm9Kj/8wv2f6s4MQIScQKBgQD/hHa28iOZh+g0SHxP\nLXcm+4zRjEJSmdkfVoNIk+KAyYtD5I/f2V29dZR34fl26UkUrlqXtc4xcgTxR223\nmc1mXEBojdzbrRnJY1qtVC/sDtPiIedEHSCZJ+cqzqOoGLJzYvOz4emua6HUAVdF\nFYwh8G13ZxHp3ffhDjLhnK/r3wKBgQDrA7zVKtliea4BdN8rn1oJxkf9WCjVoP4O\nJGsqUuqUKCAak0VIOxZDhdfwULnLy1DfRZUiaedty53mI1u0kymOWN5gm/oFUjZd\ndiHDQqezzRC/bliROv2zCQN0PPRSl4Z6c/utlMeg9s6V8ue2X1Dp8clUrBFIpSkG\nv46lk+YL6QKBgQDyYt0etNoydWs/1ZceoPmL4Ep4Kb5sjwcZpD7LpYXTN91FXVdi\nONektxpNEu9L7wbleHP1wIBGBWxM2b5p0Zu4Q0DSLejZ9v4kPXyyOc9v9aznsdOp\nmJvozaKLyBQVjMATl0WpWWAMlougClmX7lXNiD6/auXiXS8crhR0UufLLwKBgCqk\n/vrfT5ri4YQ6JNTRkZD8fcum16IMGI2QZjHD4fUIYurvlj7JGf0eqFRfEZe9SOt6\nwNkBxpDRxdEg0V8u5PeDgLafFvsoM905tl6sFao2p7dU2pVf0vFNzWamON9Tx38o\n1J5mxOKcZlgnP4yENzZ8PUA0CN7ZuVwUHlpFQBUhAoGBAOQId4WxNkvgHYn6oesF\neXp4ojaCHucS6+pRoS8tzNyFfq4EwePlkifPZvMi6GLAYbI9mTyhXNCCmtrGjZnu\nsc5c0mqYt+fjHfIfHZjqrWW3dS1aHS9sV49WCIXe0HE3I9HiwHyz7+fII11RNCUG\neycS8p3/cbcCkfAfOF5AastJ\n-----END PRIVATE KEY-----\n";
  final String projectId = "travel-app-c02d6";

  Future<void> sendNotification({
    required String token,
    required String title,
    required String body,
  }) async {
    final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send');
    final payload = {
      "message": {
        "token": token,
        "notification": {
          "title": title,
          "body": body,
        },
      },
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      print('Notifica inviata con successo.');
    } else {
      print('Errore durante l\'invio della notifica: ${response.body}');
    }
  }
}
