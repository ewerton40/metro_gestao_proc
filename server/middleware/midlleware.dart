import 'package:dart_frog/dart_frog.dart';
import 'dart:async'; 


Handler middleware(Handler handler) {

  return (context) async {
    if (context.request.method == HttpMethod.options) {
      return Response(
        statusCode: 200,
        headers: const {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': '*',
        },
      );
    }
    final response = await handler(context);

    return response.copyWith(
      headers: {
        ...response.headers,
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': '*',
      },
    );
  };
}