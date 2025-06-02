import 'package:flutter/material.dart';

import '../models/language_model.dart';
import '../screens/audio_player_screen.dart';
import 'language_card.dart';

class LanguageGridViewItemWidget extends StatefulWidget {
  final int index;
  final AnimationController animationController;
  final List<Language> filteredLanguages;

  const LanguageGridViewItemWidget({
    super.key,
    required this.index,
    required this.animationController,
    required this.filteredLanguages,
  });

  @override
  State<LanguageGridViewItemWidget> createState() =>
      _LanguageGridViewItemWidgetState();
}

class _LanguageGridViewItemWidgetState
    extends State<LanguageGridViewItemWidget> {
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
        language: widget.filteredLanguages[widget.index],
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
            setState(() {});
          }
        },
      ),
    );
  }
}
