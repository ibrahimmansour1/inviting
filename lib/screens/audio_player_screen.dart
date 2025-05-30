import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../models/language_model.dart';

class AudioPlayerScreen extends StatefulWidget {
  final Language language;

  const AudioPlayerScreen({super.key, required this.language});

  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen>
    with SingleTickerProviderStateMixin {
  late AudioPlayer audioPlayer;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  late AnimationController _animationController;
  late Animation<double> _flagAnimation;
  late Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    setupAudioPlayer();
    playAudio();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _flagAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _contentAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.3, 1.0, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  void setupAudioPlayer() {
    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });

    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        position = Duration.zero;
      });
    });
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void playAudio() async {
    try {
      final audioPath = widget.language.audioPath.replaceFirst('assets/', '');
      await audioPlayer.play(AssetSource(audioPath, mimeType: "audio/m4a"));
      setState(() => isPlaying = true);
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () {
            audioPlayer.stop();
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          // Background with flag image
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  widget.language.flagPath,
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: FadeTransition(
                    opacity: _contentAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(_contentAnimation),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(24, 30, 24, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Country flag emblem
                            ScaleTransition(
                              scale: Tween<double>(
                                begin: 0.8,
                                end: 1.0,
                              ).animate(_flagAnimation),
                              child: Container(
                                width: 80,
                                height: 80,
                                margin: EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    widget.language.flagPath,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            // Country name
                            Text(
                              widget.language.nativeName,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 4),
                            Text(
                              widget.language.name,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 36),
                            // Audio player controls
                            Container(
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
                                    color: Colors.black.withOpacity(0.05),
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
                                      overlayColor:
                                          Colors.green.withOpacity(0.2),
                                    ),
                                    child: Column(
                                      children: [
                                        // Waveform visualization
                                        Container(
                                          height: 40,
                                          margin: EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: List.generate(
                                              30,
                                              (i) {
                                                // Create a pattern that's higher in the middle
                                                double normalizedHeight = 0.3;
                                                if (i > 5 && i < 25) {
                                                  normalizedHeight = 0.3 +
                                                      0.7 *
                                                          (1 -
                                                              (i - 15).abs() /
                                                                  10);
                                                }

                                                // Make bars to the left of current position more prominent
                                                final progress = position
                                                        .inMilliseconds /
                                                    (duration.inMilliseconds > 0
                                                        ? duration
                                                            .inMilliseconds
                                                        : 1);
                                                final barProgress = i / 30;
                                                final isActive =
                                                    barProgress <= progress;

                                                return Container(
                                                  width: 3,
                                                  height: 30 * normalizedHeight,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            1.5),
                                                    color: isActive
                                                        ? Colors.green.shade300
                                                        : Colors.grey.shade300,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        Slider(
                                          value: position.inSeconds.toDouble(),
                                          min: 0,
                                          max: duration.inSeconds.toDouble() > 0
                                              ? duration.inSeconds.toDouble()
                                              : 1,
                                          onChanged: (value) {
                                            final newPosition = Duration(
                                                seconds: value.toInt());
                                            audioPlayer.seek(newPosition);
                                            setState(() {
                                              position = newPosition;
                                            });
                                          },
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // Rewind 10 seconds
                                      MaterialButton(
                                        onPressed: () {
                                          audioPlayer.seek(
                                            Duration(
                                                seconds:
                                                    position.inSeconds - 10),
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
                                        onTap: () async {
                                          if (isPlaying) {
                                            await audioPlayer.pause();
                                            setState(() => isPlaying = false);
                                          } else {
                                            if (audioPlayer.state ==
                                                PlayerState.paused) {
                                              await audioPlayer.resume();
                                            } else {
                                              final audioPath = widget
                                                  .language.audioPath
                                                  .replaceFirst('assets/', '');
                                              await audioPlayer
                                                  .play(AssetSource(audioPath));
                                            }
                                            setState(() => isPlaying = true);
                                          }
                                        },
                                        child: Container(
                                          width: 72,
                                          height: 72,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.green.shade400,
                                                Colors.green.shade700,
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.green
                                                    .withOpacity(0.3),
                                                spreadRadius: 2,
                                                blurRadius: 10,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            isPlaying
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                      // Forward 10 seconds
                                      MaterialButton(
                                        onPressed: () {
                                          audioPlayer.seek(
                                            Duration(
                                                seconds:
                                                    position.inSeconds + 10),
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
                                ],
                              ),
                            ),
                            SizedBox(height: 36),
                            // Info section
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.green.shade100,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.green.shade700,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "This audio contains Islamic teachings in the ${widget.language.name} language.",
                                      style: TextStyle(
                                        color: Colors.green.shade900,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 24),
                            TextButton.icon(
                              icon: Icon(Icons.language),
                              label: Text("Choose Another Language"),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.green.shade700,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              onPressed: () {
                                audioPlayer.stop();
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
