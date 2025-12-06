import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srumec_app/auth/providers/auth_provider.dart';
import 'package:srumec_app/auth/screens/login_screen.dart';
import 'package:srumec_app/comments/data/datasources/comments_remote_data_source.dart';
import 'package:srumec_app/comments/data/repositories/comments_repository.dart';
import 'package:srumec_app/comments/providers/comments_provider.dart';
import 'package:srumec_app/core/network/dio_client.dart';
import 'package:srumec_app/core/providers/locator/location_provider.dart';
import 'package:srumec_app/events/data/datasources/events_remote_data_source.dart';
import 'package:srumec_app/events/data/repositories/event_repository.dart';
import 'package:srumec_app/screens/main_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        // 1. AuthProvider (drží stav přihlášení)
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // 2. DioClient (potřebuje AuthProvider, aby mohl dělat logout)
        ProxyProvider<AuthProvider, DioClient>(
          update: (_, authProvider, __) => DioClient(authProvider),
        ),

        // 3. DataSource (potřebuje Dio z DioClienta)
        ProxyProvider<DioClient, EventsRemoteDataSource>(
          update: (_, dioClient, __) => EventsRemoteDataSource(dioClient.dio),
        ),

        // 4. Repository (potřebuje DataSource)
        ProxyProvider<EventsRemoteDataSource, EventsRepository>(
          update: (_, dataSource, __) => EventsRepository(dataSource),
        ),

        // 1. Comments DataSource
        ProxyProvider<DioClient, CommentsRemoteDataSource>(
          update: (_, dioClient, __) => CommentsRemoteDataSource(dioClient.dio),
        ),

        // 2. Comments Repository
        ProxyProvider<CommentsRemoteDataSource, CommentsRepository>(
          update: (_, dataSource, __) => CommentsRepository(dataSource),
        ),

        // 3. Comments Provider
        ChangeNotifierProxyProvider<CommentsRepository, CommentsProvider>(
          create: (context) =>
              CommentsProvider(context.read<CommentsRepository>()),
          update: (_, repo, previous) => CommentsProvider(repo),
        ),
      ],
      child: const SrumecApp(),
    ),
  );
}

class SrumecApp extends StatelessWidget {
  const SrumecApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Šrumec',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,

      // ZMĚNA: Tady nesmí být LoginScreen, ale náš rozhodovací Wrapper
      home: const AuthWrapper(),
    );
  }
}

/// Rozcestník: Rozhoduje, zda zobrazit Loading, Login nebo Hlavní aplikaci
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Po vykreslení widgetu spustíme kontrolu tokenu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkLoginStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // DEBUG VÝPIS
    // print("AuthWrapper Build: isLoading=${authProvider.isLoading}, isAuth=${authProvider.isAuthenticated}");

    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authProvider.isAuthenticated) {
      return const MainScreen();
    }

    return const LoginScreen();
  }
}
