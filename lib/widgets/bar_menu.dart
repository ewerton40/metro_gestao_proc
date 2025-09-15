import 'package:flutter/material.dart';

class BarMenu extends StatefulWidget implements PreferredSizeWidget{
  const BarMenu({super.key});

  @override 
  State<BarMenu> createState() => _BarMenuState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


class _BarMenuState extends State<BarMenu>{


  @override
  Widget build(BuildContext context){
    return AppBar(
        title: InkWell(
        onTap: () {},
        child: Image.asset(
          'assets/images/logo_metro_bar.png',
          height: kToolbarHeight * 0.7,
          fit: BoxFit.contain,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 50 ),
          child: IconButton(
          onPressed: (){},
          icon: const Icon(Icons.notifications),
        ),
        ),
        Padding(
              padding: const EdgeInsets.only(right: 50),
            child: PopupMenuButton(
              child: TextButton.icon(
              onPressed: null,
              icon: const Icon(Icons.person, color: Colors.black,),
              label: Text('User', style: TextStyle(color: Colors.black)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black
                )
          ),
          offset: const Offset(0, 50),
          itemBuilder:(BuildContext context) => <PopupMenuEntry<String>>[
           PopupMenuItem(
            child: TextButton.icon(
              onPressed: null,
              icon: Icon(Icons.settings),
              label: const Text('Configurações', style: TextStyle(color: Colors.black),),
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black
                )
              ) 
              ),

          ]
          ),
          ),
      ],
    );
    
  }

  
}