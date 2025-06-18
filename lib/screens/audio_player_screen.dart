import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../models/language_model.dart';
import '../services/language_service.dart';
import 'additional_sounds_screen.dart';

class AudioPlayerScreen extends StatefulWidget {
  final Language language;

  const AudioPlayerScreen({super.key, required this.language});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen>
    with SingleTickerProviderStateMixin {
  late AudioPlayer audioPlayer;
  bool isPlaying = false;
  bool isLoading = false;
  bool hasError = false;
  String? errorMessage;
  double downloadProgress = 0.0;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  late AnimationController _animationController;
  late Animation<double> _flagAnimation;
  late Animation<double> _contentAnimation;
  final LanguageService _languageService = LanguageService();

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    setupAudioPlayer();
    _initializeAudio();

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

  void _initializeAudio() async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = null;
      downloadProgress = 0.0;
    });

    try {
      // Since all languages now come from backend, use LanguageService to get cached audio path
      final cachedPath =
          await _languageService.getCachedAudioPath(widget.language);
      await audioPlayer.play(DeviceFileSource(cachedPath));
      setState(() {
        isPlaying = true;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = e.toString();
        isLoading = false;
      });
    }
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

  IconData _getErrorIcon() {
    // Show network-specific icons based on error message
    if (errorMessage != null) {
      final message = errorMessage!.toLowerCase();
      if (message.contains('internet') ||
          message.contains('connection') ||
          message.contains('network') ||
          message.contains('connectivity')) {
        return Icons.wifi_off; // No internet connection
      } else if (message.contains('timeout')) {
        return Icons.access_time; // Connection timeout
      } else if (message.contains('server') || message.contains('not found')) {
        return Icons.cloud_off; // Server error
      }
    }
    return Icons.error_outline; // Generic error
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void playAudio() async {
    if (hasError) {
      // If there was an error, try to reinitialize
      _initializeAudio();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Use LanguageService to get cached audio path for all languages
      final cachedPath =
          await _languageService.getCachedAudioPath(widget.language);
      await audioPlayer.play(DeviceFileSource(cachedPath));
      setState(() {
        isPlaying = true;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Error playing audio: $e';
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildFlagImage() {
    return FutureBuilder<String>(
      future: _languageService.getCachedFlagPath(widget.language),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.startsWith('/')) {
            // Local cached file
            return Image.file(
              File(snapshot.data!),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildFlagPlaceholder();
              },
            );
          } else {
            // Network image
            return Image.network(
              snapshot.data!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return _buildFlagPlaceholder();
              },
            );
          }
        } else if (snapshot.hasError) {
          return _buildFlagPlaceholder();
        } else {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }
      },
    );
  }

  Widget _buildSmallFlagImage() {
    return FutureBuilder<String>(
      future: _languageService.getCachedFlagPath(widget.language),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.startsWith('/')) {
            // Local cached file
            return Image.file(
              File(snapshot.data!),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildSmallFlagPlaceholder();
              },
            );
          } else {
            // Network image
            return Image.network(
              snapshot.data!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return _buildSmallFlagPlaceholder();
              },
            );
          }
        } else if (snapshot.hasError) {
          return _buildSmallFlagPlaceholder();
        } else {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 1,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          );
        }
      },
    );
  }

  Widget _buildFlagPlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag,
              color: Colors.grey.shade600,
              size: 48,
            ),
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
  }

  Widget _buildSmallFlagPlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: Center(
        child: Icon(
          Icons.flag,
          color: Colors.grey.shade600,
          size: 24,
        ),
      ),
    );
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
              color: Colors.black.withValues(alpha: 0.3),
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
                _buildFlagImage(),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.6),
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
                        color: Colors.black.withValues(alpha: 0.1),
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
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
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
                                  child: _buildSmallFlagImage(),
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
                            // Status indicator
                            if (isLoading ||
                                hasError ||
                                (!widget.language.isLocal &&
                                    downloadProgress > 0 &&
                                    downloadProgress < 1))
                              Container(
                                margin: EdgeInsets.only(top: 16),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
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
                                      Icon(_getErrorIcon(),
                                          color: Colors.red.shade700, size: 16)
                                    else if (isLoading)
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(
                                              Colors.blue.shade700),
                                        ),
                                      )
                                    else
                                      Icon(Icons.download,
                                          color: Colors.green.shade700,
                                          size: 16),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        hasError
                                            ? 'Error: ${errorMessage ?? "Unknown error"}'
                                            : isLoading
                                                ? downloadProgress > 0
                                                    ? 'Downloading ${(downloadProgress * 100).toInt()}%'
                                                    : 'Loading...'
                                                : widget.language.isLocal
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
                                      overlayColor:
                                          Colors.green.withValues(alpha: 0.2),
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
                                          if (isLoading) {
                                            return; // Don't allow interaction while loading
                                          }

                                          if (hasError) {
                                            _initializeAudio(); // Retry on error
                                            return;
                                          }

                                          if (isPlaying) {
                                            await audioPlayer.pause();
                                            setState(() => isPlaying = false);
                                          } else {
                                            if (audioPlayer.state ==
                                                PlayerState.paused) {
                                              await audioPlayer.resume();
                                              setState(() => isPlaying = true);
                                            } else {
                                              playAudio();
                                            }
                                          }
                                        },
                                        child: Container(
                                          width: 72,
                                          height: 72,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: hasError
                                                  ? [
                                                      Colors.red.shade400,
                                                      Colors.red.shade700
                                                    ]
                                                  : [
                                                      Colors.green.shade400,
                                                      Colors.green.shade700
                                                    ],
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: (hasError
                                                        ? Colors.red
                                                        : Colors.green)
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
                                                      : (isPlaying
                                                          ? Icons.pause
                                                          : Icons.play_arrow),
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
                            // Additional sounds button
                            if (widget.language.additionalSoundsCount != null &&
                                widget.language.additionalSoundsCount! > 0)
                              Container(
                                width: double.infinity,
                                margin: EdgeInsets.only(bottom: 16),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    audioPlayer.pause();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AdditionalSoundsScreen(
                                          language: widget.language,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.library_music),
                                  label: Text(
                                    'Additional Sounds (${widget.language.additionalSoundsCount})',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade600,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                    shadowColor:
                                        Colors.green.withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
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
