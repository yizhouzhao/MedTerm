// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/sync_data.dart';
import '../models/word.dart';

/// A model class that mirrors the options in [SettingsScreen] and stores data
/// in shared preferences.
class Preferences extends ChangeNotifier {
  // Keys to use with shared preferences.
  static const _bodySystemsKey = 'bodySystems';
  static const _wordListVersionKey = 'wordListVersion';
  // Indicates whether a call to [_loadFromSharedPrefs] is in progress;
  Future<void>? _loading;

  String _wordListVersion = '0.0.0';
  final Set<BodySystem> _bodySystems = <BodySystem>{};

  Future<String> get wordListVersion async {
    await _loading;
    return _wordListVersion;
  }

  Future<List<BodySystem>> get bodySystems async {
    await _loading;
    return _bodySystems.toList();
  }

  Future<void> restoreDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    SyncData.resetDatabase();
    load();
  }

  void load() {
    _loading = _loadFromSharedPrefs();
  }

  Future<void> _saveToSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_wordListVersionKey, _wordListVersion);

    // Store preferred categories as a comma-separated string containing their
    // indices.
    await prefs.setString(
      _bodySystemsKey,
      _bodySystems.map((c) => c.index.toString()).join(','),
    );
  }

  Future<void> _loadFromSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _bodySystems.clear();
    final systems = prefs.getString(_bodySystemsKey);

    if (systems != null && systems.isNotEmpty) {
      for (final name in systems.split(',')) {
        final index = int.tryParse(name) ?? -1;
        _bodySystems.add(BodySystem.values[index]);
      }
    }
    _wordListVersion = prefs.getString(_wordListVersionKey) ?? '0.0.0';

    // local wordListOnlineVersion
    final wordListOnlineVersion = await SyncData.getOnlineWordListVersion();
    print('[Preferences] wordListOnlineVersion: $wordListOnlineVersion');

    //FIXME: this is a hack to force the word list to be downloaded
    //TODO: remove this after the word list is downloaded
    //TODO: add a loading indicator
    //FIXME: this is a hack to force the word list to be downloaded
    if (wordListOnlineVersion != _wordListVersion) {
      _wordListVersion = wordListOnlineVersion;
      final categories = await SyncData.getOnlineCategories();
      print('[Preferences] categories: $categories');

      for (final category in categories) {
        print('[Preferences] category: $category');
        final bodySystem = BodySystem.values.firstWhere(
          (e) => e.name == category,
          orElse: () => BodySystem.general,
        );
        _bodySystems.add(bodySystem);
        SyncData.downloadWordList(bodySystem);
      }
      await _saveToSharedPrefs();
    }

    notifyListeners();
  }
}
