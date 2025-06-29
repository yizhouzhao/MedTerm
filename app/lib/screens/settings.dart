// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
      subtitle: const Text('Clear all the data in the MedTerm database'),
      onTap: () {
        showCupertinoDialog<void>(
          context: context,
          builder:
              (context) => CupertinoAlertDialog(
                title: const Text('Are you sure?'),
                content: const Text(
                  'Are you sure you want to reset the current MedTerm database? This action cannot be undone.',
                ),
                actions: [
                  CupertinoDialogAction(
                    isDestructiveAction: true,
                    child: const Text('Yes'),
                    onPressed: () async {
                      late bool success;
                      try {
                        await prefs.restoreDefaults();
                        success = true;
                      } catch (e) {
                        // print('[SettingsScreen] Error restoring defaults: $e');
                        success = false;
                      }
                      if (!context.mounted) return;
                      context.pop();
                      // Show success notification
                      showCupertinoDialog<void>(
                        context: context,
                        builder:
                            (context) => CupertinoAlertDialog(
                              title: const Text('Database Reset'),
                              content: Text(
                                success
                                    ? 'The database has been successfully reset.'
                                    : 'Failed to reset the database.',
                              ),
                              actions: [
                                CupertinoDialogAction(
                                  isDefaultAction: true,
                                  child: const Text('OK'),
                                  onPressed: () => context.pop(),
                                ),
                              ],
                            ),
                      );
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
      subtitle: const Text('Download the latest lessons'),
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
                    onPressed: () {
                      late bool success;
                      try {
                        prefs.load(forceDownload: true);
                        success = true;
                      } catch (e) {
                        // print('[SettingsScreen] Error downloading lessons: $e');
                        success = false;
                      }
                      if (!context.mounted) return;
                      context.pop();
                      showCupertinoDialog<void>(
                        context: context,
                        builder:
                            (context) => CupertinoAlertDialog(
                              title: const Text('Sync Data'),
                              content: Text(
                                success
                                    ? 'The database has been successfully downloaded.'
                                    : 'Failed to download the latest lessons.',
                              ),
                              actions: [
                                CupertinoDialogAction(
                                  isDefaultAction: true,
                                  child: const Text('OK'),
                                  onPressed: () => context.pop(),
                                ),
                              ],
                            ),
                      );
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

  CupertinoListTile _buildAutoReadTile(
    BuildContext context,
    Preferences prefs,
  ) {
    return CupertinoListTile.notched(
      leading: const SettingsIcon(
        backgroundColor: CupertinoColors.systemGreen,
        icon: CupertinoIcons.speaker_2,
      ),
      title: const Text('Auto-Read'),
      subtitle: const Text('Automatically read words aloud'),
      trailing: CupertinoSwitch(
        value: prefs.autoRead ?? false,
        onChanged: (value) {
          prefs.setAutoRead(value);
        },
      ),
    );
  }

  CupertinoListTile _buildShowTranslationTile(
    BuildContext context,
    Preferences prefs,
  ) {
    return CupertinoListTile.notched(
      leading: const SettingsIcon(
        backgroundColor: CupertinoColors.systemOrange,
        icon: CupertinoIcons.text_bubble,
      ),
      title: const Text('Show Translation'),
      subtitle: const Text('Display Chinese translations'),
      trailing: CupertinoSwitch(
        value: prefs.showTranslation ?? false,
        onChanged: (value) {
          prefs.setShowTranslation(value);
        },
      ),
    );
  }

  CupertinoListTile _buildTranslationTypeTile(
    BuildContext context,
    Preferences prefs,
  ) {
    return CupertinoListTile.notched(
      leading: const SettingsIcon(
        backgroundColor: CupertinoColors.systemPurple,
        icon: CupertinoIcons.textformat_abc,
      ),
      title: const Text('Set Translation Type'),
      subtitle: Text(
        prefs.translationType == 'traditional'
            ? 'Traditional Chinese'
            : 'Simplified Chinese',
      ),
      onTap: () {
        showCupertinoModalPopup<void>(
          context: context,
          builder:
              (context) => CupertinoActionSheet(
                title: const Text('Select Translation Type'),
                actions: [
                  CupertinoActionSheetAction(
                    onPressed: () {
                      prefs.setTranslationType('simplified');
                      Navigator.pop(context);
                    },
                    child: const Text('Simplified Chinese'),
                  ),
                  CupertinoActionSheetAction(
                    onPressed: () {
                      prefs.setTranslationType('traditional');
                      Navigator.pop(context);
                    },
                    child: const Text('Traditional Chinese'),
                  ),
                ],
                cancelButton: CupertinoActionSheetAction(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
        );
      },
    );
  }

  CupertinoListTile _buildProjectPageTile(BuildContext context) {
    return CupertinoListTile.notched(
      leading: const SettingsIcon(
        backgroundColor: CupertinoColors.systemIndigo,
        icon: CupertinoIcons.globe,
      ),
      title: const Text('Visit Project Page'),
      subtitle: const Text('Visit MedTerm project website'),
      onTap: () async {
        final Uri url = Uri.parse(
          'https://yizhouzhao.github.io/portfolio/medterm/',
        );
        try {
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            if (!context.mounted) return;
            showCupertinoDialog<void>(
              context: context,
              builder:
                  (context) => CupertinoAlertDialog(
                    title: const Text('Error'),
                    content: const Text('Could not open the project page.'),
                    actions: [
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        child: const Text('OK'),
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
            );
          }
        } catch (e) {
          if (!context.mounted) return;
          showCupertinoDialog<void>(
            context: context,
            builder:
                (context) => CupertinoAlertDialog(
                  title: const Text('Error'),
                  content: const Text('Failed to open the project page.'),
                  actions: [
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      child: const Text('OK'),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
          );
        }
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
                  _buildAutoReadTile(context, prefs),
                  _buildShowTranslationTile(context, prefs),
                  _buildTranslationTypeTile(context, prefs),
                ],
              ),
              CupertinoListSection.insetGrouped(
                children: [
                  _buildSyncDataTile(context, prefs),
                  _buildRestoreDefaultsTile(context, prefs),
                ],
              ),

              CupertinoListSection.insetGrouped(
                children: [_buildProjectPageTile(context)],
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
