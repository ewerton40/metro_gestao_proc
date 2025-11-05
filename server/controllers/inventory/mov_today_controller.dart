import 'package:dart_frog/dart_frog.dart';
import '../../db/connection.dart';
import '../../db/movimentation.dart';


Future<Response> movTodayHandler(RequestContext context) async{
  if (context.request.method == HttpMethod.get){
    try{
      final conexao = Connection.getConnection();
      final dao = MovimentationDAO(await conexao);
      final items = dao.MovementsToday();

      final data = {
        'data': items
      };

      return Response.json(body: {
        'success': true,
        'data': data
      });
    }catch(e){
      print("Erro em buscar todas as movimentações de hoje: $e");
      throw Exception("Erro em mov_today_controller");
    }
  }
  return Response.json(
    statusCode: 505,
    body: {'message: Método não permitido'}
  );
}