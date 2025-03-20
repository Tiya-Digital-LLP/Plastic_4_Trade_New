import 'package:flutter/material.dart';

class CustomLocationInput extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onTap;
  final String? hintText;
  final IconData prefixIcon;
  final IconData suffixIcon;
  final bool readOnly;
  final TextEditingController controller;
  final double borderRadius;

  const CustomLocationInput({
    Key? key,
    this.onChanged,
    this.onClear,
    this.onTap,
    this.hintText,
    required this.prefixIcon,
    required this.suffixIcon,
    this.readOnly = true,
    required this.controller,
    this.borderRadius = 40.0,
  }) : super(key: key);

  @override
  _CustomLocationInputState createState() => _CustomLocationInputState();
}

class _CustomLocationInputState extends State<CustomLocationInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        color: Colors.white,
      ),
      height: 40,
      margin: const EdgeInsets.only(left: 8.0),
      child: TextField(
        controller: widget.controller,
        textAlign: TextAlign.start,
        style: const TextStyle(color: Colors.black, fontSize: 14),
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: -4),
          border: InputBorder.none,
          prefixIconConstraints: const BoxConstraints(minWidth: 24),
          suffixIconConstraints: const BoxConstraints(minWidth: 24),
          prefixIcon: Icon(
            widget.prefixIcon,
            color: Colors.black,
            size: 20,
          ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: widget.onClear,
                  child: Icon(
                    widget.suffixIcon,
                    color: Colors.black,
                    size: 20,
                  ),
                )
              : null,
          hintText: widget.hintText ?? 'Location',
          hintStyle: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
