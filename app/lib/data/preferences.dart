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
  static const _autoReadKey = 'autoRead';
  static const _showTranslationKey = 'showTranslation';
  static const _translationTypeKey = 'translationType';
  // Indicates whether a call to [_loadFromSharedPrefs] is in progress;
  Future<void>? _loading;

  String _wordListVersion = '0.0.0';
  final Set<int> _lessons = <int>{};
  final Set<String> _descriptions = <String>{};
  bool _autoRead = false;
  bool _showTranslation = true;
  String _translationType = 'simplified';

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

  bool? get autoRead => _autoRead;

  Future<void> setAutoRead(bool value) async {
    _autoRead = value;
    await _saveToSharedPrefs();
    notifyListeners();
  }

  bool? get showTranslation => _showTranslation;

  Future<void> setShowTranslation(bool value) async {
    _showTranslation = value;
    await _saveToSharedPrefs();
    notifyListeners();
  }

  String get translationType => _translationType;

  Future<void> setTranslationType(String value) async {
    _translationType = value;
    await _saveToSharedPrefs();
    notifyListeners();
  }

  Future<void> restoreDefaults() async {
    // print('[Preferences] restoreDefaults...');
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _lessons.clear();
    _descriptions.clear();
    _wordListVersion = '0.0.0';
    _autoRead = false;
    _showTranslation = true;
    _translationType = 'simplified';
    await _saveToSharedPrefs();
    await SyncData.resetDatabase();
    load(forceDownload: true);
  }

  void load({bool forceDownload = false}) {
    // print('[Preferences] load');
    _loading = _loadFromSharedPrefs(forceDownload: forceDownload);
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
    await prefs.setString(
      _descriptionsKey,
      _descriptions.map((c) => c.toString()).join(','),
    );
    await prefs.setBool(_autoReadKey, _autoRead);
    await prefs.setBool(_showTranslationKey, _showTranslation);
    await prefs.setString(_translationTypeKey, _translationType);
  }

  Future<void> _loadFromSharedPrefs({bool forceDownload = false}) async {
    final prefs = await SharedPreferences.getInstance();
    _lessons.clear();
    _descriptions.clear();
    final lessons = prefs.getString(_lessonsKey);
    final descriptions = prefs.getString(_descriptionsKey);
    // print('[Preferences] local lessons: $lessons');
    // print('[Preferences] local descriptions: $descriptions');

    if (lessons != null && lessons.isNotEmpty) {
      for (final name in lessons.split(',')) {
        final index = int.tryParse(name) ?? -1;
        _lessons.add(index);
      }
    }
    if (descriptions != null && descriptions.isNotEmpty) {
      for (final name in descriptions.split(',')) {
        _descriptions.add(name);
      }
    }
    _wordListVersion = prefs.getString(_wordListVersionKey) ?? '0.0.0';
    _autoRead = prefs.getBool(_autoReadKey) ?? false;
    _showTranslation = prefs.getBool(_showTranslationKey) ?? false;
    _translationType = prefs.getString(_translationTypeKey) ?? 'simplified';

    // local wordListOnlineVersion
    final wordListOnlineVersion = await SyncData.getOnlineWordListVersion();
    // print('[Preferences] wordListOnlineVersion: $wordListOnlineVersion');

    if (wordListOnlineVersion != _wordListVersion || forceDownload) {
      _wordListVersion = wordListOnlineVersion;
      final onlineLessons = await SyncData.getOnlineLessons();
      // print('[Preferences] lessons: $onlineLessons');

      for (final lesson in onlineLessons) {
        _lessons.add(lesson);
        final description = await SyncData.getOnlineDescription(lesson);
        _descriptions.add(description);
        SyncData.downloadWordList(lesson);
      }
      await _saveToSharedPrefs();
    }

    // print('[Preferences] _lessons: $_lessons');
    // print('[Preferences] _descriptions: $_descriptions');

    notifyListeners();
  }
}
