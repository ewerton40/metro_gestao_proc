import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:mysql_client/mysql_client.dart';

class Connection {

  Future<MySQLConnection> connect() async {
    
    final dotEnv = dotenv.DotEnv(includePlatformEnvironment: true)..load(['.env']);


    MySQLConnection? conn;  
    try {
      
      conn = await MySQLConnection.createConnection(
        host: dotEnv['HOST']!,
        port: int.parse(dotEnv['PORT']!),
        userName: dotEnv['USER']!, 
        password: dotEnv['PASSWORD']!,
        databaseName: dotEnv['DATABASE']
      );

      await conn.connect();
      print("conectado");

      } catch (e) {
      print("erro ao conectar");
      print(e);
      rethrow; 
    } 
    return conn;
  }
}