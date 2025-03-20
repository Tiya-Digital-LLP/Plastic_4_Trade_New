import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class EditTextPasswordLogin extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool secureText;
  TextInputType textInputType;
  Widget? prefix;

  EditTextPasswordLogin(
      {required this.controller,
      required this.label,
      this.textInputType = TextInputType.text,
      this.secureText = true,
      this.prefix,
      super.key});

  @override
  State<EditTextPasswordLogin> createState() => _EditTextPasswordState();
}

class _EditTextPasswordState extends State<EditTextPasswordLogin> {
  Color _color2 = AppColors.black26Color;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: _color2,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: SizedBox(
        height: 65,
        child: TextFormField(
          controller: widget.controller,
          obscureText: !_isPasswordVisible,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: AppColors.gray,
            fontFamily: 'assets/fonst/Metropolis-Black.otf',
          ),
          keyboardType: widget.textInputType,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            filled: true,
            fillColor: AppColors.backgroundColor,
            labelText: widget.label,
            labelStyle: TextStyle(
              color: Colors.grey[600],
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 32),
            prefixIconColor: AppColors.gray,
            border: InputBorder.none,
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _color2, width: 1),
              borderRadius: BorderRadius.circular(12.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _color2, width: 1),
              borderRadius: BorderRadius.circular(12.0),
            ),
            prefixIcon: widget.prefix,
            suffixIconConstraints: const BoxConstraints(minWidth: 32),
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.blackColor,
                ),
              ),
            ),
          ),
          validator: (value) {
            if (value!.isEmpty) {
            } else {
              _color2 = AppColors.greenWithShade;
            }
            return null;
          },
          onFieldSubmitted: (value) {
            if (value.isEmpty) {
              WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
              showCustomToast('Please Enter Your ${widget.label}');
              _color2 = AppColors.red;
            } else {
              _color2 = AppColors.greenWithShade;
            }
          },
          onChanged: (value) {
            if (value.isEmpty) {
              WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
              showCustomToast('Please Enter Your ${widget.label}');
              setState(() {
                _color2 = AppColors.red;
              });
            } else {
              setState(() {
                _color2 = AppColors.greenWithShade;
              });
            }
          },
        ),
      ),
    );
  }
}
