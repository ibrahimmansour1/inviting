import 'package:flutter/material.dart';

import '../models/language_model.dart';
import '../services/language_service.dart';
import '../widgets/languages_grid_view_widget.dart';
import 'add_language_screen.dart';
import 'settings_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with SingleTickerProviderStateMixin {
  List<Language> allLanguages = [];
  List<Language> filteredLanguages = [];
  final TextEditingController searchController = TextEditingController();
  bool isSearchEmpty = true;
  bool isLoading = true;
  bool isOnline = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final LanguageService _languageService = LanguageService();

  @override
  void initState() {
    super.initState();
    searchController.addListener(_filterLanguages);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    setState(() {
      isLoading = true;
    });

    try {
      final languages = await _languageService.getAllLanguages();
      final online = _languageService.isOnline;

      setState(() {
        allLanguages = languages;
        filteredLanguages = List.from(languages);
        isOnline = online;
        isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
        // Try to use cached languages if available
        allLanguages = _languageService.getCachedLanguages();
        filteredLanguages = List.from(allLanguages);
        isOnline = false;
      });

      if (mounted) {
        String errorMessage = 'Unable to load languages from server';
        if (allLanguages.isEmpty) {
          errorMessage +=
              '. Please check your internet connection and try again.';
        } else {
          errorMessage += '. Showing cached languages.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: allLanguages.isEmpty ? Colors.red : Colors.orange,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadLanguages,
            ),
          ),
        );
      }

      _animationController.forward();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _filterLanguages() {
    final query = searchController.text.toLowerCase();
    setState(() {
      isSearchEmpty = query.isEmpty;
      if (isSearchEmpty) {
        filteredLanguages = List.from(allLanguages);
      } else {
        filteredLanguages = allLanguages
            .where((language) =>
                language.name.toLowerCase().contains(query) ||
                language.nativeName.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _navigateToAddLanguage() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddLanguageScreen(),
      ),
    );

    // If a language was added successfully, refresh the list
    if (result == true) {
      _loadLanguages();
    }
  }

  Animation<double> get _fadeAnimation =>
      Tween<double>(begin: 0, end: 1).animate(_animation);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Language'),
        elevation: 0,
        actions: [
          if (isOnline)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Language',
              onPressed: _navigateToAddLanguage,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadLanguages,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading languages...'),
                  ],
                ),
              )
            : FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Connection status indicator
                    if (!isOnline && allLanguages.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        color: Colors.orange.shade100,
                        child: Row(
                          children: [
                            Icon(
                              Icons.cloud_off,
                              size: 16,
                              color: Colors.orange.shade800,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Offline - Showing cached languages',
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: 'Search languages',
                          hintText: 'Type in English or native language',
                          prefixIcon:
                              Icon(Icons.search, color: Colors.green.shade600),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear,
                                      color: Colors.grey.shade600),
                                  onPressed: () {
                                    searchController.clear();
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Found ${filteredLanguages.length} languages',
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (!isSearchEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                border:
                                    Border.all(color: Colors.green.shade300),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.search,
                                      size: 16, color: Colors.green),
                                  const SizedBox(width: 4),
                                  Text(
                                    '"${searchController.text}"',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    LanguagesGridViewWidget(
                      filteredLanguages: filteredLanguages,
                      allLanguages: allLanguages,
                      isOnline: isOnline,
                      onRetryLoad: _loadLanguages,
                      searchController: searchController,
                      animationController: _animationController,
                      languageService: _languageService,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
