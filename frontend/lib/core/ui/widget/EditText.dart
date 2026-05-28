import 'package:flutter/material.dart';

class EditText extends StatelessWidget {
  // EditText(this.hintText, this.obscure, {super.key});

  EditText({
    Key? key,
    required this.hintText, // non-nullable and required
    this.obscure = false, // nullable and optional
  }) : super(key: key);

  final String hintText;
  bool obscure;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 68,
      child: TextField(
          textAlignVertical: TextAlignVertical.center,
          obscureText: obscure,
          obscuringCharacter: "*",
          maxLines: 1,
          cursorColor: const Color(0xFF828282),
          style: const TextStyle(
            color: Color(0xFF4F4F4F),
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintStyle: const TextStyle(
              color: Color(0xFF828282),
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
            hintText: hintText,
            enabledBorder: editTextBorder(),
            border: editTextBorder(),
            focusedBorder: editTextBorder(),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 26, horizontal: 25),
          )),
    );
  }
}

OutlineInputBorder editTextBorder() {
  return OutlineInputBorder(
    borderSide: const BorderSide(width: 1, color: Color(0xFFBDBDBD)),
    borderRadius: BorderRadius.circular(71),
  );
}
