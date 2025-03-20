import 'package:flutter/services.dart';

class CapitalizingTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text;

    // Capitalize the first letter of each word
    newText = newText
        .split(' ')
        .map((word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');

    // Ensure that only alphabets and digits are allowed
    newText = newText.replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '');

    // Limit length to 40 characters
    if (newText.length > 40) {
      newText = newText.substring(0, 40);
    }

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
