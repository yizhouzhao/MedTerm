// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

const _bottomNavigationBarItemIconPadding = EdgeInsets.only(top: 4.0);

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.restorationId,
    required this.child,
    required this.onTap,
  });

  final String? restorationId;
  final Widget child;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final index = _getSelectedIndex(GoRouterState.of(context).uri.toString());
    print('index: $index');
    return RestorationScope(
      restorationId: restorationId,
      child: CupertinoPageScaffold(
        child: Column(
          children: [
            Expanded(child: child),
            CupertinoTabBar(
              currentIndex: index,
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: _bottomNavigationBarItemIconPadding,
                    child: Icon(CupertinoIcons.doc),
                  ),
                  label: 'Study',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: _bottomNavigationBarItemIconPadding,
                    child: Icon(CupertinoIcons.book),
                  ),
                  label: 'Review',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: _bottomNavigationBarItemIconPadding,
                    child: Icon(CupertinoIcons.search),
                  ),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: _bottomNavigationBarItemIconPadding,
                    child: Icon(CupertinoIcons.settings),
                  ),
                  label: 'Settings',
                ),
              ],
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }

  int _getSelectedIndex(String location) {
    if (location.startsWith('/list')) return 0;
    if (location.startsWith('/favorites')) return 1;
    if (location.startsWith('/search')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }
}
