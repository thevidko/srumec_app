import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srumec_app/auth/providers/auth_provider.dart';
import 'package:srumec_app/auth/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authService = AuthService();

  // Naše brand barvy
  static const Color vibrantPurple = Color(0xFF6200EA);

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final loginData = await _authService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (loginData != null) {
        if (!mounted) return;
        final token = loginData['token'];
        final userId = loginData['userId'];
        await context.read<AuthProvider>().login(token, userId);
      } else {
        setState(() {
          _errorMessage = 'Nesprávný email nebo heslo.';
        });
      }
    } catch (e) {
      debugPrint("Login error: $e");
      setState(() {
        _errorMessage = 'Chyba přihlášení. Zkontrolujte připojení.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleRegistration() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registrace bude brzy dostupná!'),
        backgroundColor: vibrantPurple,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- LOGO A HLAVIČKA ---
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: vibrantPurple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.pin_drop_rounded,
                      size: 50,
                      color: vibrantPurple,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Vítejte zpět!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Přihlaste se a zjistěte, kde je šrumec.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 48),

                  // --- FORMULÁŘ ---

                  // Email
                  TextFormField(
                    controller: _emailController,
                    cursorColor: vibrantPurple,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration('Email', Icons.email_outlined),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !value.contains('@')) {
                        return 'Zadejte platný email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Heslo
                  TextFormField(
                    controller: _passwordController,
                    cursorColor: vibrantPurple,
                    obscureText: true,
                    decoration: _inputDecoration('Heslo', Icons.lock_outline),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Zadejte heslo';
                      }
                      return null;
                    },
                  ),

                  // Zapomenuté heslo (volitelné, pro doplnění designu)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {}, // TODO
                      style: TextButton.styleFrom(foregroundColor: Colors.grey),
                      child: const Text("Zapomněli jste heslo?"),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- CHYBOVÁ HLÁŠKA ---
                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // --- TLAČÍTKO PŘIHLÁSIT ---
                  FilledButton(
                    onPressed: _isLoading ? null : _login,
                    style: FilledButton.styleFrom(
                      backgroundColor: vibrantPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'PŘIHLÁSIT SE',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                  ),

                  const SizedBox(height: 32),

                  // --- REGISTRACE ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Ještě nemáš účet?",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: _handleRegistration,
                        style: TextButton.styleFrom(
                          foregroundColor: vibrantPurple,
                        ),
                        child: const Text("Zaregistrovat se"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Pomocná metoda pro konzistentní styl inputů
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey),
      labelStyle: const TextStyle(color: Colors.grey),
      floatingLabelStyle: const TextStyle(color: vibrantPurple),
      filled: true,
      fillColor: Colors.grey[50], // Velmi světlé pozadí inputu
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: vibrantPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}
