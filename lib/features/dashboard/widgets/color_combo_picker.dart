import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';
import 'package:organizer/features/dashboard/widgets/blossom_color_picker.dart';

/// A reusable widget that shows a blossom color picker dialog and returns the selected
/// color as a hex string (e.g. "#FF5733").
class ColorComboPicker extends StatefulWidget {
  final String? initialColorHex;
  final ValueChanged<String> onColorChanged;

  const ColorComboPicker({
    super.key,
    this.initialColorHex,
    required this.onColorChanged,
  });

  @override
  State<ColorComboPicker> createState() => _ColorComboPickerState();
}

class _ColorComboPickerState extends State<ColorComboPicker> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColorHex != null
        ? _hexToColor(widget.initialColorHex!)
        : AppColor.primary;
  }

  Color _hexToColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  String _colorToHex(Color color) => '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

  void _openPicker() async {
    final Color? picked = await showBlossomColorPicker(context, _selectedColor);

    if (picked != null && picked != _selectedColor) {
      setState(() => _selectedColor = picked);
      widget.onColorChanged(_colorToHex(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openPicker,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _selectedColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.border),
        ),
        child: const Icon(Icons.palette, color: Colors.white),
      ),
    );
  }
}
