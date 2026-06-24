import 'package:flutter/material.dart';

import '../models/language_model.dart';
import '../screens/audio_player_screen.dart';
import '../services/language_service.dart';
import 'language_card.dart';

class LanguageGridViewItemWidget extends StatefulWidget {
  final int index;
  final AnimationController animationController;
  final List<Language> filteredLanguages;
  final LanguageService languageService;
  final bool isAdminMode;
  final VoidCallback? onLanguageDeleted;

  const LanguageGridViewItemWidget({
    super.key,
    required this.index,
    required this.animationController,
    required this.filteredLanguages,
    required this.languageService,
    this.isAdminMode = false,
    this.onLanguageDeleted,
  });

  @override
  State<LanguageGridViewItemWidget> createState() =>
      _LanguageGridViewItemWidgetState();
}

class _LanguageGridViewItemWidgetState
    extends State<LanguageGridViewItemWidget> {
  int _refreshKey = 0;

  Future<void> _deleteLanguage() async {
    final language = widget.filteredLanguages[widget.index];

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Language'),
        content: Text(
          'Are you sure you want to delete "${language.name}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await widget.languageService.deleteLanguage(language.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${language.name}" deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onLanguageDeleted?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting language: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editLanguage() async {
    // TODO: Navigate to edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit functionality coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        final delay = (widget.index * 0.1).clamp(0.0, 0.5);
        final slideAnimation = Tween<Offset>(
          begin: Offset(0, 0.1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: widget.animationController,
            curve: Interval(
              delay,
              (delay + 0.5).clamp(0.0, 1.0),
              curve: Curves.easeOutQuart,
            ),
          ),
        );
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: widget.animationController,
              curve: Interval(
                delay,
                (delay + 0.5).clamp(0.0, 1.0),
                curve: Curves.easeOut,
              ),
            ),
          ),
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
      child: LanguageCard(
        key: ValueKey(
            '${widget.filteredLanguages[widget.index].id}_$_refreshKey'),
        language: widget.filteredLanguages[widget.index],
        languageService: widget.languageService,
        isAdminMode: widget.isAdminMode,
        onEdit: widget.isAdminMode ? _editLanguage : null,
        onDelete: widget.isAdminMode ? _deleteLanguage : null,
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AudioPlayerScreen(
                language: widget.filteredLanguages[widget.index],
              ),
            ),
          );
          // Trigger a rebuild to refresh cache status
          if (mounted) {
            setState(() {
              _refreshKey++; // Change the key to force LanguageCard to rebuild
            });
          }
        },
      ),
    );
  }
}
