import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GymBuddyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSecondary;
  final Widget? icon;

  const GymBuddyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSecondary
            ? const Color(0xFF1A1A1A)
            : AppTheme.neonLime,
        foregroundColor: isSecondary ? Colors.white : Colors.black,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        side: isSecondary ? const BorderSide(color: Color(0xFF333333)) : null,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 8)],
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
