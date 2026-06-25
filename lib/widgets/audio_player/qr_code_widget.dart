import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeWidget extends StatelessWidget {
  final String? qrData; // URL to encode as QR
  final String? qrImageUrl; // Direct QR code image URL

  const QrCodeWidget({
    super.key,
    this.qrData,
    this.qrImageUrl,
  }) : assert(qrData != null || qrImageUrl != null,
            'Either qrData or qrImageUrl must be provided');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.shade100,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // If image URL is provided, show the image, otherwise generate QR code
          if (qrImageUrl != null && qrImageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                qrImageUrl!,
                width: 180,
                height: 180,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    width: 180,
                    height: 180,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to generating QR from qrData if image fails
                  if (qrData != null && qrData!.isNotEmpty) {
                    return QrImageView(
                      data: qrData!,
                      version: QrVersions.auto,
                      size: 180,
                      backgroundColor: Colors.white,
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                    );
                  }
                  return Container(
                    width: 180,
                    height: 180,
                    color: Colors.grey.shade200,
                    child: Icon(Icons.qr_code_2, size: 80, color: Colors.grey),
                  );
                },
              ),
            )
          else if (qrData != null && qrData!.isNotEmpty)
            QrImageView(
              data: qrData!,
              version: QrVersions.auto,
              size: 180,
              backgroundColor: Colors.white,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
            )
          else
            Container(
              width: 180,
              height: 180,
              color: Colors.grey.shade200,
              child: Icon(Icons.qr_code_2, size: 80, color: Colors.grey),
            ),
          SizedBox(height: 8),
          Text(
            'Scan to learn more',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
