import 'package:flutter/material.dart';
import '../dashboard/admin_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();

  bool isHide = true;

  final String adminUsername = "a";
  final String adminPassword = "a";

  void login() {
    if (usernameC.text.trim() == adminUsername &&
        passwordC.text.trim() == adminPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AdminPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username / Password salah"),
        ),
      );
    }
  }

  @override
  void dispose() {
    usernameC.dispose();
    passwordC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            final keyboard = MediaQuery.of(context).viewInsets.bottom;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(
                0,
                -keyboard * 0.4,
                0,
              ),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text(
                            "Kembali",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: [Colors.blue, Colors.indigo],
                                ),
                              ),
                              child: const Icon(
                                Icons.shield,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              "Admin Panel",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Masuk ke dashboard administrator",
                              style: TextStyle(color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: usernameC,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Username",
                                hintStyle:
                                    const TextStyle(color: Colors.white54),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: passwordC,
                              obscureText: isHide,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Password",
                                hintStyle:
                                    const TextStyle(color: Colors.white54),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isHide
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white54,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isHide = !isHide;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: login,
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text("Login"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}