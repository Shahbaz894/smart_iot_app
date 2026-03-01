import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';



final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        //builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        //builder: (context, state) => const LoginScreen(),
      ),
      // Dashboard with parameters
      // GoRoute(
      //   path: '/dashboard/:deviceId',
      //   builder: (context, state) {
      //     final id = state.pathParameters['deviceId']!;
      //     //return DashboardScreen(deviceId: id);
      //   },
      // ),
    ],
  );
});