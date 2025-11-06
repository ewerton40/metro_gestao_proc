import 'package:dart_frog/dart_frog.dart';
import '../../db/connection.dart';
import '../../db/movimentation.dart';


Future<Response> fiveUsedHandler(RequestContext context) async{
  if (context.request.method == HttpMethod.get){
    try{
      final conexao = Connection.getConnection();
      final dao = MovimentationDAO(await conexao);
      final items = await dao.MovementsToday();

      return Response.json(body: {
        'success': true,
        'data': items
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