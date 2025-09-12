import 'package:flutter/material.dart';


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
                )

            ],
         )
        );
    }
}