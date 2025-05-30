import 'package:flutter/material.dart';

import '../models/language_model.dart';
import 'language_gird_view_item_widget.dart';

class LanguagesGridViewWidget extends StatelessWidget {
  const LanguagesGridViewWidget({
    super.key,
    required this.filteredLanguages,
    required this.searchController,
    required AnimationController animationController,
  }) : _animationController = animationController;

  final List<Language> filteredLanguages;
  final TextEditingController searchController;
  final AnimationController _animationController;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: filteredLanguages.isEmpty
          ? Center(
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
            )
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
                );
              },
            ),
    );
  }
}
