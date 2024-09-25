import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:test_appdp/home_screen.dart';
import 'package:test_appdp/services/auth_service.dart';
import 'package:test_appdp/signup_screen.dart';
import 'package:test_appdp/widgets/custom_button.dart';
import 'package:test_appdp/widgets/custom_signup.dart';
import 'package:test_appdp/widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isChecked = false;
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
          child: Column(
        children: [
          const Center(
            child: Image(
              image: AssetImage('assets/images/logodl.png'),
              width: 250,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chào mừng trở lại,',
                  style: TextStyle(fontSize: 36, fontFamily: 'Jaldi'),
                ),
                const Text(
                  'Khám phá những lựa chọn vô hạn và sự tiện lợi chưa từng có.',
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: "Inter",
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Form(
                  child: Column(
                    children: [
                      CustomTextfield(
                        controller: emailController,
                        labelText: 'E-Mail',
                        prefixIcon: const Icon(Icons.mail_outline),
                      ),
                      const SizedBox(
                        height: 17,
                      ),
                      CustomTextfield(
                        controller: passwordController,
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        isPassword: true,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: isChecked,
                                onChanged: (value) {
                                  isChecked = value!;
                                  setState(() {});
                                },
                              ),
                              const Text(
                                  'Chọn ô để chúng tôi biết chính xác là người!'),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          CustomButton(
                            onButtonPressed: isChecked
                                ? () async {
                                    User? user =
                                        await _auth.signInWithEmailAndPassword(
                                      emailController.text,
                                      passwordController.text,
                                    );
                                    if (user != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const HomeScreen(),
                                        ),
                                      );
                                    }
                                  }
                                : null,
                            text: 'Đăng nhập',
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomCreateaccount(
                        onSignUpPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignupScreen()));
                        },
                        signUpText: "Tạo tài khoản",
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.black,
                              thickness: 1,
                              endIndent: 10,
                            ),
                          ),
                          Text('Hoặc đăng nhập với'),
                          Expanded(
                            child: Divider(
                              color: Colors.black,
                              thickness: 1,
                              indent: 10,
                            ),
                          ),
                        ],
                      ),
                      // Center(
                      //   child: ElevatedButton.icon(
                      //     onPressed: () async {
                      //       final provider = OAuthProvider("microsoft.com");
                      //       provider.setCustomParameters(
                      //         {
                      //           "tenant": "98ada680-e3f4-48cb-8fbb-c8b10cb97aed"
                      //         },
                      //       );

                      //       try {
                      //         if (kIsWeb) {
                      //           await FirebaseAuth.instance
                      //               .signInWithPopup(provider);
                      //         } else {
                      //           await FirebaseAuth.instance
                      //               .signInWithRedirect(provider);
                      //         }
                      //       } catch (e) {
                      //         // Show error message
                      //         ScaffoldMessenger.of(context).showSnackBar(
                      //           SnackBar(
                      //               content: Text("Đăng nhập thất bại: $e")),
                      //         );
                      //       }
                      //     },
                      //     label: const Text("Đăng nhập bằng Microsoft"),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      )),
    ));
  }
}
