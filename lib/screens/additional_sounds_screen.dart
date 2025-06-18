import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../models/additional_sound_model.dart';
import '../models/language_model.dart';
import '../services/language_service.dart';

class AdditionalSoundsScreen extends StatefulWidget {
  final Language language;

  const AdditionalSoundsScreen({super.key, required this.language});

  @override
  State<AdditionalSoundsScreen> createState() => _AdditionalSoundsScreenState();
}

class _AdditionalSoundsScreenState extends State<AdditionalSoundsScreen>
    with TickerProviderStateMixin {
  late AudioPlayer audioPlayer;
  final LanguageService _languageService = LanguageService();

  Language? _detailedLanguage;
  bool _isLoading = true;
  String? _errorMessage;

  // Audio state
  bool isPlaying = false;
  bool isLoadingAudio = false;
  AdditionalSound? currentlyPlayingSound;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    _setupAudioPlayer();
    _loadLanguageDetails();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  void _setupAudioPlayer() {
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
        currentlyPlayingSound = null;
        position = Duration.zero;
      });
    });
  }

  Future<void> _loadLanguageDetails() async {
    if (widget.language.id == null) {
      setState(() {
        _errorMessage = 'Language ID is required';
        _isLoading = false;
      });
      return;
    }

    try {
      final detailedLanguage =
          await _languageService.getLanguageById(widget.language.id!);
      setState(() {
        _detailedLanguage = detailedLanguage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _playAdditionalSound(AdditionalSound sound) async {
    if (isLoadingAudio) return;

    // Stop current playback
    if (isPlaying) {
      await audioPlayer.stop();
    }

    setState(() {
      isLoadingAudio = true;
      currentlyPlayingSound = sound;
    });

    try {
      final cachedPath = await _languageService.getCachedAdditionalSoundPath(
        sound.file,
        sound.fileName,
      );

      await audioPlayer.play(DeviceFileSource(cachedPath));
      setState(() {
        isPlaying = true;
        isLoadingAudio = false;
      });
    } catch (e) {
      setState(() {
        isLoadingAudio = false;
        currentlyPlayingSound = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error playing audio: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () {
            audioPlayer.stop();
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Additional Sounds',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: const Offset(0, 1),
                blurRadius: 3,
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.green.shade400,
                  Colors.green.shade600,
                  Colors.green.shade800,
                ],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: _isLoading
                ? _buildLoadingWidget()
                : _errorMessage != null
                    ? _buildErrorWidget()
                    : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Loading additional sounds...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Additional Sounds',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadLanguageDetails();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green.shade700,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final additionalSounds = _detailedLanguage?.additionalSounds ?? [];

    if (additionalSounds.isEmpty) {
      return _buildNoSoundsWidget();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    widget.language.nativeName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${additionalSounds.length} Additional Sound${additionalSounds.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            // Sounds list
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                  itemCount: additionalSounds.length,
                  itemBuilder: (context, index) {
                    final sound = additionalSounds[index];
                    return _buildSoundCard(sound, index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSoundsWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_off,
              size: 64,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 16),
            Text(
              'No Additional Sounds',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This language doesn\'t have any additional sounds available.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundCard(AdditionalSound sound, int index) {
    final isCurrentlyPlaying = currentlyPlayingSound?.id == sound.id;
    final isCurrentlyLoading = isLoadingAudio && isCurrentlyPlaying;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCurrentlyPlaying
              ? [Colors.green.shade50, Colors.green.shade100]
              : [Colors.grey.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color:
              isCurrentlyPlaying ? Colors.green.shade200 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Play button
                GestureDetector(
                  onTap: () async {
                    if (isCurrentlyPlaying && isPlaying) {
                      await audioPlayer.pause();
                      setState(() => isPlaying = false);
                    } else if (isCurrentlyPlaying && !isPlaying) {
                      await audioPlayer.resume();
                      setState(() => isPlaying = true);
                    } else {
                      await _playAdditionalSound(sound);
                    }
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.green.shade400,
                          Colors.green.shade600,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.3),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isCurrentlyLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : Icon(
                            isCurrentlyPlaying && isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 28,
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                // Sound info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sound.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Added ${sound.createdAtHuman}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status indicator
                if (isCurrentlyPlaying)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPlaying ? Icons.volume_up : Icons.pause,
                          size: 14,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPlaying ? 'Playing' : 'Paused',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            // Progress bar (only shown when playing)
            if (isCurrentlyPlaying && duration.inSeconds > 0) ...[
              const SizedBox(height: 16),
              Column(
                children: [
                  // Waveform visualization
                  Container(
                    height: 32,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        20,
                        (i) {
                          final progress = position.inMilliseconds /
                              (duration.inMilliseconds > 0
                                  ? duration.inMilliseconds
                                  : 1);
                          final barProgress = i / 20;
                          final isActive = barProgress <= progress;

                          // Create varied heights for visual appeal
                          double height =
                              0.3 + (0.7 * (1 - (i - 10).abs() / 10));
                          if (i % 3 == 0) height *= 0.7;
                          if (i % 5 == 0) height *= 1.3;

                          return Container(
                            width: 2,
                            height: 24 * height,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1),
                              color: isActive
                                  ? Colors.green.shade400
                                  : Colors.grey.shade300,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Time progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatTime(position),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatTime(duration),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // Slider
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 12),
                      activeTrackColor: Colors.green.shade400,
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbColor: Colors.green.shade600,
                      overlayColor: Colors.green.withValues(alpha: 0.2),
                    ),
                    child: Slider(
                      value: position.inSeconds.toDouble(),
                      min: 0,
                      max: duration.inSeconds.toDouble() > 0
                          ? duration.inSeconds.toDouble()
                          : 1,
                      onChanged: (value) {
                        final newPosition = Duration(seconds: value.toInt());
                        audioPlayer.seek(newPosition);
                        setState(() {
                          position = newPosition;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
