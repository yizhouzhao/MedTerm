import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'data/app_state.dart';
import 'data/preferences.dart';
import 'screens/home.dart';
import 'styles.dart';
import 'widgets/med_term_page.dart';
import 'screens/body_systems.dart';
import 'screens/settings.dart';
import 'screens/word_detail.dart';
import 'screens/word_list.dart';
import 'screens/search.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    const RootRestorationScope(restorationId: 'root', child: MedTermApp()),
  );
}

class MedTermApp extends StatefulWidget {
  const MedTermApp({super.key});

  @override
  State<MedTermApp> createState() => _MedTermAppState();
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class _MedTermAppState extends State<MedTermApp> with RestorationMixin {
  final _RestorableAppState _appState = _RestorableAppState();

  @override
  String get restorationId => 'wrapper';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_appState, 'state');
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _appState.value),
        ChangeNotifierProvider(create: (_) => Preferences()..load()),
      ],
      child: CupertinoApp.router(
        theme: Styles.medThemeData,
        debugShowCheckedModeBanner: false,
        restorationScopeId: 'app',
        routerConfig: GoRouter(
          navigatorKey: _rootNavigatorKey,
          restorationScopeId: 'router',
          initialLocation: '/list',
          redirect: (context, state) {
            if (state.path == '/') {
              return '/list';
            }
            return null;
          },
          debugLogDiagnostics: true,
          routes: [
            ShellRoute(
              navigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state, child) {
                return CupertinoPage(
                  restorationId: 'router.shell',
                  child: HomeScreen(
                    restorationId: 'home',
                    child: child,
                    onTap: (index) {
                      if (index == 0) {
                        context.go('/list');
                      } else if (index == 1) {
                        context.go('/notebook');
                      } else if (index == 2) {
                        context.go('/search');
                      } else {
                        context.go('/settings');
                      }
                    },
                  ),
                );
              },
              routes: [
                GoRoute(
                  path: '/list',
                  pageBuilder: (context, state) {
                    return MedTermPage(
                      key: state.pageKey,
                      restorationId: 'route.list',
                      child: ListScreen(restorationId: 'list'),
                    );
                  },
                  routes: [
                    GoRoute(
                      path: ':name',
                      pageBuilder: (context, state) {
                        return WordListScreen.pageBuilder(
                          context,
                          state.pathParameters['name']!,
                        );
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: '/notebook',
                  pageBuilder: (context, state) {
                    return NotebookWordListScreen.pageBuilder(context);
                  },
                  //routes: [_buildDetailsRoute()],
                ),
                GoRoute(
                  path: '/search',
                  pageBuilder: (context, state) {
                    return MedTermPage(   
                      key: state.pageKey,
                      restorationId: 'route.search',
                      child: SearchScreen(restorationId: 'search'),
                    );
                  },
                  //routes: [_buildDetailsRoute()],
                ),
                GoRoute(
                  path: '/settings',
                  pageBuilder: (context, state) {
                    return MedTermPage(
                      key: state.pageKey,
                      restorationId: 'route.settings',
                      child: SettingsScreen(restorationId: 'settings'),
                    );
                  },
                  routes: [
                    GoRoute(
                      parentNavigatorKey: _rootNavigatorKey,
                      path: 'categories',
                      pageBuilder: (context, state) {
                        return CupertinoPage(
                          restorationId: 'route.settings.categories',
                          child: const Text('TODO Widget'),
                        );
                      },
                    ),
                    GoRoute(
                      parentNavigatorKey: _rootNavigatorKey,
                      path: 'calories',
                      pageBuilder: (context, state) {
                        return MedTermPage(
                          key: state.pageKey,
                          restorationId: 'route.settings.calories',
                          child: const Text('TODO Widget'),
                        );
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: '/word/:word',
                  pageBuilder: (context, state) {
                    return WordDetailScreen.pageBuilder(context, state.pathParameters['word']!);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RestorableAppState extends RestorableListenable<AppState> {
  @override
  AppState createDefaultValue() {
    return AppState();
  }

  @override
  AppState fromPrimitives(Object? data) {
    final appState = AppState();
    final favorites = (data as List<dynamic>).cast<int>();
    for (var id in favorites) {
      appState.setFavorite(id, true);
    }
    return appState;
  }

  @override
  Object toPrimitives() {
    return value.favoriteVeggies.map((veggie) => veggie.id).toList();
  }
}
