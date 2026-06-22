import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/language_model.dart';
import '../services/language_service.dart';
import '../widgets/audio_player/audio_controls_widget.dart';
import '../widgets/audio_player/audio_status_indicator.dart';
import '../widgets/audio_player/connect_share_section_widget.dart';
import '../widgets/audio_player/flag_image_widget.dart';
import '../widgets/audio_player/motivational_quote_widget.dart';
import 'additional_sounds_screen.dart';
import 'books_screen.dart';
import 'videos_screen.dart';

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
    });

    try {
      final url =
          await _languageService.getCachedAudioPath(widget.language);
      await audioPlayer.play(UrlSource(url));
      WakelockPlus.enable();
      setState(() {
        isPlaying = true;
        isLoading = false;
        errorMessage = null;
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
      WakelockPlus.disable();
      setState(() {
        isPlaying = false;
        position = Duration.zero;
      });
    });
  }

  IconData _getErrorIcon(String? errorMsg) {
    // Show network-specific icons based on error message
    if (errorMsg != null) {
      final message = errorMsg.toLowerCase();
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

  Future<void> _shareAudio() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = widget.language.audioFileName;
      final tempPath = '${tempDir.path}/$fileName';
      final tempFile = File(tempPath);

      if (!await tempFile.exists()) {
        final dio = Dio();
        await dio.download(widget.language.audioPath, tempPath);
      }

      await Share.shareXFiles(
        [XFile(tempPath)],
        text:
            'Listen to "${widget.language.name}" pronunciation (${widget.language.nativeName})',
        subject: 'Audio pronunciation - ${widget.language.name}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share audio: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    try {
      // Remove any non-digit characters except the leading +
      String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final url = Uri.parse('https://wa.me/$cleanedNumber');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open WhatsApp: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
      final url =
          await _languageService.getCachedAudioPath(widget.language);
      await audioPlayer.play(UrlSource(url));
      WakelockPlus.enable();
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
    WakelockPlus.disable();
    audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Parse motivational text to extract phone number and actual message
  Map<String, String?> _parseMotivationalText() {
    String? phoneNumber;
    String? message;

    if (widget.language.motivationalText != null &&
        widget.language.motivationalText!.isNotEmpty) {
      final text = widget.language.motivationalText!.trim();

      // Look for phone number pattern at the beginning (starts with +)
      final phoneRegex = RegExp(r'^\+\d+');
      final match = phoneRegex.firstMatch(text);

      if (match != null) {
        phoneNumber = match.group(0);
        // Get the message part (everything after the phone number)
        message = text.substring(match.end).trim();
      } else {
        // If no phone number found, treat entire text as message
        message = text;
      }
    }

    return {'phoneNumber': phoneNumber, 'message': message};
  }

  void _handlePlayPause() async {
    if (isLoading) {
      return;
    }

    if (hasError) {
      _initializeAudio();
      return;
    }

    if (isPlaying) {
      await audioPlayer.pause();
      WakelockPlus.disable();
      setState(() => isPlaying = false);
    } else {
      if (audioPlayer.state == PlayerState.paused) {
        await audioPlayer.resume();
        WakelockPlus.enable();
        setState(() => isPlaying = true);
      } else {
        playAudio();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Parse motivational text to extract phone number and message
    final parsedData = _parseMotivationalText();
    final extractedPhoneNumber = parsedData['phoneNumber'];
    final actualMessage = parsedData['message'];

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
            WakelockPlus.disable();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.share, color: Colors.white, size: 20),
            ),
            onPressed: _shareAudio,
          ),
        ],
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
                FlagImageWidget(
                  language: widget.language,
                  languageService: _languageService,
                ),
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
                                  child: FlagImageWidget(
                                    language: widget.language,
                                    languageService: _languageService,
                                    isSmall: true,
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
                            // Status indicator
                            AudioStatusIndicator(
                              isLoading: isLoading,
                              hasError: hasError,
                              errorMessage: errorMessage,
                              isLocal: widget.language.isLocal,
                              getErrorIcon: _getErrorIcon,
                            ),
                            SizedBox(height: 36),
                            AudioControlsWidget(
                              audioPlayer: audioPlayer,
                              position: position,
                              duration: duration,
                              isPlaying: isPlaying,
                              isLoading: isLoading,
                              hasError: hasError,
                              onPlayPause: _handlePlayPause,
                              onShare: _shareAudio,
                              formatTime: formatTime,
                            ),
                            SizedBox(height: 36),
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
                            // Motivational quote
                            if (actualMessage != null &&
                                actualMessage.isNotEmpty)
                              MotivationalQuoteWidget(
                                motivationalText: actualMessage,
                              ),
                            // Connect & Share section (QR Code + WhatsApp)
                            ConnectShareSectionWidget(
                              qrDescription: widget.language.qrDescription,
                              personNum: widget.language.personNum,
                              extractedPhoneNumber: extractedPhoneNumber,
                              onWhatsAppPressed: _openWhatsApp,
                            ),
                            // Additional sounds button
                            if (widget.language.additionalSoundsCount != null &&
                                widget.language.additionalSoundsCount! > 0)
                              Container(
                                width: double.infinity,
                                margin: EdgeInsets.only(bottom: 16),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    audioPlayer.pause();
                                    WakelockPlus.disable();
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
                                  icon: Icon(
                                    Icons.library_music,
                                    color: Colors.white,
                                  ),
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
                            // Books button
                            if (widget.language.books != null &&
                                widget.language.books!.isNotEmpty)
                              Container(
                                width: double.infinity,
                                margin: EdgeInsets.only(bottom: 16),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    audioPlayer.pause();
                                    WakelockPlus.disable();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BooksScreen(
                                          language: widget.language,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.menu_book,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    'Books (${widget.language.books!.length})',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade600,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                    shadowColor:
                                        Colors.blue.withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
                            // Videos button
                            if (widget.language.videos != null &&
                                widget.language.videos!.isNotEmpty)
                              Container(
                                width: double.infinity,
                                margin: EdgeInsets.only(bottom: 16),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    audioPlayer.pause();
                                    WakelockPlus.disable();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VideosScreen(
                                          language: widget.language,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.video_library,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    'Videos (${widget.language.videos!.length})',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade600,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                    shadowColor:
                                        Colors.red.withValues(alpha: 0.3),
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
                                WakelockPlus.disable();
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
