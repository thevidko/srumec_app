import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srumec_app/auth/providers/auth_provider.dart';
import 'package:srumec_app/auth/screens/login_screen.dart';
import 'package:srumec_app/chat/data/datasources/chat_remote_data_source.dart';
import 'package:srumec_app/chat/data/repositories/chat_repository.dart';
import 'package:srumec_app/chat/providers/chat_provider.dart';
import 'package:srumec_app/core/services/web_socket_service.dart';
import 'package:srumec_app/comments/data/datasources/comments_remote_data_source.dart';
import 'package:srumec_app/comments/data/repositories/comments_repository.dart';
import 'package:srumec_app/comments/providers/comments_provider.dart';
import 'package:srumec_app/core/network/dio_client.dart';
import 'package:srumec_app/core/providers/locator/location_provider.dart';
import 'package:srumec_app/events/data/datasources/events_remote_data_source.dart';
import 'package:srumec_app/events/data/repositories/event_repository.dart';
import 'package:srumec_app/screens/main_screen.dart';
import 'package:srumec_app/users/data/datasources/users_remote_data_source.dart';
import 'package:srumec_app/users/data/repositories/users_repository.dart';
import 'package:srumec_app/users/providers/users_providers.dart';

void main() {
  runApp(
    // 1. VRSTVA: Infrastruktura (Data, Sítě, Repozitáře)
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // WebSocket Service
        Provider<WebSocketService>(create: (_) => WebSocketService()),
        ProxyProvider<AuthProvider, WebSocketService>(
          lazy: false,
          update: (_, auth, wsService) {
            if (wsService == null) return WebSocketService();
            if (auth.isAuthenticated && auth.token != null) {
              wsService.connect(auth.token!);
            } else {
              wsService.disconnect();
            }
            return wsService;
          },
        ),

        // Dio & DataSources
        ProxyProvider<AuthProvider, DioClient>(
          update: (_, auth, __) => DioClient(auth),
        ),
        ProxyProvider<DioClient, EventsRemoteDataSource>(
          update: (_, dio, __) => EventsRemoteDataSource(dio.dio),
        ),
        ProxyProvider<DioClient, CommentsRemoteDataSource>(
          update: (_, dio, __) => CommentsRemoteDataSource(dio.dio),
        ),
        ProxyProvider<DioClient, ChatRemoteDataSource>(
          update: (_, dio, __) => ChatRemoteDataSource(dio.dio),
        ),

        // Repositories
        ProxyProvider<EventsRemoteDataSource, EventsRepository>(
          update: (_, ds, __) => EventsRepository(ds),
        ),
        ProxyProvider<CommentsRemoteDataSource, CommentsRepository>(
          update: (_, ds, __) => CommentsRepository(ds),
        ),
        ProxyProvider<ChatRemoteDataSource, ChatRepository>(
          update: (_, ds, __) => ChatRepository(ds),
        ),

        ProxyProvider<DioClient, UsersRemoteDataSource>(
          update: (_, dio, __) => UsersRemoteDataSource(dio.dio),
        ),

        // 2. Users Repository
        ProxyProvider<UsersRemoteDataSource, UsersRepository>(
          update: (_, ds, __) => UsersRepository(ds),
        ),

        // 3. Users Provider (Vložte do té DRUHÉ vrstvy 'child' MultiProvideru, tam kde je ChatProvider)
        ChangeNotifierProxyProvider<UsersRepository, UsersProvider>(
          create: (context) => UsersProvider(context.read<UsersRepository>()),
          update: (_, repo, __) => UsersProvider(repo),
        ),
      ],
      // 2. VRSTVA: Logika (Providers, které potřebují Repozitáře)
      child: MultiProvider(
        providers: [
          // Comments Provider
          ChangeNotifierProxyProvider<CommentsRepository, CommentsProvider>(
            create: (context) =>
                CommentsProvider(context.read<CommentsRepository>()),
            update: (_, repo, prev) => CommentsProvider(repo),
          ),

          // Chat Provider
          // TEĎ UŽ BUDE FUNGOVAT context.read<ChatRepository>(),
          // protože je "pod" první vrstvou.
          ChangeNotifierProxyProvider2<
            ChatRepository,
            WebSocketService,
            ChatProvider
          >(
            create: (context) => ChatProvider(
              context.read<ChatRepository>(),
              context.read<WebSocketService>(),
            ),
            update: (_, repo, ws, prev) => ChatProvider(repo, ws),
          ),
        ],
        child: const SrumecApp(),
      ),
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
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkLoginStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authProvider.isAuthenticated) {
      return const MainScreen();
    }

    return const LoginScreen();
  }
}
