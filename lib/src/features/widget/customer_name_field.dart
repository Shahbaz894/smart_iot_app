import "package:flutter/material.dart";
import "package:smart_iot_app/src/core/constant/app_color.dart";

class CustomerNameField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<String> suggestions;
  final bool enabled;

  const CustomerNameField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.suggestions,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: focusNode,
      optionsBuilder: (TextEditingValue value) {
        if (!enabled) return const Iterable<String>.empty();

        final input = value.text.trim().toLowerCase();
        if (input.isEmpty) return const Iterable<String>.empty();

        return suggestions.where(
              (name) => name.toLowerCase().contains(input),
        );
      },
      onSelected: (String value) {
        controller.text = value;
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
      },
      fieldViewBuilder: (
          context,
          textEditingController,
          fieldFocusNode,
          onFieldSubmitted,
          ) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: TextField(
            enabled: enabled,
            controller: textEditingController,
            focusNode: fieldFocusNode,
            keyboardType: TextInputType.text,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: enabled
                  ? "Customer name for Khata"
                  : "Select a device first",
              hintStyle: TextStyle(
                color: AppColors.white.withOpacity(0.42),
              ),
              prefixIcon: Icon(
                enabled
                    ? Icons.person_outline_rounded
                    : Icons.lock_outline_rounded,
                color: AppColors.primary,
              ),
              suffixIcon: suggestions.isEmpty || !enabled
                  ? null
                  : Icon(
                Icons.manage_search_rounded,
                color: AppColors.white.withOpacity(0.45),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width - 36,
              constraints: const BoxConstraints(
                maxHeight: 240,
                maxWidth: 560,
              ),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderDark),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.34),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 6),
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, __) {
                  return Divider(
                    height: 1,
                    color: AppColors.white.withOpacity(0.06),
                  );
                },
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);

                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      option,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}