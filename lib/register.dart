import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  bool _isLoading = false;
  double _isLoadingPercent = 0.0;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final email = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final birthday = _dateController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        birthday.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun!")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Parolalar uyuşmuyor!")));
      return;
    }

    setState(() {
      _isLoading = true;
      _isLoadingPercent = 0.0;
    });

    try {
      // Simülasyon: %10'dan %100'e kadar animasyon
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {
          _isLoadingPercent = i * 0.1;
        });
      }

      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final userId = credential.user?.uid;

      await FirebaseFirestore.instance.collection("users").doc(userId).set({
        "email": email,
        "birthday": birthday,
        "createdAt": Timestamp.now(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kayıt başarılı! Giriş yapabilirsiniz.")),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String mesaj = "Bir hata oluştu.";
      if (e.code == 'email-already-in-use') {
        mesaj = "Bu e-posta zaten kayıtlı!";
      } else if (e.code == 'invalid-email') {
        mesaj = "Geçersiz e-posta!";
      } else if (e.code == 'weak-password') {
        mesaj = "Parola çok zayıf (min. 6 karakter)!";
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mesaj)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Kayıt hatası: ${e.toString()}")));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    double yukseklik = MediaQuery.of(context).size.height;
    double genislik = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/image.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.amber, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Align(
            alignment: const Alignment(0, -0.55),
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
                  _buildInput("E-Posta", false, _usernameController),
                  SizedBox(height: yukseklik * 0.015),
                  _buildInput("Parola", true, _passwordController),
                  SizedBox(height: yukseklik * 0.015),
                  _buildInput(
                    "Parola Tekrar",
                    true,
                    _confirmPasswordController,
                  ),
                  SizedBox(height: yukseklik * 0.015),
                  _buildDatePicker("Doğum Tarihi"),
                  SizedBox(height: yukseklik * 0.02),
                  _isLoading
                      ? Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(
                                    value: _isLoadingPercent,
                                    color: Colors.amber,
                                    strokeWidth: 6,
                                  ),
                                ),
                                Text(
                                  "${(_isLoadingPercent * 100).toInt()}%",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : ElevatedButton(
                          onPressed: _register,
                          child: const Text("Kayıt Ol"),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
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

  Widget _buildDatePicker(String label) {
    return Theme(
      data: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber),
          ),
          labelStyle: TextStyle(color: Color.fromARGB(255, 56, 48, 21)),
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
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: label,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (selectedDate != null) {
                      _dateController.text =
                          '${selectedDate.toLocal().toString().split(' ')[0]}';
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
