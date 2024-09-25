import 'package:flutter/material.dart';

class CustomCreateaccount extends StatelessWidget {
  final VoidCallback onSignUpPressed;
  final String signUpText;
  final Color? color;
  const CustomCreateaccount(
      {super.key, required this.onSignUpPressed, required this.signUpText, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
              minimumSize: const Size(400, 50),
              side: const BorderSide(color: Colors.black, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              )),
          onPressed: onSignUpPressed,
          child: Text(
            signUpText,
            style: const TextStyle(
              fontSize: 22,
              fontFamily: 'Jaldi',
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
