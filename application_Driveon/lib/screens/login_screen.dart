import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart'; // <-- AGGIUNTO
import 'user_provider.dart'; // <-- AGGIUNTO

import 'main_navigation.dart';
import 'register_screen.dart';

// Screen that allows the user to log in with email and password.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String _rememberMeKey = 'remember_me';
  static const String _savedEmailKey = 'saved_email';

  // Tracks the text entered in the inputs.
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  // Manages password visibility.
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLoginPreference();
  }

  Future<void> _loadSavedLoginPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(_savedEmailKey) ?? '';
    final shouldRemember = prefs.getBool(_rememberMeKey) ?? false;

    if (!mounted) return;

    setState(() {
      _rememberMe = shouldRemember;
      if (shouldRemember && savedEmail.isNotEmpty) {
        emailCtrl.text = savedEmail;
      }
    });
  }

  Future<void> _saveLoginPreference() async {
    final prefs = await SharedPreferences.getInstance();

    if (_rememberMe) {
      await prefs.setBool(_rememberMeKey, true);
      await prefs.setString(_savedEmailKey, emailCtrl.text.trim());
    } else {
      await prefs.setBool(_rememberMeKey, false);
      await prefs.remove(_savedEmailKey);
    }
  }

  // Method that logs the user in with Firebase.
  Future<void> _login() async {
    // Reads the values entered by the user.
    final email = emailCtrl.text.trim();
    final password = passCtrl.text;

    // If either field is empty, show an error message.
    if (email.isEmpty || password.isEmpty) {
      _showMessage('Inserisci email e password.');
      return;
    }

    try {
      // Firebase Auth call to authenticate the user.
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // If the user is authenticated correctly, save login preference.
      await _saveLoginPreference();

      // --- SALVATAGGIO DATI NEL PROVIDER ---
      if (mounted) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await Provider.of<UserProvider>(context, listen: false).setUserData(
            name: user.displayName ?? user.email?.split('@').first ?? 'Utente',
            email: user.email ?? 'Email non disponibile',
          );
        }
      }

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      // If Firebase returns an auth error, show it to the user.
      _showMessage(e.message ?? 'Errore durante l\'accesso.');
    } on FirebaseException catch (e) {
      final message = e.code == 'network-request-failed'
          ? 'Controlla la connessione a Internet e riprova.'
          : e.message ?? 'Errore durante l\'accesso.';
      _showMessage(message);
    } catch (e) {
      _showMessage('Si è verificato un errore di rete. Controlla la connessione e riprova.');
    }
  }

  // Helper method to show a message at the bottom of the screen.
  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Sends a password reset email to the user.
  Future<void> _resetPassword() async {
    final email = emailCtrl.text.trim();

    if (email.isEmpty) {
      _showMessage('Inserisci la tua email per reimpostare la password.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showMessage('Ti abbiamo inviato un’email per reimpostare la password.');
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Impossibile reimpostare la password.');
    } on FirebaseException catch (e) {
      final message = e.code == 'network-request-failed'
          ? 'Controlla la connessione a Internet e riprova.'
          : e.message ?? 'Impossibile reimpostare la password.';
      _showMessage(message);
    } catch (e) {
      _showMessage('Si è verificato un errore di rete. Controlla la connessione e riprova.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0C0C),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 46 : 18,
                vertical: isDesktop ? 30 : 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        'Login - DRIVEON',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isDesktop ? 14 : 12,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Text(
                        'DRIVEON.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1.2,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'CAR RENTAL',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: isDesktop ? 420 : 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      image: const DecorationImage(
                        image: AssetImage('lib/assets/images/porche_image.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 34),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final formWidth = isDesktop
                          ? 760.0
                          : constraints.maxWidth;

                      return Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: formWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Mettiti al volante.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 50,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -1.7,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Accedi e riparti dal tuo prossimo viaggio.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 28),
                              const Text(
                                'Email',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: isDesktop ? 760 : double.infinity,
                                child: TextField(
                                  controller: emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'La tua email',
                                    hintStyle: const TextStyle(
                                      color: Colors.white38,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFF1D1E22),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 22),
                              const Text(
                                'Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: passCtrl,
                                obscureText: _obscurePassword,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'La tua password',
                                  hintStyle: const TextStyle(
                                    color: Colors.white38,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF1D1E22),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.white54,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) async {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });

                                      await _saveLoginPreference();
                                    },
                                    activeColor: const Color(0xFFB7FF00),
                                    checkColor: Colors.black,
                                    side: const BorderSide(
                                      color: Colors.white38,
                                    ),
                                  ),
                                  const Text(
                                    'Ricordami',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: _resetPassword,
                                    child: const Text(
                                      'Password dimenticata?',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              SizedBox(
                                height: 62,
                                child: ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFB7FF00),
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Accedi',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 28,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 26),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Non hai un account? ',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const RegisterScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Registrati',
                                      style: TextStyle(
                                        color: Color(0xFFB7FF00),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 26),
                              const Center(
                                child: Text(
                                  'LA STRADA È TUA.',
                                  style: TextStyle(
                                    color: Colors.white38,
                                    letterSpacing: 2.8,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Center(
                                child: Container(
                                  width: 112,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}