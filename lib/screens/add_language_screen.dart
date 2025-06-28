import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../services/language_service.dart';

class AddLanguageScreen extends StatefulWidget {
  const AddLanguageScreen({super.key});

  @override
  State<AddLanguageScreen> createState() => _AddLanguageScreenState();
}

class _AddLanguageScreenState extends State<AddLanguageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nativeNameController = TextEditingController();
  final LanguageService _languageService = LanguageService();
  
  File? _selectedFlagFile;
  File? _selectedAudioFile;
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
    super.dispose();
  }

  Future<void> _checkConnection() async {
    final isOnline = await _languageService.checkServerConnection();
    setState(() {
      _isOnline = isOnline;
    });
  }

  Future<void> _pickFlagImage() async {
    // For demo purposes, we'll create a placeholder file
    // In a real app, you'd use image_picker package
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/temp_flag.png');
      
      // Create a placeholder file (in real app, this would be from image picker)
      await file.writeAsBytes([]);
      
      setState(() {
        _selectedFlagFile = file;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Flag image selected (placeholder)'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting flag: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickAudioFile() async {
    // For demo purposes, we'll create a placeholder file
    // In a real app, you'd use file_picker package
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/temp_audio.m4a');
      
      // Create a placeholder file (in real app, this would be from file picker)
      await file.writeAsBytes([]);
      
      setState(() {
        _selectedAudioFile = file;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio file selected (placeholder)'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting audio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      await _languageService.addLanguage(
        name: _nameController.text.trim(),
        nativeName: _nativeNameController.text.trim(),
        flagFile: _selectedFlagFile!,
        audioFile: _selectedAudioFile!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Language added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
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
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Language Details',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.green.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Language Name (English)',
                                  hintText: 'e.g., German, Portuguese',
                                  border: OutlineInputBorder(),
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
                                  border: OutlineInputBorder(),
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
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Files',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.green.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildFileSelectionCard(
                                title: 'Flag Image',
                                subtitle: _selectedFlagFile != null
                                    ? 'Flag selected'
                                    : 'No flag selected',
                                icon: Icons.flag,
                                isSelected: _selectedFlagFile != null,
                                onTap: _pickFlagImage,
                              ),
                              const SizedBox(height: 12),
                              _buildFileSelectionCard(
                                title: 'Audio File',
                                subtitle: _selectedAudioFile != null
                                    ? 'Audio selected'
                                    : 'No audio selected',
                                icon: Icons.audiotrack,
                                isSelected: _selectedAudioFile != null,
                                onTap: _pickAudioFile,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _addLanguage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Add Language',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
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

  Widget _buildFileSelectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.green.shade50 : Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.green : Colors.grey.shade600,
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
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.green.shade800 : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.green.shade600 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.add_circle_outline,
              color: isSelected ? Colors.green : Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }
}
