import 'package:flutter/material.dart';

import '../models/language_model.dart';
import '../widgets/languages_grid_view_widget.dart';
import 'settings_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with SingleTickerProviderStateMixin {
  List<Language> filteredLanguages = List.from(languages);
  final TextEditingController searchController = TextEditingController();
  bool isSearchEmpty = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

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

    _animationController.forward();
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
        filteredLanguages = List.from(languages);
      } else {
        filteredLanguages = languages
            .where((language) =>
                language.name.toLowerCase().contains(query) ||
                language.nativeName.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Animation<double> get _fadeAnimation =>
      Tween<double>(begin: 0, end: 1).animate(_animation);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Your Language'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
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
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
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
                            icon:
                                Icon(Icons.clear, color: Colors.grey.shade600),
                            onPressed: () {
                              searchController.clear();
                            },
                          )
                        : null,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    Spacer(),
                    if (!isSearchEmpty)
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          border: Border.all(color: Colors.green.shade300),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search, size: 16, color: Colors.green),
                            SizedBox(width: 4),
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
                  searchController: searchController,
                  animationController: _animationController),
            ],
          ),
        ),
      ),
    );
  }
}
