import 'package:flutter/material.dart';
import 'package:metro_projeto/screens/ItemRegistrationScreen.dart';
import 'package:metro_projeto/screens/CadastroMaterialScreen.dart';
class VerticalMenu extends StatefulWidget{
    const VerticalMenu({super.key});

    @override
    State<VerticalMenu> createState() => _VerticalMenuState();

}


class _VerticalMenuState extends State<VerticalMenu>{

    @override
    Widget build(BuildContext context){
        return Drawer(
         child: ListView(
            padding: EdgeInsets.zero,
            children:  <Widget>[
                SizedBox(
                    height: 130,
                    child: DrawerHeader(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    SizedBox(
                                    width: 50,
                                    height: 50,
                                    child:  Image.asset('assets/images/logo_metro_menu.png')
                                    ),                       
                                ],
                            )        
                ),
                ),
                ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Início'),
                    onTap:() {
                      Navigator.pop(context);
                    },
                ),
                ListTile(
                    leading: const Icon(Icons.add_box_outlined),
                    title: const Text('cadastrar material'),
                    onTap:() {
                      Navigator.pop(context);
                      Navigator.push(context, 
                      MaterialPageRoute(builder: (builder) => const CadastroMaterialScreen())
                      );
                    },
                ),

            ],
         )
        );
    }
}