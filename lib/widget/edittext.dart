import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:Plastic4trade/utill/custom_toast.dart';
import 'package:flutter/material.dart';

class EditText extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType textInputType;
  final int minLines;
  final int maxLength;
  final Widget? prefix;

  const EditText({
    required this.controller,
    required this.label,
    this.textInputType = TextInputType.text,
    this.minLines = 1,
    this.maxLength = 40,
    this.prefix,
    super.key,
  });

  @override
  _EditTextState createState() => _EditTextState();
}

class _EditTextState extends State<EditText> {
  Color _color2 = AppColors.black26Color;
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
          cursorHeight: 15,
          controller: widget.controller,
          minLines: widget.minLines,
          maxLines: widget.minLines,
          maxLength: widget.maxLength,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: AppColors.blackColor,
            fontFamily: 'assets/fonst/Metropolis-Black.otf',
          ),
          keyboardType: widget.textInputType,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            filled: true,
            fillColor: AppColors.backgroundColor,
            counterText: '',
            prefixIcon: widget.prefix,
            labelText: widget.label,
            labelStyle: TextStyle(
              color: Colors.grey[600],
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 32),
            prefixIconColor: AppColors.gray,
            border: InputBorder.none,
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
