import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/language_service.dart';

/// Enhanced Add Language Screen with ALL required fields
/// Features:
/// 1. Flag Image
/// 2. Arabic Name
/// 3. Native Name
/// 4. Main Audio
/// 5. Multiple Sub-Audios with titles
/// 6. Books (PDF/EPUB)
/// 7. QR Code Link
/// 8. Motivational Text
/// 9. YouTube Video Links
/// 10. WhatsApp Number

class AddLanguageScreen extends StatefulWidget {
  const AddLanguageScreen({super.key});

  @override
  State<AddLanguageScreen> createState() => _AddLanguageScreenState();
}

class _AddLanguageScreenState extends State<AddLanguageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nativeNameController = TextEditingController();
  final _motivationalTextController = TextEditingController();
  final _qrLinkController = TextEditingController();
  final _whatsappController = TextEditingController();
  final LanguageService _languageService = LanguageService();

  File? _selectedFlagFile;
  File? _selectedAudioFile;
  File? _selectedQrImageFile;
  final List<Map<String, dynamic>> _subAudios =
      []; // {file: File, title: TextEditingController}
  final List<File> _selectedBookFiles = [];
  final List<TextEditingController> _youtubeVideoControllers =
      []; // YouTube URLs
  bool _isLoading = false;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nativeNameController.dispose();
    _motivationalTextController.dispose();
    _qrLinkController.dispose();
    _whatsappController.dispose();
    // Dispose sub-audio title controllers
    for (var audio in _subAudios) {
      (audio['title'] as TextEditingController).dispose();
    }
    // Dispose YouTube link controllers
    for (var controller in _youtubeVideoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _checkConnection() async {
    final isOnline = await _languageService.checkServerConnection();
    setState(() {
      _isOnline = isOnline;
    });
  }

  Future<void> _pickFlagImage() async {
    try {
      // Use file picker to support all image formats
      final result = await FilePicker.platform.pickFiles(
        type: FileType
            .image, // Accepts all image formats (jpg, jpeg, png, gif, bmp, webp, etc.)
      );
      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      setState(() {
        _selectedFlagFile = file;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Flag image selected: ${result.files.single.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting flag: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.audio);
      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      setState(() {
        _selectedAudioFile = file;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Audio file selected: ${result.files.single.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickSubAudioFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false, // Pick one at a time to add title
      );
      if (result == null) return;

      final file = File(result.files.single.path!);

      // Show dialog to enter title
      final titleController = TextEditingController();
      if (!mounted) return;
      final title = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Audio Title'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Enter audio title/name',
              hintText: 'e.g., Introduction, Lesson 1',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, titleController.text),
              child: const Text('Add'),
            ),
          ],
        ),
      );

      if (title == null || title.trim().isEmpty) {
        titleController.dispose();
        return;
      }

      setState(() {
        _subAudios.add({
          'file': file,
          'title': TextEditingController(text: title.trim()),
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sub-audio "$title" added'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting sub-audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickBookFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'epub'],
        allowMultiple: true,
      );
      if (result == null) return;

      final files = result.files.map((f) => File(f.path!)).toList();
      setState(() {
        _selectedBookFiles.addAll(files);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${files.length} book file(s) added'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting books: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickQrImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      setState(() {
        _selectedQrImageFile = file;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR image selected: ${result.files.single.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting QR image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addYouTubeVideo() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add YouTube Video'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'YouTube Video URL',
            hintText: 'https://www.youtube.com/watch?v=...',
            prefixIcon: Icon(Icons.link),
          ),
          keyboardType: TextInputType.url,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _youtubeVideoControllers.add(controller);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('YouTube video link added'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeSubAudio(int index) {
    final audio = _subAudios[index];
    (audio['title'] as TextEditingController).dispose();
    setState(() {
      _subAudios.removeAt(index);
    });
  }

  void _removeBook(int index) {
    setState(() {
      _selectedBookFiles.removeAt(index);
    });
  }

  void _removeYouTubeVideo(int index) {
    _youtubeVideoControllers[index].dispose();
    setState(() {
      _youtubeVideoControllers.removeAt(index);
    });
  }

  Future<void> _addLanguage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedFlagFile == null || _selectedAudioFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both flag and audio files'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement complete upload logic with all fields
      // This will require updating the LanguageService to handle:
      // - Sub-audios upload
      // - Books upload
      // - Videos upload
      // - Motivational text, QR link, WhatsApp number

      await _languageService.addLanguage(
        name: _nameController.text.trim(),
        nativeName: _nativeNameController.text.trim(),
        flagFile: _selectedFlagFile!,
        audioFile: _selectedAudioFile!,
        qrLink: _qrLinkController.text.trim().isNotEmpty
            ? _qrLinkController.text.trim()
            : null,
        qrImageFile: _selectedQrImageFile,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Language added successfully! (Note: Extended fields need backend implementation)'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding language: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Language'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: !_isOnline
            ? _buildOfflineMessage()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Language Details Section
                      _buildSection(
                        title: '1. Language Details',
                        icon: Icons.language,
                        color: Colors.green,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Language Name (English)',
                              hintText: 'e.g., German, Portuguese',
                              prefixIcon: Icon(Icons.language),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter the language name';
                              }
                              return null;
                            },
                            textCapitalization: TextCapitalization.words,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nativeNameController,
                            decoration: const InputDecoration(
                              labelText: 'Native Name (Arabic)',
                              hintText: 'e.g., ألماني, برتغالي',
                              prefixIcon: Icon(Icons.translate),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter the native name';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Required Files Section
                      _buildSection(
                        title: '2. Required Files',
                        icon: Icons.attachment,
                        color: Colors.green,
                        children: [
                          _buildFileSelectionCard(
                            title: 'Flag Image',
                            subtitle: _selectedFlagFile != null
                                ? '✓ Flag selected'
                                : 'Tap to select flag',
                            icon: Icons.flag,
                            isSelected: _selectedFlagFile != null,
                            onTap: _pickFlagImage,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 12),
                          _buildFileSelectionCard(
                            title: 'Main Audio File',
                            subtitle: _selectedAudioFile != null
                                ? '✓ Audio selected'
                                : 'Tap to select main audio',
                            icon: Icons.audiotrack,
                            isSelected: _selectedAudioFile != null,
                            onTap: _pickAudioFile,
                            color: Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Sub-Audios Section
                      _buildSection(
                        title: '3. Sub-Audios (Optional)',
                        subtitle: 'Add audio files with titles',
                        icon: Icons.library_music,
                        color: Colors.orange,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickSubAudioFiles,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Sub-Audio File'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade100,
                              foregroundColor: Colors.orange.shade900,
                            ),
                          ),
                          if (_subAudios.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text('${_subAudios.length} audio(s) added:',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ..._subAudios.asMap().entries.map((entry) {
                              final audio = entry.value;
                              final file = audio['file'] as File;
                              final titleController =
                                  audio['title'] as TextEditingController;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Card(
                                  color: Colors.orange.shade50,
                                  child: ListTile(
                                    leading: const Icon(Icons.audiotrack,
                                        color: Colors.orange),
                                    title: Text(titleController.text,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text(
                                      file.path.split('/').last,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _removeSubAudio(entry.key),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Books Section
                      _buildSection(
                        title: '4. Books (Optional)',
                        subtitle: 'PDF or EPUB files',
                        icon: Icons.menu_book,
                        color: Colors.blue,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickBookFiles,
                            icon: const Icon(Icons.add),
                            label: Text('Add Book Files'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade100,
                              foregroundColor: Colors.blue.shade900,
                            ),
                          ),
                          if (_selectedBookFiles.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                                '${_selectedBookFiles.length} file(s) selected:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ..._selectedBookFiles.asMap().entries.map((entry) {
                              return _buildFileItem(
                                entry.value,
                                Icons.picture_as_pdf,
                                Colors.blue,
                                () => _removeBook(entry.key),
                              );
                            }),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),

                      // YouTube Videos Section
                      _buildSection(
                        title: '5. YouTube Videos (Optional)',
                        subtitle: 'Add YouTube video links',
                        icon: Icons.video_library,
                        color: Colors.red,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _addYouTubeVideo,
                            icon: const Icon(Icons.add),
                            label: const Text('Add YouTube Video Link'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade100,
                              foregroundColor: Colors.red.shade900,
                            ),
                          ),
                          if (_youtubeVideoControllers.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                                '${_youtubeVideoControllers.length} video(s) added:',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ..._youtubeVideoControllers
                                .asMap()
                                .entries
                                .map((entry) {
                              final controller = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Card(
                                  color: Colors.red.shade50,
                                  child: ListTile(
                                    leading: const Icon(
                                        Icons.play_circle_filled,
                                        color: Colors.red),
                                    title: Text(
                                      controller.text,
                                      style: const TextStyle(fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: const Text('YouTube Video'),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _removeYouTubeVideo(entry.key),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Additional Information Section
                      _buildSection(
                        title: '6. Additional Information (Optional)',
                        icon: Icons.info_outline,
                        color: Colors.purple,
                        children: [
                          TextFormField(
                            controller: _motivationalTextController,
                            decoration: const InputDecoration(
                              labelText: 'Motivational Text',
                              hintText: 'Add motivational message',
                              prefixIcon: Icon(Icons.format_quote),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          // QR Code Section - Choose between Link or Image
                          Text(
                            'QR Code (Choose one):',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.purple.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _qrLinkController,
                            decoration: const InputDecoration(
                              labelText: 'QR Code Link',
                              hintText: 'URL that will be converted to QR code',
                              prefixIcon: Icon(Icons.link),
                            ),
                            keyboardType: TextInputType.url,
                            enabled: _selectedQrImageFile == null,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'OR',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildFileSelectionCard(
                            title: 'QR Code Image',
                            subtitle: _selectedQrImageFile != null
                                ? '✓ QR image selected'
                                : 'Upload pre-generated QR code image',
                            icon: Icons.qr_code_2,
                            isSelected: _selectedQrImageFile != null,
                            onTap: _pickQrImage,
                            color: Colors.purple,
                          ),
                          if (_selectedQrImageFile != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Colors.green, size: 16),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _selectedQrImageFile!.path
                                          .split('/')
                                          .last,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: () {
                                      setState(() {
                                        _selectedQrImageFile = null;
                                      });
                                    },
                                    color: Colors.red,
                                    tooltip: 'Remove QR image',
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _whatsappController,
                            decoration: const InputDecoration(
                              labelText: 'Preacher WhatsApp Number',
                              hintText: '+966501234567',
                              prefixIcon: Icon(Icons.phone),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Summary Card
                      Card(
                        color: Colors.green.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text('Summary',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade900,
                                  )),
                              const SizedBox(height: 12),
                              _buildSummaryItem(
                                  'Required',
                                  _selectedFlagFile != null &&
                                          _selectedAudioFile != null
                                      ? 2
                                      : 0,
                                  2),
                              _buildSummaryItem(
                                  'Sub-Audios', _subAudios.length, null),
                              _buildSummaryItem(
                                  'Books', _selectedBookFiles.length, null),
                              _buildSummaryItem('YouTube Videos',
                                  _youtubeVideoControllers.length, null),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Submit Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _addLanguage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Add Language with All Content',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color:
              isSelected ? color.withValues(alpha: 0.1) : Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey.shade600,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected ? color : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.add_circle_outline,
              color: isSelected ? color : Colors.grey.shade600,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem(
      File file, IconData icon, Color color, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          file.path.split('/').last,
          style: const TextStyle(fontSize: 14),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onRemove,
        ),
        tileColor: color.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        dense: true,
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count, int? required) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            required != null ? '$count / $required' : '$count',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: (required != null && count < required)
                  ? Colors.red
                  : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Internet Connection Required',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Adding new languages requires an internet connection to upload files to the server.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Check Connection'),
                  onPressed: _checkConnection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
