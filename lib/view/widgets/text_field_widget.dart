import 'package:gep/core/constants/constants.dart';
import 'package:material_ui/material_ui.dart';

class TextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final int? maxLines;
  final FocusNode? focusNode;
  final Function(String)? onFieldSubmitted;
  final bool enabled;

  const TextFieldWidget({
    super.key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.focusNode,
    this.onFieldSubmitted,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final fillColor = isDark ? AppColors.darkNeutral : AppColors.lightNeutral;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final iconColor = isDark ? AppColors.darkIcon : AppColors.primary;

    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: borderColor),
    );

    return TextFormField(
      controller: controller,
      enabled: enabled,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      maxLines: obscureText ? 1 : maxLines,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        isDense: true,
        labelText: labelText,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 13,
        ),
        floatingLabelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        filled: true,
        fillColor: fillColor,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 18, color: iconColor)
            : null,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 45,
        ),
        suffixIcon: suffixIcon,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 45,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: AppConstants.defaultPadding,
        ),
        border: baseBorder,
        enabledBorder: baseBorder,
        disabledBorder: baseBorder.copyWith(
          borderSide: BorderSide(color: borderColor.withValues(alpha: 0.5)),
        ),
        focusedBorder: baseBorder.copyWith(
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        errorBorder: baseBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: baseBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}
