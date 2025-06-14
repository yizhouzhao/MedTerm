import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';


import 'styles.dart';
import 'data/app_state.dart';
import 'data/preferences.dart';
import 'widgets/med_term_page.dart';
import 'screens/home.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const RootRestorationScope(restorationId: 'root', child: MedTermApp()));
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

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
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
        theme: Styles.veggieThemeData,
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
                        context.go('/favorites');
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
                      child: Text('TODO Widget'),
                    );
                  },
                  routes: [_buildDetailsRoute()],
                ),
                GoRoute(
                  path: '/favorites',
                  pageBuilder: (context, state) {
                    return MedTermPage(
                      key: state.pageKey,
                      restorationId: 'route.favorites',
                      child: const Text('TODO Widget'),
                    );
                  },
                  routes: [_buildDetailsRoute()],
                ),
                GoRoute(
                  path: '/search',
                  pageBuilder: (context, state) {
                    return MedTermPage(
                      key: state.pageKey,
                      restorationId: 'route.search',
                      child: const Text('TODO Widget'),
                    );
                  },
                  routes: [_buildDetailsRoute()],
                ),
                GoRoute(
                  path: '/settings',
                  pageBuilder: (context, state) {
                    return MedTermPage(
                      key: state.pageKey,
                      restorationId: 'route.settings',
                      child: const Text('TODO Widget'),
                    );
                  },
                  routes: [
                    GoRoute(
                      parentNavigatorKey: _rootNavigatorKey,
                      path: 'categories',
                      pageBuilder: (context, state) {
                        return const CupertinoPage(child: Text('TODO Page'));
                      },
                    ),
                    GoRoute(
                      parentNavigatorKey: _rootNavigatorKey,
                      path: 'calories',
                      pageBuilder: (context, state) {
                        return CupertinoPage(child: Text('TODO Page'));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // GoRouter does not support relative routes,
  // see https://github.com/flutter/flutter/issues/108177
  GoRoute _buildDetailsRoute() {
    return GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: 'details/:id',
      pageBuilder: (context, state) {
        final veggieId = int.parse(state.pathParameters['id']!);
        return CupertinoPage(
          restorationId: 'route.details',
          child: const Text('TODO Widget'),
        );
      },
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
