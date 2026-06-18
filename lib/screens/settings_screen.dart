import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, settings, _) {
        final mode = settings.themeMode;

        return Scaffold(
          backgroundColor: AppTheme.scaffoldBg(mode),
          appBar: AppBar(
            title: Text(
              '设置',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary(mode),
              ),
            ),
          ),
          body: ListView(
            children: [
              _buildSection(context, '阅读模式', mode, [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      _ModeChip(
                        icon: Icons.swipe,
                        label: '翻页',
                        selected: settings.readingMode == 0,
                        mode: mode,
                        onTap: () => settings.setReadingMode(0),
                      ),
                      const SizedBox(width: 12),
                      _ModeChip(
                        icon: Icons.swap_vert,
                        label: '滚动',
                        selected: settings.readingMode == 1,
                        mode: mode,
                        onTap: () => settings.setReadingMode(1),
                      ),
                    ],
                  ),
                ),
              ]),
              _buildDivider(mode),
              _buildSection(context, '字体大小', mode, [
                Row(
                  children: [
                    Text('A',
                        style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary(mode))),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: AppTheme.accent(mode),
                          inactiveTrackColor: AppTheme.divider(mode),
                          thumbColor: AppTheme.accent(mode),
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6),
                          trackHeight: 2,
                        ),
                        child: Slider(
                          value: settings.fontSize,
                          min: 14,
                          max: 28,
                          divisions: 14,
                          onChanged: (v) => settings.setFontSize(v),
                        ),
                      ),
                    ),
                    Text('A',
                        style: TextStyle(
                            fontSize: 22,
                            color: AppTheme.textSecondary(mode))),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${settings.fontSize.round()}',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary(mode),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ]),
              _buildDivider(mode),
              _buildSection(context, '行高', mode, [
                Row(
                  children: [
                    Icon(Icons.format_line_spacing,
                        size: 18, color: AppTheme.textSecondary(mode)),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: AppTheme.accent(mode),
                          inactiveTrackColor: AppTheme.divider(mode),
                          thumbColor: AppTheme.accent(mode),
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6),
                          trackHeight: 2,
                        ),
                        child: Slider(
                          value: settings.lineHeight,
                          min: 1.2,
                          max: 2.5,
                          divisions: 13,
                          onChanged: (v) => settings.setLineHeight(v),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 28,
                      child: Text(
                        settings.lineHeight.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary(mode),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ]),
              _buildDivider(mode),
              _buildSection(context, '字体', mode, [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      _FontChip(
                        label: '宋体',
                        selected: settings.fontFamily == 'serif',
                        mode: mode,
                        onTap: () => settings.setFontFamily('serif'),
                      ),
                      const SizedBox(width: 8),
                      _FontChip(
                        label: '黑体',
                        selected: settings.fontFamily == 'sans-serif',
                        mode: mode,
                        onTap: () => settings.setFontFamily('sans-serif'),
                      ),
                      const SizedBox(width: 8),
                      _FontChip(
                        label: '等宽',
                        selected: settings.fontFamily == 'monospace',
                        mode: mode,
                        onTap: () => settings.setFontFamily('monospace'),
                      ),
                    ],
                  ),
                ),
              ]),
              _buildDivider(mode),
              _buildSection(context, '亮度', mode, [
                Row(
                  children: [
                    Icon(Icons.brightness_low,
                        size: 18, color: AppTheme.textSecondary(mode)),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: AppTheme.accent(mode),
                          inactiveTrackColor: AppTheme.divider(mode),
                          thumbColor: AppTheme.accent(mode),
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6),
                          trackHeight: 2,
                        ),
                        child: Slider(
                          value: settings.brightness,
                          min: 0.1,
                          max: 1.0,
                          divisions: 9,
                          onChanged: (v) => settings.setBrightness(v),
                        ),
                      ),
                    ),
                    Icon(Icons.brightness_high,
                        size: 18, color: AppTheme.textSecondary(mode)),
                  ],
                ),
              ]),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(
      BuildContext context, String title, int mode, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary(mode),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDivider(int mode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(color: AppTheme.divider(mode), height: 24),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final int mode;
  final VoidCallback onTap;

  const _ModeChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.mode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.accent(mode).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppTheme.accent(mode) : AppTheme.divider(mode),
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: selected
                    ? AppTheme.accent(mode)
                    : AppTheme.textSecondary(mode)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? AppTheme.accent(mode)
                    : AppTheme.textPrimary(mode),
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FontChip extends StatelessWidget {
  final String label;
  final bool selected;
  final int mode;
  final VoidCallback onTap;

  const _FontChip({
    required this.label,
    required this.selected,
    required this.mode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.accent(mode).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppTheme.accent(mode) : AppTheme.divider(mode),
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color:
                selected ? AppTheme.accent(mode) : AppTheme.textPrimary(mode),
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
