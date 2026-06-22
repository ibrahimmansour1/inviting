import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../models/language_model.dart';
import '../models/video_model.dart';
import 'video_player_screen.dart';

class VideosScreen extends StatelessWidget {
  final Language language;

  const VideosScreen({super.key, required this.language});

  Future<void> _shareVideo(BuildContext context, Video video) async {
    try {
      // If there's a shareable link, share it
      if (video.shareableLink != null && video.shareableLink!.isNotEmpty) {
        await Share.share(
          'Watch this video: "${video.title}"\n\n${video.shareableLink}',
          subject: video.title,
        );
      } else {
        // Share the video URL
        await Share.share(
          'Watch this video: "${video.title}"\n\n${video.videoUrl}',
          subject: video.title,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share video: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showQRCode(BuildContext context, String data) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Scan to Watch',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: QrImageView(
                  data: data,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _playVideo(BuildContext context, Video video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(video: video),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final videos = language.videos ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Videos - ${language.name}'),
        centerTitle: true,
      ),
      body: videos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_library_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No videos available',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () => _playVideo(context, video),
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Video thumbnail
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: video.thumbnailUrl != null &&
                                      video.thumbnailUrl!.isNotEmpty
                                  ? Image.network(
                                      video.thumbnailUrl!,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              _buildDefaultThumbnail(),
                                    )
                                  : _buildDefaultThumbnail(),
                            ),
                            // Play button overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.play_arrow,
                                      size: 40,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Duration badge
                            if (video.durationSeconds != null)
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    video.formattedDuration,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        // Video details
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                              if (video.description != null &&
                                  video.description!.isNotEmpty) ...[
                                SizedBox(height: 8),
                                Text(
                                  video.description!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              SizedBox(height: 12),
                              // Action buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => _playVideo(context, video),
                                    icon: Icon(Icons.play_arrow),
                                    label: Text('Watch'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade600,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () =>
                                            _shareVideo(context, video),
                                        icon: Icon(Icons.share),
                                        color: Colors.green.shade700,
                                        tooltip: 'Share Video',
                                      ),
                                      if (video.shareableLink != null &&
                                          video.shareableLink!.isNotEmpty)
                                        IconButton(
                                          onPressed: () => _showQRCode(
                                              context, video.shareableLink!),
                                          icon: Icon(Icons.qr_code),
                                          color: Colors.green.shade700,
                                          tooltip: 'Show QR Code',
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDefaultThumbnail() {
    return Container(
      height: 200,
      color: Colors.green.shade100,
      child: Center(
        child: Icon(
          Icons.video_library,
          size: 60,
          color: Colors.green.shade400,
        ),
      ),
    );
  }
}
