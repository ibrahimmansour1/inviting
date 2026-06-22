import 'package:flutter/material.dart';

import '../../models/language_model.dart';
import '../../services/language_service.dart';

class FlagImageWidget extends StatelessWidget {
  final Language language;
  final LanguageService languageService;
  final bool isSmall;

  const FlagImageWidget({
    super.key,
    required this.language,
    required this.languageService,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      language.flagPath,
      fit: isSmall ? null : BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: isSmall ? 1 : 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              isSmall ? Colors.green : Colors.white,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade300,
          child: Center(
            child: isSmall
                ? Icon(Icons.flag, color: Colors.grey.shade600, size: 24)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flag, color: Colors.grey.shade600, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        'Flag',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
