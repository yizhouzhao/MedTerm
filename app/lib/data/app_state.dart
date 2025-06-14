// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'local_veggie_provider.dart';
import 'veggie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  final List<Veggie> _veggies;

  AppState() : _veggies = LocalVeggieProvider.veggies;

  List<Veggie> get allVeggies => List<Veggie>.from(_veggies);

  List<Veggie> get availableVeggies {
    var currentSeason = _getSeasonForDate(DateTime.now());
    return _veggies.where((v) => v.seasons.contains(currentSeason)).toList();
  }

  List<Veggie> get favoriteVeggies =>
      _veggies.where((v) => v.isFavorite).toList();

  List<Veggie> get unavailableVeggies {
    var currentSeason = _getSeasonForDate(DateTime.now());
    return _veggies.where((v) => !v.seasons.contains(currentSeason)).toList();
  }

  Veggie getVeggie(int? id) => _veggies.singleWhere((v) => v.id == id);

  List<Veggie> searchVeggies(String? terms) =>
      _veggies
          .where((v) => v.name.toLowerCase().contains(terms!.toLowerCase()))
          .toList();

  void setFavorite(int? id, bool isFavorite) {
    var veggie = getVeggie(id);
    veggie.isFavorite = isFavorite;
    notifyListeners();
  }

  /// Used in tests to set the season independent of the current date.
  static Season? debugCurrentSeason;

  static Season? _getSeasonForDate(DateTime date) {
    if (debugCurrentSeason != null) {
      return debugCurrentSeason;
    }
    return Season.winter;
  }


}
