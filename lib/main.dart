import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'register.dart';
import 'home.dart';
import 'splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
      ),
      home: const SplashScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  double _progress = 0.0;

  Future<void> _login() async {
    final email = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun!")),
      );
      return;
    }

    setState(() {
      _loading = true;
      _progress = 0.0;
    });

    try {
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {
          _progress = i * 0.1;
        });
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted)
        return; //setState sonrası hala widget ağacına bağlı mı kontrolü
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Giriş başarılı!")));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: \${e.code}");
      String mesaj;

      switch (e.code) {
        case 'user-not-found':
          mesaj = "Bu e-posta ile kayıtlı kullanıcı yok.";
          HapticFeedback.vibrate();
          break;
        case 'wrong-password':
          mesaj = "Parola hatalı!";
          HapticFeedback.vibrate();
          break;
        case 'invalid-email':
          mesaj = "Geçersiz e-posta formatı!";
          HapticFeedback.vibrate();
          break;
        case 'too-many-requests':
          mesaj = "Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.";
          HapticFeedback.vibrate();
          break;
        case 'invalid-credential':
          mesaj =
              "Kimlik doğrulama başarısız. Lütfen bilgilerinizi kontrol edin.";
          HapticFeedback.vibrate();
          break;
        default:
          mesaj = "Bir hata oluştu: \${e.code}";
          HapticFeedback.vibrate();
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mesaj)));
    } catch (e) {
      print("GENEL HATA: \${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bilinmeyen bir hata oluştu.")),
      );
      HapticFeedback.vibrate();
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    double genislik = MediaQuery.of(context).size.width;
    double yukseklik = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/image.png"),
            fit: BoxFit.cover,
          ),
        ),
        alignment: const Alignment(0, -0.3),
        child: SizedBox(
          width: genislik * 0.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(75),
                child: Image.asset(
                  "assets/images/logo.png",
                  height: yukseklik * 0.2,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: yukseklik * 0.015),
              _buildStyledTextField("E-posta", false, _usernameController),
              SizedBox(height: yukseklik * 0.015),
              _buildStyledTextField("Parola", true, _passwordController),
              SizedBox(height: yukseklik * 0.015),

              _loading
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            value: _progress,
                            color: Colors.amber,
                            strokeWidth: 6,
                          ),
                        ),
                        Text(
                          "${(_progress * 100).toInt()}%",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text("Giriş Yap"),
                    ),

              SizedBox(height: yukseklik * 0.018),

              RichText(
                text: TextSpan(
                  text: "Hesabınız yok mu? ",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: "Kayıt olun",
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyledTextField(
    String label,
    bool obscure,
    TextEditingController controller,
  ) {
    return Theme(
      data: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber),
          ),
          labelStyle: TextStyle(color: Colors.amber),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 5, 12, 0),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.3 * 255).toInt()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: TextField(
              controller: controller,
              obscureText: obscure,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(
                  color: Color.fromARGB(255, 56, 48, 21),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
