import "package:mysql1/mysql1.dart";
import 'package:flutter_dotenv/flutter_dotenv.dart';




class Connection{
  MySqlConnection? conn;

   Future<void> connect() async{
    try{
    await dotenv.load(fileName: '.env');

    final config = await ConnectionSettings(
      host: dotenv.env['HOST']!,
      port: int.parse(dotenv.env['PORT']!),
      user: dotenv.env['USER'],
      password: dotenv.env['PASSWORD']
    );

    conn = await MySqlConnection.connect(config);
    print("conexao bem sucedida");
  }
  catch(e){
    print("erro ao conectar");
    print(e);
  }finally{
    if (conn != null){
      await conn!.close();
    }
  }
  }
}




