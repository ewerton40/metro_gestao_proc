import 'package:dart_frog/dart_frog.dart';
import '../../db/connection.dart';
import '../../db/movimentation.dart';


Future<Response> fiveUsedHandler(RequestContext context) async {
  if (context.request.method == HttpMethod.get) {
    try {
      final conexao = await Connection.getConnection();
      final dao = MovimentationDAO(conexao);
      final items = await dao.getTopFiveUsedMaterials();

      final data = items.map((e) => {
        'material': e.nome,
        'total_saidas': e.totalSaidas,
      }).toList();

      return Response.json(body: {
        'success': true,
        'data': data,
      });
      
    } catch (e) {
      print("Erro ao buscar top 5 materiais: $e");
      return Response.json(
        statusCode: 500,
        body: {'success': false, 'message': 'Erro interno no servidor'},
      );
    }
  }

  return Response.json(
    statusCode: 405,
    body: {'message': 'Método não permitido'},
  );
}
