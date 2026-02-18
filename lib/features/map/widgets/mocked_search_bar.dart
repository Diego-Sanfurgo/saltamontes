import 'package:flutter/material.dart';
import 'package:saltamontes/core/theme/colors.dart';
import 'package:saltamontes/widgets/animated_search_text.dart';

class MockedSearchBar extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;

  const MockedSearchBar({super.key, this.onTap, this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(color: colorScheme.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
          child: Row(
            spacing: 8,
            children: [
              Icon(
                Icons.search_rounded,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkPrimaryColor
                    : AppColors.lightTextColor,
              ),

              AnimatedSearchText(),

              const Spacer(),

              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.tune_outlined),
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkPrimaryColor
                    : AppColors.lightTextColor,
                onPressed: onFilterTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
