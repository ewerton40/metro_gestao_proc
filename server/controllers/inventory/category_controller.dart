import 'package:dart_frog/dart_frog.dart';
import '../../db/connection.dart';
import '../../db/category.dart';


Future<Response> categoryHandler(RequestContext context) async{
    if(context.request.method == HttpMethod.get){
    try{
      final conexao = Connection.getConnection();
      final categorias = await CategoryDAO(await conexao).getAllCategories();
      final data = categorias.map((categoria) => {
        'id': categoria.id_categoria,
        'nome': categoria.nome_categoria
      }).toList();


      return Response.json(body: {
        'success': true,
        'data': data
      });
      
    }catch(e){
      print("Erro na na busca de todas as categorias do banco de dados: $e");
      return Response.json(
        statusCode: 500,
        body: {
          'success': false,
          'message': 'Erro interno ao buscar categorias.',
        },
      );
    }
}
    return Response.json(
    statusCode: 405,
    body: {'message': 'Método não permitido'},
  );
}