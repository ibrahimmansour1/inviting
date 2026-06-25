import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'audio_waveform_widget.dart';

class AudioControlsWidget extends StatelessWidget {
  final AudioPlayer audioPlayer;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onPlayPause;
  final VoidCallback onShare;
  final String Function(Duration) formatTime;

  const AudioControlsWidget({
    super.key,
    required this.audioPlayer,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.isLoading,
    required this.hasError,
    required this.onPlayPause,
    required this.onShare,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade50,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.green.shade100,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Track progress
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: 8,
              ),
              overlayShape: RoundSliderOverlayShape(
                overlayRadius: 16,
              ),
              activeTrackColor: Colors.green.shade700,
              inactiveTrackColor: Colors.green.shade100,
              thumbColor: Colors.white,
              overlayColor: Colors.green.withValues(alpha: 0.2),
            ),
            child: Column(
              children: [
                // Waveform visualization
                AudioWaveformWidget(
                  position: position,
                  duration: duration,
                ),
                Slider(
                  value: position.inSeconds.toDouble(),
                  min: 0,
                  max: duration.inSeconds.toDouble() > 0
                      ? duration.inSeconds.toDouble()
                      : 1,
                  onChanged: (value) {
                    final newPosition = Duration(seconds: value.toInt());
                    audioPlayer.seek(newPosition);
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatTime(position),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        formatTime(duration),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          // Player controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Rewind 10 seconds
              MaterialButton(
                onPressed: () {
                  audioPlayer.seek(
                    Duration(seconds: position.inSeconds - 10),
                  );
                },
                shape: CircleBorder(),
                color: Colors.white,
                elevation: 2,
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.replay_10,
                  color: Colors.green.shade700,
                  size: 30,
                ),
              ),
              // Play/Pause
              GestureDetector(
                onTap: onPlayPause,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: hasError
                          ? [Colors.red.shade400, Colors.red.shade700]
                          : [Colors.green.shade400, Colors.green.shade700],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (hasError ? Colors.red : Colors.green)
                            .withValues(alpha: 0.3),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        )
                      : Icon(
                          hasError
                              ? Icons.refresh
                              : (isPlaying ? Icons.pause : Icons.play_arrow),
                          color: Colors.white,
                          size: 40,
                        ),
                ),
              ),
              // Forward 10 seconds
              MaterialButton(
                onPressed: () {
                  audioPlayer.seek(
                    Duration(seconds: position.inSeconds + 10),
                  );
                },
                shape: CircleBorder(),
                color: Colors.white,
                elevation: 2,
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.forward_10,
                  color: Colors.green.shade700,
                  size: 30,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Share button row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: onShare,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                color: Colors.green,
                elevation: 2,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Share Audio',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
