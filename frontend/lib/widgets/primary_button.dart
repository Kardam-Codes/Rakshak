import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isDanger;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isDanger) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
        onPressed: onPressed,
        child: Text(text),
      );
    }
    
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
