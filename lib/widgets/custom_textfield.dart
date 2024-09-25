import 'package:flutter/material.dart';

class CustomTextfield extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final Widget? prefixIcon;
  final bool isPassword; // Thêm thuộc tính để xác định xem đây có phải là trường mật khẩu không

  const CustomTextfield({
    super.key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.isPassword = false, // Mặc định là không phải trường mật khẩu
  });

  @override
  _CustomTextfieldState createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  bool _obscureText = true; // Biến để kiểm soát trạng thái hiển thị mật khẩu

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false, // Nếu là mật khẩu thì áp dụng
      decoration: InputDecoration(
        labelText: widget.labelText,
        prefixIcon: widget.prefixIcon,
        contentPadding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
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
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText; // Đổi trạng thái khi nhấn vào biểu tượng
                  });
                },
              )
            : null, // Nếu không phải là trường mật khẩu thì không có biểu tượng
      ),
    );
  }
}
