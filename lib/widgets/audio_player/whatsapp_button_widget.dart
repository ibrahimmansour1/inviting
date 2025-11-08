import 'package:flutter/material.dart';

class WhatsAppButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final bool hasQrCode;

  const WhatsAppButtonWidget({
    super.key,
    required this.onPressed,
    this.hasQrCode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: hasQrCode ? 16 : 0),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          Icons.message,
          color: Colors.white,
          size: 20,
        ),
        label: Text(
          'Contact on WhatsApp',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF25D366),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: Color(0xFF25D366).withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
