import 'package:flutter/material.dart';

class AudioWaveformWidget extends StatelessWidget {
  final Duration position;
  final Duration duration;

  const AudioWaveformWidget({
    super.key,
    required this.position,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          30,
          (i) {
            // Create a pattern that's higher in the middle
            double normalizedHeight = 0.3;
            if (i > 5 && i < 25) {
              normalizedHeight = 0.3 + 0.7 * (1 - (i - 15).abs() / 10);
            }

            // Make bars to the left of current position more prominent
            final progress = position.inMilliseconds /
                (duration.inMilliseconds > 0 ? duration.inMilliseconds : 1);
            final barProgress = i / 30;
            final isActive = barProgress <= progress;

            return Container(
              width: 3,
              height: 30 * normalizedHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1.5),
                color: isActive ? Colors.green.shade300 : Colors.grey.shade300,
              ),
            );
          },
        ),
      ),
    );
  }
}
