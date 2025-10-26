import "package:mysql_client/mysql_client.dart";
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Connection {

  Future<MySQLConnection> connect() async {
    
    await dotenv.load(fileName: '.env');

    MySQLConnection? conn;
    try {
      
      conn = await MySQLConnection.createConnection(
        host: dotenv.env['HOST']!,
        port: int.parse(dotenv.env['PORT']!),
        userName: dotenv.env['USER']!, 
        password: dotenv.env['PASSWORD']!,
      );

      await conn.connect();
      print("conectado");

      } catch (e) {
      print("erro ao conectar");
      print(e);
      rethrow; 
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
    return conn;
  }
}