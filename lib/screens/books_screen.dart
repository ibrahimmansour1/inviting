import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/book_model.dart';
import '../models/language_model.dart';

class BooksScreen extends StatelessWidget {
  final Language language;

  const BooksScreen({super.key, required this.language});

  Future<void> _shareBook(BuildContext context, Book book) async {
    try {
      // If there's a shareable link, share it directly
      if (book.shareableLink != null && book.shareableLink!.isNotEmpty) {
        await Share.share(
          'Check out this book: "${book.title}"\n\n${book.shareableLink}',
          subject: book.title,
        );
        return;
      }

      // Otherwise, download and share the file if available
      if (book.fileUrl != null && book.fileUrl!.isNotEmpty) {
        final tempDir = await getTemporaryDirectory();
        final fileName = book.fileUrl!.split('/').last;
        final tempPath = '${tempDir.path}/$fileName';
        final tempFile = File(tempPath);

        if (!await tempFile.exists()) {
          final dio = Dio();
          await dio.download(book.fileUrl!, tempPath);
        }

        await Share.shareXFiles(
          [XFile(tempPath)],
          text: 'Check out this book: "${book.title}"',
          subject: book.title,
        );
      } else {
        throw Exception('No file or link available for sharing');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share book: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openBook(BuildContext context, Book book) async {
    try {
      if (book.fileUrl != null && book.fileUrl!.isNotEmpty) {
        final uri = Uri.parse(book.fileUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not open book';
        }
      } else {
        throw 'No file URL available';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open book: ${e.toString()}'),
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
                'Scan to Access',
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

  @override
  Widget build(BuildContext context) {
    final books = language.books ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Books - ${language.name}'),
        centerTitle: true,
      ),
      body: books.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No books available',
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
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Book cover image
                      if (book.coverImageUrl != null &&
                          book.coverImageUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: Image.network(
                            book.coverImageUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              height: 200,
                              color: Colors.green.shade100,
                              child: Center(
                                child: Icon(
                                  Icons.book,
                                  size: 60,
                                  color: Colors.green.shade400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Book details
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                            if (book.description != null &&
                                book.description!.isNotEmpty) ...[
                              SizedBox(height: 8),
                              Text(
                                book.description!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                            SizedBox(height: 16),
                            // Action buttons
                            Row(
                              children: [
                                if (book.fileUrl != null &&
                                    book.fileUrl!.isNotEmpty)
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _openBook(context, book),
                                      icon: Icon(Icons.menu_book),
                                      label: Text('Read Book'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade600,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => _shareBook(context, book),
                                  icon: Icon(Icons.share),
                                  color: Colors.green.shade700,
                                  tooltip: 'Share Book',
                                ),
                                if (book.shareableLink != null &&
                                    book.shareableLink!.isNotEmpty)
                                  IconButton(
                                    onPressed: () => _showQRCode(
                                        context, book.shareableLink!),
                                    icon: Icon(Icons.qr_code),
                                    color: Colors.green.shade700,
                                    tooltip: 'Show QR Code',
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
