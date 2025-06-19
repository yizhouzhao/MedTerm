// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/sync_data.dart';

/// A model class that mirrors the options in [SettingsScreen] and stores data
/// in shared preferences.
class Preferences extends ChangeNotifier {
  // Keys to use with shared preferences.
  static const _lessonsKey = 'lessons';
  static const _wordListVersionKey = 'wordListVersion';
  static const _descriptionsKey = 'descriptions';
  // Indicates whether a call to [_loadFromSharedPrefs] is in progress;
  Future<void>? _loading;

  String _wordListVersion = '0.0.0';
  final Set<int> _lessons = <int>{};
  final Set<String> _descriptions = <String>{};

  Future<List<String>> get descriptions async {
    await _loading;
    return _descriptions.toList();
  }

  Future<String> get wordListVersion async {
    await _loading;
    return _wordListVersion;
  }

  Future<List<int>> get lessons async {
    await _loading;
    return _lessons.toList();
  }

  Future<void> restoreDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    SyncData.resetDatabase();
    load();
  }

  void load() {
    print('[Preferences] load');
    _loading = _loadFromSharedPrefs();
  }

  Future<void> _saveToSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_wordListVersionKey, _wordListVersion);

    // Store preferred categories as a comma-separated string containing their
    // indices.
    await prefs.setString(
      _lessonsKey,
      _lessons.map((c) => c.toString()).join(','),
    );
  }

  Future<void> _loadFromSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _lessons.clear();
    final systems = prefs.getString(_lessonsKey);

    if (systems != null && systems.isNotEmpty) {
      for (final name in systems.split(',')) {
        final index = int.tryParse(name) ?? -1;
        _lessons.add(index);
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
    //if (wordListOnlineVersion != _wordListVersion) {
    _wordListVersion = wordListOnlineVersion;
    final lessons = await SyncData.getOnlineLessons();
    print('[Preferences] lessons: $lessons');

    for (final lesson in lessons) {
      print('[Preferences] lesson: $lesson');
      _lessons.add(lesson);
      final description = await SyncData.getOnlineDescription(lesson);
      _descriptions.add(description);
      SyncData.downloadWordList(lesson);
    }
    await _saveToSharedPrefs();
    //}

    notifyListeners();
  }
}
