import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:organizer/app/theme/app_color.dart';

TextStyle getAppFontStyle(
  String fontName, {
  Color? color,
  double? fontSize,
  FontWeight? fontWeight,
  double? height,
}) {
  const googleFonts = {
    'Inter',
    'Roboto',
    'Outfit',
    'Poppins',
    'Montserrat',
    'Lato',
    'Open Sans',
    'Raleway',
    'Playfair Display',
    'Fira Code',
  };
  if (googleFonts.contains(fontName)) {
    try {
      return GoogleFonts.getFont(
        fontName,
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
      );
    } catch (_) {}
  }
  return TextStyle(
    fontFamily: fontName,
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
  );
}

class TypographyPicker extends StatefulWidget {
  final String? initialFont;
  final ValueChanged<String> onFontChanged;

  const TypographyPicker({
    super.key,
    this.initialFont,
    required this.onFontChanged,
  });

  @override
  State<TypographyPicker> createState() => _TypographyPickerState();
}

class _TypographyPickerState extends State<TypographyPicker> {
  static const List<String> availableFonts = [
    // Asset Fonts
    'AiryBlend',
    'Altavera',
    'Amsthon',
    'Capitalism',
    'Catsumi',
    'Cattyer',
    'Comfort',
    'DarkBristelle',
    'Grostel',
    'JamoaScript',
    'Journal',
    'KhaylaExelent',
    'Lowera',
    'LunaMuse',
    'Malviro',
    'MilanoPerla',
    'Montesand',
    'Mornings',
    'Moves',
    'Raceday',
    'Second',
    'StarlightBranch',
    'TheBlackheads',
    'Thinger',
    'Torra',
    'Beasticle',
    'BlackWiliam',
    'Gunman',
    'HandmadeBrushes',
    'LightPaprica',
    'ViewVacation',
    // Popular Google Fonts
    'Inter',
    'Roboto',
    'Outfit',
    'Poppins',
    'Montserrat',
    'Lato',
    'Open Sans',
    'Raleway',
    'Playfair Display',
    'Fira Code',
  ];

  late String _selectedFont;

  @override
  void initState() {
    super.initState();
    _selectedFont = widget.initialFont ?? 'Inter';
  }

  void _openFontPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (ctx, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Typography',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColor.textMuted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: availableFonts.length,
                      separatorBuilder: (ctx, index) => const Divider(color: AppColor.border, height: 1),
                      itemBuilder: (ctx, index) {
                        final font = availableFonts[index];
                        final isSelected = font == _selectedFont;
                        return Material(
                          color: AppColor.surface,
                          child: ListTile(
                            title: Text(
                              font,
                              style: getAppFontStyle(
                                font,
                                color: isSelected ? AppColor.primary : Colors.white,
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              'Sample Text: Quick Brown Fox',
                              style: getAppFontStyle(
                                font,
                                color: AppColor.textMuted,
                                fontSize: 12,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_circle_rounded, color: AppColor.primary)
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedFont = font;
                              });
                              widget.onFontChanged(font);
                              Navigator.pop(ctx);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openFontPicker,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColor.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.text_fields_rounded, color: AppColor.textMuted, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedFont,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: getAppFontStyle(
                  _selectedFont,
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down_rounded, color: AppColor.textMuted),
          ],
        ),
      ),
    );
  }
}

