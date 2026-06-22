import 'package:flutter/material.dart';

import '../models/language_model.dart';
import '../services/language_service.dart';
import 'language_gird_view_item_widget.dart';

class LanguagesGridViewWidget extends StatelessWidget {
  const LanguagesGridViewWidget({
    super.key,
    required this.filteredLanguages,
    required this.searchController,
    required AnimationController animationController,
    required this.languageService,
    required this.allLanguages,
    required this.isOnline,
    required this.onRetryLoad,
  }) : _animationController = animationController;

  final List<Language> filteredLanguages;
  final List<Language> allLanguages;
  final bool isOnline;
  final VoidCallback onRetryLoad;
  final TextEditingController searchController;
  final AnimationController _animationController;
  final LanguageService languageService;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: filteredLanguages.isEmpty
          ? _buildEmptyState(context)
          : GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: filteredLanguages.length,
              itemBuilder: (context, index) {
                return LanguageGridViewItemWidget(
                  index: index,
                  animationController: _animationController,
                  filteredLanguages: filteredLanguages,
                  languageService: languageService,
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    // If no languages at all were loaded
    if (allLanguages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 80,
              color: Colors.red.shade300,
            ),
            SizedBox(height: 16),
            Text(
              'Unable to load languages',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please check your internet connection\nand try again.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
              onPressed: onRetryLoad,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green.shade600,
              ),
            ),
          ],
        ),
      );
    }

    // If search returned no results
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16),
          Text(
            'No languages found matching\n"${searchController.text}"',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            icon: Icon(Icons.clear),
            label: Text('Clear Search'),
            onPressed: () {
              searchController.clear();
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.green.shade800,
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
