import 'package:flutter/material.dart';

import '../models/language_model.dart';
import '../screens/audio_player_screen.dart';
import 'language_card.dart';

class LanguageGridViewItemWidget extends StatelessWidget {
  final int index;
  const LanguageGridViewItemWidget({
    super.key,
    required this.index,
    required AnimationController animationController,
    required this.filteredLanguages,
  }) : _animationController = animationController;

  final AnimationController _animationController;
  final List<Language> filteredLanguages;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final delay = (index * 0.1).clamp(0.0, 1.0);
        final slideAnimation = Tween<Offset>(
          begin: Offset(0, 0.1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              delay, // Start
              delay + 0.5, // End
              curve: Curves.easeOutQuart,
            ),
          ),
        );
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                delay, // Start
                delay + 0.5, // End
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
        language: filteredLanguages[index],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AudioPlayerScreen(
                language: filteredLanguages[index],
              ),
            ),
          );
        },
      ),
    );
  }
}
