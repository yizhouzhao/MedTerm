// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/preferences.dart';
import '../styles.dart';

class CalorieSettingsScreen extends StatelessWidget {
  const CalorieSettingsScreen({super.key, this.restorationId});

  final String? restorationId;

  static const max = 1000;
  static const min = 2600;
  static const step = 200;

  static Page<void> pageBuilder(BuildContext context) {
    return const CupertinoPage<void>(
      restorationId: 'router.calorie',
      child: CalorieSettingsScreen(restorationId: 'calorie'),
      title: 'Calorie Target',
    );
  }

  @override
  Widget build(BuildContext context) {
    var brightness = CupertinoTheme.brightnessOf(context);
    return RestorationScope(
      restorationId: restorationId,
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          previousPageTitle: 'Settings',
        ),
        backgroundColor: Styles.scaffoldBackground(brightness),
        child: ListView(restorationId: 'list', children: [Text('Categories')]),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({this.restorationId, super.key});

  final String? restorationId;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  CupertinoListTile _buildCaloriesTile(
    BuildContext context,
    Preferences prefs,
  ) {
    return CupertinoListTile.notched(
      leading: const SettingsIcon(
        backgroundColor: CupertinoColors.systemBlue,
        icon: Styles.calorieIcon,
      ),
      title: const Text('Calorie Target'),
      additionalInfo: Text("1000"),
      trailing: const CupertinoListTileChevron(),
      onTap: () => context.go('/settings/calories'),
    );
  }

  CupertinoListTile _buildCategoriesTile(
    BuildContext context,
    Preferences prefs,
  ) {
    return CupertinoListTile.notched(
      leading: const SettingsIcon(
        backgroundColor: CupertinoColors.systemOrange,
        icon: Styles.preferenceIcon,
      ),
      title: const Text('Preferred Categories'),
      trailing: const CupertinoListTileChevron(),
      onTap: () => context.go('/settings/categories'),
    );
  }

  CupertinoListTile _buildRestoreDefaultsTile(
    BuildContext context,
    Preferences prefs,
  ) {
    return CupertinoListTile.notched(
      leading: const SettingsIcon(
        backgroundColor: CupertinoColors.systemRed,
        icon: Styles.resetIcon,
      ),
      title: const Text('Reset Database'),
      onTap: () {
        showCupertinoDialog<void>(
          context: context,
          builder:
              (context) => CupertinoAlertDialog(
                title: const Text('Are you sure?'),
                content: const Text(
                  'Are you sure you want to reset the current MedTerm database?',
                ),
                actions: [
                  CupertinoDialogAction(
                    isDestructiveAction: true,
                    child: const Text('Yes'),
                    onPressed: () async {
                      await prefs.restoreDefaults();
                      if (!context.mounted) return;
                      context.pop();
                    },
                  ),
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: const Text('No'),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
        );
      },
    );
  }

  CupertinoListTile _buildSyncDataTile(
    BuildContext context,
    Preferences prefs,
  ) {
    return CupertinoListTile.notched(
      leading: const SettingsIcon(
        backgroundColor: CupertinoColors.systemBlue,
        icon: CupertinoIcons.cloud_download,
      ),
      title: const Text('Sync Data'),
      onTap: () {
        showCupertinoDialog<void>(
          context: context,
          builder:
              (context) => CupertinoAlertDialog(
                title: const Text('Download Latest Lessons'),
                content: const Text(
                  'Download the latest lessons from the project website.',
                ),
                actions: [
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: const Text('Download'),
                    onPressed: () async {
                      // await prefs.syncData();
                      if (!context.mounted) return;
                      context.pop();
                    },
                  ),
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: const Text('No'),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<Preferences>(context);

    return CupertinoPageScaffold(
      backgroundColor: Styles.scaffoldBackground(
        CupertinoTheme.brightnessOf(context),
      ),
      child: CustomScrollView(
        slivers: <Widget>[
          const CupertinoSliverNavigationBar(largeTitle: Text('Settings')),
          SliverList(
            delegate: SliverChildListDelegate([
              // CupertinoListSection.insetGrouped(
              //   children: [
              //     _buildCaloriesTile(context, prefs),
              //     _buildCategoriesTile(context, prefs),
              //   ],
              // ),
              CupertinoListSection.insetGrouped(
                children: [
                  _buildRestoreDefaultsTile(context, prefs),
                  _buildSyncDataTile(context, prefs),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class SettingsIcon extends StatelessWidget {
  const SettingsIcon({
    required this.icon,
    this.foregroundColor = CupertinoColors.white,
    this.backgroundColor = CupertinoColors.black,
    super.key,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: backgroundColor,
      ),
      child: Center(child: Icon(icon, color: foregroundColor, size: 20)),
    );
  }
}
