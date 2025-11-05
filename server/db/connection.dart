import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:mysql_client/mysql_client.dart';

class Connection {

  static MySQLConnection? conn;  

  static Future<MySQLConnection> getConnection() async {

    if(conn != null && conn!.connected){
      return conn!;
    }
    
    final dotEnv = dotenv.DotEnv(includePlatformEnvironment: true)..load(['.env']);


    try {
      conn = await MySQLConnection.createConnection(
        host: dotEnv['HOST']!,
        port: int.parse(dotEnv['PORT']!),
        userName: dotEnv['USER']!, 
        password: dotEnv['PASSWORD']!,
        databaseName: dotEnv['DATABASE']!
      );

      await conn!.connect();
      print("conectado");

      } catch (e) {
      print("erro ao conectar");
      print(e);
      rethrow; 
    } 
    return conn!;
  }
}