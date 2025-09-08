import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget{
  final VoidCallback onPressed;
  final Text text;
  final Color color;
  final Size size;

  const CustomButton({super.key, required this.onPressed, required this.text, required this.color, required this.size});

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>{
  @override
  Widget build(BuildContext context){
    return ElevatedButton(
      onPressed: widget.onPressed, 
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.color,
        fixedSize: widget.size 
        ),
      child: widget.text,
      
    );
  }

}