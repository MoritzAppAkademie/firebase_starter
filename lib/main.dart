import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Firebase Auth", home: AuthGate());
  }
}

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

//Auth-Gate
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const PlaceholderPage();
        }
        return const _LoginPage();
      },
    );
  }
}

class _LoginPage extends StatefulWidget {
  const _LoginPage({super.key});

  @override
  State<_LoginPage> createState() => __LoginPageState();
}

class __LoginPageState extends State<_LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _pwCtrl.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? "Login fehlgeschlagen");
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || v.trim().isEmpty
                        ? "Email eingeben"
                        : null),
                  ),
                  TextFormField(controller: _pwCtrl, obscureText: true),
                  SizedBox(height: 12),
                  if (_error != null) Text(_error!),
                  SizedBox(height: 12),
                  FilledButton(
                    onPressed: _loading ? null : _signIn,
                    child: _loading
                        ? const SizedBox(child: CircularProgressIndicator())
                        : const Text("Einloggen"),
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
