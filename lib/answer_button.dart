import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnswerButton extends StatelessWidget {
  const AnswerButton({
    super.key,
    required this.answer,
    required this.onTap,
    this.isEnabled = true,
  });

  final String answer;
  final void Function() onTap;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6E50FF),
            Color(0xFFB867FF),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: isEnabled ? onTap : null,
        child: Text(
          answer,
          style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
