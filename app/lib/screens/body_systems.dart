// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../data/preferences.dart';
import '../styles.dart';
import '../models/word.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({this.restorationId, super.key});

  final String? restorationId;

  Widget _generateBodySystemCard(BodySystem bodySystem) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: BodySystemCard(bodySystem),
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
            child: FutureBuilder<List<BodySystem>>(
              future: prefs.bodySystems,
              builder: (context, snapshot) {
                final data = snapshot.data ?? <BodySystem>[];
                return ListView.builder(
                  restorationId: 'list',
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return _generateBodySystemCard(data[index]);
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

class BodySystemCard extends StatelessWidget {
  const BodySystemCard(this.bodySystem, {super.key});

  /// Veggie to be displayed by the card.
  final BodySystem bodySystem;

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
            Text(
              bodySystem.name[0].toUpperCase() + bodySystem.name.substring(1),
              style: Styles.cardTitleText(themeData),
            ),
            const SizedBox(height: 8),
            // Text(
            //   "A short description of the body system",
            //   style: Styles.cardDescriptionText(themeData),
            // ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PressableCard(
      onPressed: () {
        context.go('/list/${bodySystem.name}');
      },
      child: Stack(
        children: [
          Semantics(
            label: 'A card background featuring ${bodySystem.name}',
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: _generateColorFromName(bodySystem.name),
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
