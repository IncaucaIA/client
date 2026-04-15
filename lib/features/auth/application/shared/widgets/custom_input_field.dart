import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final String? errorText;
  final bool obscureText;
  final bool readOnly;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final List<DropdownMenuItem<String>>? dropdownItems;
  final String? dropdownValue;
  final ValueChanged<String?>? onDropdownChanged;
  final bool isDropdown;
  final bool isDateField;
  final DateTime? selectedDate;
  final ThemeData? theme;
  final FocusNode? focusNode;

  const CustomInputField({
    Key? key,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.errorText,
    this.obscureText = false,
    this.readOnly = false,
    this.keyboardType,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.controller,
    this.dropdownItems,
    this.dropdownValue,
    this.onDropdownChanged,
    this.isDropdown = false,
    this.isDateField = false,
    this.selectedDate,
    this.theme,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = this.theme ?? Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        isDropdown
            ? _buildDropdown(colors, theme)
            : _buildTextField(colors, theme),
        // Error text personalizado con salto de línea
        if (errorText != null && errorText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0, right: 12.0),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.error,
              ),
              softWrap: true,
              maxLines: null, // Permite múltiples líneas
            ),
          ),
      ],
    );
  }

  Widget _buildTextField(ColorScheme colors, ThemeData theme) {
    return TextField(
      onChanged: onChanged,
      obscureText: obscureText,
      readOnly: readOnly || isDateField,
      keyboardType: keyboardType,
      onTap: onTap,
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.error),
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: colors.onSurface.withOpacity(0.6),
        ),
        suffixIcon: suffixIcon,
        // Removemos errorText del InputDecoration para manejarlo manualmente
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colors.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildDropdown(ColorScheme colors, ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: dropdownValue,
      hint: Text(
        hintText,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colors.onSurface.withOpacity(0.6),
        ),
      ),
      items: dropdownItems,
      onChanged: onDropdownChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.error),
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: colors.onSurface.withOpacity(0.6),
        ),
        // Removemos errorText del InputDecoration para manejarlo manualmente
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      icon: Icon(
        Icons.arrow_drop_down,
        color: colors.onSurface.withOpacity(0.6),
      ),
      dropdownColor: colors.surface,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: colors.onSurface,
      ),
    );
  }
}