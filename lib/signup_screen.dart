import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:test_appdp/home_screen.dart';
import 'package:test_appdp/login_screen.dart';

import 'package:test_appdp/services/auth_service.dart';
import 'package:test_appdp/widgets/custom_signup.dart';

class SignupScreen extends StatelessWidget {
  final AuthService _auth = AuthService();
  final TextEditingController _emailConttroller = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1d2630),
      appBar: AppBar(
        backgroundColor: const Color(0xff1d2630),
        foregroundColor: Colors.white,
        title: const Text("Create Account"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            const Text(
              'Đăng ký tài khoản',
              style: TextStyle(
                fontSize: 36,
                fontFamily: 'Jaldi',
                color: Colors.white,
              ),
            ),
            const Text(
              'Khám phá những lựa chọn vô hạn và sự tiện lợi chưa từng có.',
              style: TextStyle(
                fontSize: 17,
                fontFamily: "Inter",
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: _emailConttroller,
              style: const TextStyle(
                color: Colors.white, // Set text color to white
              ),
              decoration: InputDecoration(
                labelText: 'E-mail',
                labelStyle: const TextStyle(
                    fontFamily: 'Jaldi', fontSize: 20, color: Colors.white),
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Colors.white,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(
                    color: Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                    width: 3.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: _passwordController,
              style: const TextStyle(
                color: Colors.white, // Set text color to white
              ),
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(
                    fontFamily: 'Jaldi', fontSize: 20, color: Colors.white),
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.white,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(
                    color: Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                    width: 3.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xfff2a9b6),
                    minimumSize: const Size(400, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                onPressed: () async {
                  User? user = await _auth.registerWithEmailAndPassword(
                    _emailConttroller.text,
                    _passwordController.text,
                  );
                  if (user != null) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomeScreen()));
                  }
                },
                child: const Text(
                  'Đăng ký',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Jaldi',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            const Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.white,
                    thickness: 1,
                    endIndent: 10,
                  ),
                ),
                Text(
                  'Hoặc đăng ký với',
                  style: TextStyle(color: Colors.white),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.white,
                    thickness: 1,
                    indent: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size(400, 50),
                  side: const BorderSide(color: Colors.white, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
              },
              child: const Text(
                'Đăng nhập',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Jaldi',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
