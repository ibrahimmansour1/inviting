import 'package:flutter/material.dart';

import '../models/language_model.dart';
import '../services/audio_cache_manager.dart';

class LanguageCard extends StatefulWidget {
  final Language language;
  final VoidCallback onTap;

  const LanguageCard({
    super.key,
    required this.language,
    required this.onTap,
  });

  @override
  State<LanguageCard> createState() => _LanguageCardState();
}

class _LanguageCardState extends State<LanguageCard> {
  final AudioCacheManager _cacheManager = AudioCacheManager();
  bool _isCached = false;
  bool _isDownloading = false;
  bool _hasNetworkError = false;

  @override
  void initState() {
    super.initState();
    _checkCacheStatus();
  }

  @override
  void didUpdateWidget(LanguageCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.language != widget.language) {
      _checkCacheStatus();
    }
  }

  void _checkCacheStatus() async {
    if (!widget.language.isLocal) {
      final cached =
          await _cacheManager.isAudioCached(widget.language.audioFileName);
      final downloading =
          _cacheManager.isDownloading(widget.language.audioFileName);

      // Check network connectivity for remote languages
      if (!cached && !downloading) {
        try {
          final hasNetwork = await _cacheManager.hasInternetConnection();
          if (mounted) {
            setState(() {
              _hasNetworkError = !hasNetwork;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _hasNetworkError = true;
            });
          }
        }
      }

      if (mounted) {
        setState(() {
          _isCached = cached;
          _isDownloading = downloading;
        });
      }
    }
  }

  // Public method to refresh cache status
  void refreshCacheStatus() {
    _checkCacheStatus();
  }

  Widget _buildStatusIcon() {
    if (widget.language.isLocal) {
      // Local audio - show play icon
      return Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.play_circle_outline,
          color: Colors.white,
          size: 18,
        ),
      );
    } else if (_isDownloading) {
      // Downloading - show progress
      return Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    } else if (_isCached) {
      // Cached - show play icon with green background
      return Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.play_circle_outline,
          color: Colors.white,
          size: 18,
        ),
      );
    } else if (_hasNetworkError) {
      // No network - show network error icon
      return Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.wifi_off,
          color: Colors.white,
          size: 18,
        ),
      );
    } else {
      // Not cached - show download icon
      return Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.download,
          color: Colors.white,
          size: 18,
        ),
      );
    }
  }

  Widget _buildStatusBadge() {
    if (widget.language.isLocal) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'LOCAL',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (_isCached) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'OFFLINE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (_hasNetworkError) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'NO WIFI',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'ONLINE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 5,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: widget.onTap,
        splashColor: Colors.green.withValues(alpha: 0.3),
        child: Stack(
          children: [
            // Flag background with gradient overlay
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                        ),
                        child: Image.asset(
                          widget.language.flagPath,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Subtle gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Country name section
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.green.shade50,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.language.nativeName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green.shade800,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.language.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Status badge (top left)
            Positioned(
              top: 8,
              left: 8,
              child: _buildStatusBadge(),
            ),
            // Status icon (top right)
            Positioned(
              top: 8,
              right: 8,
              child: _buildStatusIcon(),
            ),
          ],
        ),
      ),
    );
  }
}
