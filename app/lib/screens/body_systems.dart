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
import '../services/database.dart';
import '../widgets/word_line.dart';

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

  Widget _buildDetails(BuildContext context) {
    final themeData = CupertinoTheme.of(context);
    return Container(
      color: CupertinoColors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(bodySystem.name, style: Styles.cardTitleText(themeData)),
            const SizedBox(height: 8),
            Text(
              "A short description of the body system",
              style: Styles.cardDescriptionText(themeData),
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
        context.go('/list/${bodySystem.name}');
      },
      child: Stack(
        children: [
          Semantics(
            label: 'A card background featuring ${bodySystem.name}',
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue,
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

class BodySystemWordListScreen extends StatelessWidget {
  const BodySystemWordListScreen({super.key, required this.bodySystemName});

  final String bodySystemName;
  static final DatabaseService databaseService = DatabaseService();

  static Page<void> pageBuilder(BuildContext context, String bodySystemName) {
    return CupertinoPage(
      restorationId: 'router.systems.$bodySystemName',
      child: BodySystemWordListScreen(bodySystemName: bodySystemName),
      title: '$bodySystemName Word List',
    );
  }

  @override
  Widget build(BuildContext context) {
    var brightness = CupertinoTheme.brightnessOf(context);
    return RestorationScope(
      restorationId: bodySystemName,
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Words'),
          previousPageTitle: 'Home',
        ),
        backgroundColor: Styles.scaffoldBackground(brightness),
        child: SafeArea(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: databaseService.getUserWordsWithMemory(bodySystemName),
            builder: (context, snapshot) {
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;
              print('[BodySystemWordListScreen] isLoading: $isLoading');
              return (isLoading)
                  ? const CupertinoActivityIndicator()
                  : (ListView.builder(
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      return WordLine(word: snapshot.data?[index]['word'] ?? '', memoryLevel: snapshot.data?[index]['memory_level'] ?? 0);
                    },
                  ));
            },
          ),
        ),
      ),
    );
  }
}
