import 'package:flutter/material.dart';

class AudioStatusIndicator extends StatelessWidget {
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final bool isLocal;
  final IconData Function(String?) getErrorIcon;

  const AudioStatusIndicator({
    super.key,
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
    required this.isLocal,
    required this.getErrorIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading && !hasError) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: hasError
            ? Colors.red.shade100
            : isLoading
                ? Colors.blue.shade100
                : Colors.green.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasError
              ? Colors.red.shade300
              : isLoading
                  ? Colors.blue.shade300
                  : Colors.green.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasError)
            Icon(getErrorIcon(errorMessage),
                color: Colors.red.shade700, size: 16)
          else if (isLoading)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.blue.shade700),
              ),
            )
          else
            Icon(Icons.download, color: Colors.green.shade700, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              hasError
                  ? 'Error: ${errorMessage ?? "Unknown error"}'
                  : isLoading
                      ? errorMessage ?? 'Loading...'
                      : isLocal
                          ? 'Local audio'
                          : 'Downloaded',
              style: TextStyle(
                color: hasError
                    ? Colors.red.shade700
                    : isLoading
                        ? Colors.blue.shade700
                        : Colors.green.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
