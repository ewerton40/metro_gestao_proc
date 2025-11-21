import 'package:dart_frog/dart_frog.dart';
import '../../db/base_filter.dart';
import '../../db/connection.dart';


Future<Response> countCalibrationBaseHandler(RequestContext context, String base) async {
  if (context.request.method != HttpMethod.get) {
    return Response.json(statusCode: 405, body: {'error': 'Método não permitido'});
  }

  final baseId = int.tryParse(base);
  if (baseId == null) return Response.json(statusCode: 400, body: {'error': 'Base inválida'});

  try {
    final conn = await Connection.getConnection();
    final dao = BaseFilterDAO(conn);

    final result = await dao.getBaseMonthCalibration(baseId);

    return Response.json(body: {'success': true, 'data': result});
  } catch (e) {
    print("Erro no controller countCalibrationBaseHandler: $e");
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  }
}
