import 'package:flutter/material.dart';

import 'qr_code_widget.dart';
import 'whatsapp_button_widget.dart';

class ConnectShareSectionWidget extends StatelessWidget {
  final String? qrDescription;
  final int? personNum;
  final String? extractedPhoneNumber;
  final Function(String) onWhatsAppPressed;

  const ConnectShareSectionWidget({
    super.key,
    required this.qrDescription,
    required this.personNum,
    this.extractedPhoneNumber,
    required this.onWhatsAppPressed,
  });

  @override
  Widget build(BuildContext context) {
    final hasQrCode = qrDescription != null && qrDescription!.isNotEmpty;
    // Prefer extracted phone number, fallback to personNum
    final phoneNumber = extractedPhoneNumber ?? (personNum?.toString());
    final hasWhatsApp = phoneNumber != null && phoneNumber.isNotEmpty;

    if (!hasQrCode && !hasWhatsApp) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.shade200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Connect & Share',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade900,
            ),
          ),
          SizedBox(height: 16),
          if (hasQrCode) QrCodeWidget(qrData: qrDescription!),
          if (hasWhatsApp)
            WhatsAppButtonWidget(
              onPressed: () => onWhatsAppPressed(phoneNumber),
              hasQrCode: hasQrCode,
            ),
        ],
      ),
    );
  }
}
