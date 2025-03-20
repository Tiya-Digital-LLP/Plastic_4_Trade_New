import 'package:Plastic4trade/utill/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class CustomSearchInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;
  final Function(String) onChanged;
  final Future<List<String>> Function(String)? suggestionsCallback;
  final Widget Function(BuildContext, String)? itemBuilder;
  final Function(String)? onSuggestionSelected;
  final VoidCallback? onClear;

  const CustomSearchInput({
    required this.controller,
    required this.onSubmitted,
    required this.onChanged,
    this.onClear,
    this.suggestionsCallback,
    this.itemBuilder,
    this.onSuggestionSelected,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomSearchInput> createState() => _CustomSearchInputState();
}

class _CustomSearchInputState extends State<CustomSearchInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40.0),
        color: AppColors.backgroundColor,
      ),
      height: 40,
      margin: const EdgeInsets.only(left: 6.0),
      width: MediaQuery.of(context).size.width / 2.2,
      child: widget.suggestionsCallback != null &&
              widget.itemBuilder != null &&
              widget.onSuggestionSelected != null
          ? TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                style:
                    const TextStyle(color: AppColors.blackColor, fontSize: 14),
                controller: widget.controller,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: InputBorder.none,
                  prefixIconConstraints: const BoxConstraints(minWidth: 24),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.blackColor,
                    size: 20,
                  ),
                  suffixIcon: widget.controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              size: 20, color: Colors.black),
                          onPressed: widget.onClear,
                        )
                      : null,
                  hintText: 'Search',
                  hintStyle: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                    color: AppColors.blackColor,
                  ),
                ),
                onSubmitted: widget.onSubmitted,
                onChanged: widget.onChanged,
              ),
              suggestionsCallback: widget.suggestionsCallback!,
              itemBuilder: widget.itemBuilder!,
              onSuggestionSelected: widget.onSuggestionSelected!,
            )
          : TextField(
              style: const TextStyle(color: AppColors.blackColor, fontSize: 14),
              controller: widget.controller,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(top: -4),
                border: InputBorder.none,
                prefixIconConstraints: const BoxConstraints(minWidth: 24),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.blackColor,
                  size: 20,
                ),
                suffixIcon: widget.controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            size: 20, color: Colors.black),
                        onPressed: widget.onClear, // External function call
                      )
                    : null,
                hintText: 'Search',
                hintStyle: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                  color: AppColors.blackColor,
                ),
              ),
              onSubmitted: widget.onSubmitted,
              onChanged: widget.onChanged,
            ),
    );
  }
}
