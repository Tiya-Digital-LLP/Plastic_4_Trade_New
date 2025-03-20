import 'package:flutter/material.dart';

class BottomSheetFilterCore extends StatelessWidget {
  final GestureTapCallback? onTap;
  final bool? checked;
  final String? title;

  const BottomSheetFilterCore(
      {super.key, this.onTap, this.checked = false, this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              checked == true
                  ? Icon(
                      Icons.check_circle,
                      color: Colors.green.shade600,
                      size: 22,
                    )
                  : const Icon(Icons.circle_outlined,
                      color: Colors.black45, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "$title",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontFamily: 'assets/fonts/Metropolis-Black.otf',
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.24,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 7),
      ],
    );
  }
}
