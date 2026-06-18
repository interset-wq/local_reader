import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, settings, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('设置')),
          body: ListView(
            children: [
              _SectionTitle(title: '主题'),
              _ThemeSelector(settings: settings),
              const Divider(),
              _SectionTitle(title: '字体大小: ${settings.fontSize.round()}'),
              Slider(
                value: settings.fontSize,
                min: 14,
                max: 28,
                divisions: 14,
                onChanged: (v) => settings.setFontSize(v),
              ),
              const Divider(),
              _SectionTitle(
                title: '行高: ${settings.lineHeight.toStringAsFixed(1)}',
              ),
              Slider(
                value: settings.lineHeight,
                min: 1.2,
                max: 2.5,
                divisions: 13,
                onChanged: (v) => settings.setLineHeight(v),
              ),
              const Divider(),
              _SectionTitle(title: '字体'),
              _FontSelector(settings: settings),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final AppSettings settings;
  const _ThemeSelector({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _ThemeButton(
            label: '日间',
            color: const Color(0xFFFDF5E6),
            textColor: Colors.brown.shade800,
            selected: settings.themeMode == 0,
            onTap: () => settings.setThemeMode(0),
          ),
          const SizedBox(width: 12),
          _ThemeButton(
            label: '夜间',
            color: const Color(0xFF1A1A1A),
            textColor: Colors.white70,
            selected: settings.themeMode == 1,
            onTap: () => settings.setThemeMode(1),
          ),
          const SizedBox(width: 12),
          _ThemeButton(
            label: '护眼',
            color: const Color(0xFFF5E6C8),
            textColor: Colors.brown.shade800,
            selected: settings.themeMode == 2,
            onTap: () => settings.setThemeMode(2),
          ),
        ],
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? Colors.brown : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _FontSelector extends StatelessWidget {
  final AppSettings settings;
  const _FontSelector({required this.settings});

  static const _fonts = [
    ('serif', '宋体'),
    ('sans-serif', '黑体'),
    ('monospace', '等宽'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: _fonts.map((f) {
          final selected = settings.fontFamily == f.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(f.$2),
              selected: selected,
              onSelected: (_) => settings.setFontFamily(f.$1),
            ),
          );
        }).toList(),
      ),
    );
  }
}
