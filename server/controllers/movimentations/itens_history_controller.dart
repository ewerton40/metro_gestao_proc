import 'package:dart_frog/dart_frog.dart';
import '../../db/connection.dart';
import '../../db/movimentation.dart';

Future<Response> itensHistoryHandler(RequestContext context, String id) async {
  if (context.request.method == HttpMethod.get) {
    try {
      final conn = await Connection.getConnection();
      final dao = MovimentationDAO(conn);

      final itemDetail = await dao.getItemHistory(int.parse(id));

      return Response.json(
        body: {
          'success': true,
          'data': itemDetail,
        },
      );
    } catch (e) {
      print('Erro no handler de detalhe: $e');
      return Response.json(
        statusCode: 500,
        body: {'success': false, 'error': e.toString()},
      );
    }
  }

  return Response.json(
    statusCode: 405,
    body: {'success': false, 'error': 'Método não permitido'},
  );
}