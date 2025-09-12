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
        IconButton(
          onPressed: (){},
          icon: const Icon(Icons.notifications),
        ),
        IconButton(
          onPressed: (){}, 
          icon: const Icon(Icons.person))
      ],
    );
    
  }

  
}