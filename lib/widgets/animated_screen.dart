import 'package:flutter/material.dart';

class AnimatedScreen extends StatefulWidget {
  final Widget child;

  const AnimatedScreen({super.key, required this.child});

  @override
  State<AnimatedScreen> createState() => _AnimatedScreenState();
}

class _AnimatedScreenState extends State<AnimatedScreen> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _show = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      opacity: _show ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        offset: _show ? Offset.zero : const Offset(0, 0.02),
        child: widget.child,
      ),
    );
  }
}
