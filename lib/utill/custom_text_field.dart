import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
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
  final String? errorText;
  final bool? obscureText;
  final bool? enabled;
  final List<String>? autofillHints;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters = const [],
    this.onChanged,
    this.validator,
    this.borderColor = AppColors.gray,
    this.onFieldSubmitted,
    this.readOnly = false,
    this.suffixIcon,
    this.onTap,
    this.textCapitalization = TextCapitalization.none,
    this.errorText,
    this.obscureText = false,
    this.enabled = true,
    this.autofillHints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: SizedBox(
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
          obscureText: obscureText ?? false,
          enabled: enabled,
          autofillHints: autofillHints,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: TextStyle(
              color: enabled == false ? Colors.black : Colors.grey[600],
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            isDense: true,
            suffixIcon: suffixIcon,
            errorText: errorText,
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
      ),
    );
  }
}
