// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import '../models/word.dart';

class AppState extends ChangeNotifier {
  List<MedWord> _medWords = [];

  AppState();

  void setMedWords(List<MedWord> medWords) {
    print('[setMedWords]: ${medWords.length}');
    _medWords = medWords;
    notifyListeners();
  }

  List<MedWord> getMedWords() {
    return _medWords;
  }

  int getMedWordsLength() {
    print('[getMedWordsLength]: ${_medWords.length}');
    return _medWords.length;
  }

  int getCurrentMedWordIndex(String word) {
    return _medWords.indexWhere((e) => e.word == word);
  }

  int getNextMedWordIndex(String word) {
    // loop around if the index is the last one
    int index = _medWords.indexWhere((e) => e.word == word);
    if (index == _medWords.length - 1) {
      return 0;
    }
    return index + 1;
  }
}
