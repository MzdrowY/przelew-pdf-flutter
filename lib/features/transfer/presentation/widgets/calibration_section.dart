import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../settings/domain/settings_notifier.dart';

class CalibrationSection extends ConsumerStatefulWidget {
  const CalibrationSection({super.key});

  @override
  ConsumerState<CalibrationSection> createState() => _CalibrationSectionState();
}

class _CalibrationSectionState extends ConsumerState<CalibrationSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final settings = ref.watch(settingsStateProvider);
    final notifier = ref.read(settingsStateProvider.notifier);

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Text('Kalibracja PDF', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(width: 6),
                  Text('pozycje pól', style: Theme.of(context).textTheme.bodyMedium),
                  const Spacer(),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 18,
                    color: colors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            Divider(height: 1, color: colors.border),
            const SizedBox(height: 10),
            _SliderRow(
              label: 'Przesunięcie X',
              value: (settings['shift_x'] as num?)?.toDouble() ?? -2.0,
              min: -10, max: 10,
              colors: colors,
              onChanged: (v) => notifier.update({'shift_x': v}),
            ),
            _SliderRow(
              label: 'Przesunięcie Y',
              value: (settings['shift_y'] as num?)?.toDouble() ?? -1.0,
              min: -10, max: 10,
              colors: colors,
              onChanged: (v) => notifier.update({'shift_y': v}),
            ),
            _SliderRow(
              label: 'Rozmiar fontu',
              value: (settings['font_size'] as num?)?.toDouble() ?? 11,
              min: 6, max: 20,
              colors: colors,
              onChanged: (v) => notifier.update({'font_size': v}),
            ),
            _SliderRow(
              label: 'Offset Y',
              value: (settings['offset_y'] as num?)?.toDouble() ?? 3.5,
              min: -10, max: 20,
              colors: colors,
              onChanged: (v) => notifier.update({'offset_y': v}),
            ),
            _SliderRow(
              label: 'Szer. komórki',
              value: (settings['cell_w'] as num?)?.toDouble() ?? 5.0,
              min: 1, max: 10,
              colors: colors,
              onChanged: (v) => notifier.update({'cell_w': v}),
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final AppThemeColors colors;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.colors,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
                Text(value.toStringAsFixed(1), style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                )),
              ],
            ),
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: colors.primary,
              inactiveTrackColor: colors.border,
              thumbColor: colors.primary.withValues(alpha: 0.8),
              overlayColor: colors.primary.withValues(alpha: 0.08),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
