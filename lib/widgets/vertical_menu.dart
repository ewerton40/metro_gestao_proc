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
 children: <Widget>[
  SizedBox(
 height: 130,
 child: DrawerHeader(
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
                                    Row(
                                        children: [
                                            SizedBox(
                                                width: 50,
                                                height: 50,
                                                child: Image.asset('assets/images/logo_metro_menu.png')
                                            ),  
                                            const SizedBox(width: 8),
                                            const Text(
                                                'METRÔ', 
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color: Color(0xFF001789),
                                                ),
                                            ),
                                        ],
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
 leading: const Icon(Icons.grid_view),
 title: const Text('Painel'),
 onTap:() {
 Navigator.pop(context); 
 },
 ),

               
 ListTile(
 leading: const Icon(Icons.inventory_2_outlined), 
 title: const Text('Inventário'),
 onTap:() {
 Navigator.pop(context);
 },
 ),

             
 ListTile(
 leading: const Icon(Icons.input), 
 title: const Text('Entradas'),
 onTap:() {
 Navigator.pop(context);
 },
 ),

               
 ListTile(
 leading: const Icon(Icons.bar_chart), 
 title: const Text('Relatórios'),
 onTap:() {
 Navigator.pop(context);
 },
 ),

              
 ListTile(
 leading: const Icon(Icons.settings), 
 title: const Text('Configurações'),
 onTap:() {
 Navigator.pop(context);
 },
 ),

               
 ListTile(
 leading: const Icon(Icons.help_outline), 
 title: const Text('Ajuda'),
 onTap:() {
 Navigator.pop(context);
 },
 ),

               

 ],
)
 );
 }
}
