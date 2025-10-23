import 'package:flutter/material.dart';
import 'package:srumec_app/screens/main_screen.dart';
import 'package:srumec_app/services/auth_service.dart';
import 'package:srumec_app/services/storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Klíč pro validaci formuláře
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _storageService = StorageService();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    // Zvalidujeme formulář
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await _authService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (token != null) {
        await _storageService.saveToken(token);
        // Po úspěšném přihlášení přejdeme na hlavní obrazovku
        // 'mounted' kontroluje, zda je widget stále aktivní
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Nesprávný email nebo heslo.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Nastala chyba. Zkuste to prosím znovu.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. VRSTVA: Samotný formulář
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo aplikace
                      const Icon(
                        Icons.pin_drop_outlined,
                        size: 80,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Vítejte v Šrumec',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Emailové pole
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !value.contains('@')) {
                            return 'Prosím zadejte platný email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Heslové pole
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Heslo',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Prosím zadejte heslo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Chybová hláška
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Přihlašovací tlačítko
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: _isLoading ? null : _login,
                        child: const Text(
                          'Přihlásit se',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. VRSTVA: Loading screen (zobrazí se pouze pokud _isLoading je true)
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
