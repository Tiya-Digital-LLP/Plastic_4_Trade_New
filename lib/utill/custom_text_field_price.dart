import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFieldPrice extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final List<TextInputFormatter> inputFormatters;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final Color borderColor;
  final Function(String)? onFieldSubmitted;
  final bool readOnly;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final TextCapitalization? textCapitalization;
  final String? errorText; // New optional errorText parameter

  const CustomTextFieldPrice({
    Key? key,
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters = const [],
    this.onChanged,
    this.validator,
    this.borderColor = Colors.grey,
    this.onFieldSubmitted,
    this.readOnly = false,
    this.suffixIcon,
    this.onTap,
    this.textCapitalization = TextCapitalization.none,
    this.errorText, // Initialize the new parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: TextFormField(
        controller: controller,
        cursorHeight: 15,
        style: const TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.w400,
          color: Colors.black,
          fontFamily: 'assets/fonts/Metropolis-Black.otf',
        ),
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          filled: true,
          labelText: labelText,
          labelStyle: TextStyle(
            color: Colors.grey[600],
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          isDense: true,
          suffixIcon: suffixIcon,
          errorText: errorText, // Add the errorText parameter here
        ),
        validator: validator ?? (value) => null,
        onChanged: (value) {
          if (value.isEmpty) {
            FocusScope.of(context).unfocus();
          }
          onChanged?.call(value);
        },
        onFieldSubmitted: (value) {
          if (onFieldSubmitted != null) {
            onFieldSubmitted!(value);
          }
        },
        onTap: onTap,
        readOnly: readOnly,
      ),
    );
  }
}
