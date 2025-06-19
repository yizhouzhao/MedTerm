// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../data/preferences.dart';
import '../styles.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({this.restorationId, super.key});

  final String? restorationId;

  Widget _generateLessonCard(int lesson) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LessonCard(lesson),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      restorationScopeId: restorationId,
      builder: (context) {
        final prefs = Provider.of<Preferences>(context);
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarBrightness: MediaQuery.platformBrightnessOf(context),
          ),
          child: SafeArea(
            bottom: false,
            child: FutureBuilder<List<int>>(
              future: prefs.lessons,
              builder: (context, snapshot) {
                final data = snapshot.data ?? <int>[];
                return ListView.builder(
                  restorationId: 'list',
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return _generateLessonCard(data[index]);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// A Card-like Widget that responds to tap events by animating changes to its
/// elevation and invoking an optional [onPressed] callback.
class PressableCard extends StatelessWidget {
  const PressableCard({
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.onPressed,
    super.key,
  });

  final VoidCallback? onPressed;

  final Widget child;

  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(borderRadius: borderRadius),
        child: ClipRRect(borderRadius: borderRadius, child: child),
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  const LessonCard(this.lesson, {super.key});

  /// Veggie to be displayed by the card.
  final int lesson;

  Color _generateColorFromName(String name) {
    // Create a hash from the name to generate consistent colors
    int hash = name.hashCode;

    // Use the hash to generate RGB values
    int r = (hash & 0xFF0000) >> 16;
    int g = (hash & 0x00FF00) >> 8;
    int b = hash & 0x0000FF;

    // Ensure minimum brightness for readability
    if (r + g + b < 300) {
      r = (r + 100).clamp(0, 255);
      g = (g + 100).clamp(0, 255);
      b = (b + 100).clamp(0, 255);
    }

    return Color.fromARGB(200, r, g, b);
  }

  Widget _buildDetails(BuildContext context) {
    final themeData = CupertinoTheme.of(context);
    return Container(
      color: CupertinoColors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Lesson $lesson", style: Styles.cardTitleText(themeData)),
            const SizedBox(height: 8),
            Consumer<Preferences>(
              builder: (context, prefs, child) {
                return FutureBuilder<List<String>>(
                  future: prefs.descriptions,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data!.length > lesson - 1) {
                      return Text(
                        snapshot.data![lesson - 1],
                        style: Styles.cardDescriptionText(themeData),
                      );
                    }
                    return Text(
                      'Loading...',
                      style: Styles.cardDescriptionText(themeData),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PressableCard(
      onPressed: () {
        context.go('/list/$lesson');
      },
      child: Stack(
        children: [
          Semantics(
            label: 'A card background featuring lesson $lesson',
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: _generateColorFromName("lesson $lesson"),
                // image: DecorationImage(
                //   fit: BoxFit.cover,
                //   colorFilter: Styles.desaturatedColorFilter,
                //   image: AssetImage(veggie.imageAssetPath),
                // ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildDetails(context),
          ),
        ],
      ),
    );
  }
}
