/// Main dashboard page.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/edith_theme.dart';
import 'dashboard_state.dart';
import 'providers/dashboard_providers.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.edithTheme;
    final battery = ref.watch(batteryInfoProvider);
    final components = ref.watch(componentStatusesProvider);
    final unavailableCount = components
        .where((component) =>
            component.id != 'battery' &&
            component.dataSource == DataSource.unavailable)
        .length;

    return Scaffold(
      backgroundColor: theme.colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: theme.colors.accentStrong,
          backgroundColor: theme.colors.panel,
          onRefresh: () async {
            ref.invalidate(batteryInfoProvider);
            ref.invalidate(connectivityInfoProvider);
            ref.invalidate(visionStatusProvider);
            ref.invalidate(aiEngineStatusProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  theme.spacing.md,
                  theme.spacing.md,
                  theme.spacing.md,
                  theme.spacing.xxl,
                ),
                sliver: SliverList.list(
                  children: [
                    _Header(theme: theme),
                    SizedBox(height: theme.spacing.xl),
                    _BatteryPanel(theme: theme, battery: battery),
                    SizedBox(height: theme.spacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'SYSTEMS',
                            style: theme.typography.labelMedium.copyWith(
                              color: theme.colors.textMuted,
                              letterSpacing: 1.6,
                            ),
                          ),
                        ),
                        Text(
                          '$unavailableCount NOT CONNECTED',
                          style: theme.typography.labelSmall.copyWith(
                            color: theme.colors.textMuted,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: theme.spacing.sm),
                    for (final component in components.where(
                      (component) => component.id != 'battery',
                    )) ...[
                      _SystemRow(theme: theme, component: component),
                      SizedBox(height: theme.spacing.sm),
                    ],
                    SizedBox(height: theme.spacing.md),
                    Text(
                      'Only readings available from this phone are shown. Other systems need an active integration.',
                      style: theme.typography.bodySmall.copyWith(
                        color: theme.colors.textMuted,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.theme});

  final EdithThemeExtension theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.colors.panel,
            borderRadius: BorderRadius.circular(theme.radius.md),
            border: Border.all(color: theme.colors.panelBorder),
          ),
          child: Center(
            child: Image.asset(
              'assets/brand/edith_icon.png',
              width: 30,
              height: 30,
              errorBuilder: (_, _, _) => Icon(
                Icons.remove_red_eye_outlined,
                size: 25,
                color: theme.colors.accentStrong,
              ),
            ),
          ),
        ),
        SizedBox(width: theme.spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('E.D.I.T.H.', style: theme.typography.titleLarge),
              SizedBox(height: theme.spacing.xs),
              Text(
                'DEVICE OVERVIEW',
                style: theme.typography.labelSmall.copyWith(
                  color: theme.colors.textMuted,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Refresh device readings',
          onPressed: () {
            final container = ProviderScope.containerOf(context);
            container.invalidate(batteryInfoProvider);
            container.invalidate(connectivityInfoProvider);
            container.invalidate(visionStatusProvider);
            container.invalidate(aiEngineStatusProvider);
          },
          icon: Icon(Icons.refresh, color: theme.colors.textSecondary),
        ),
      ],
    );
  }
}

class _BatteryPanel extends StatelessWidget {
  const _BatteryPanel({required this.theme, required this.battery});

  final EdithThemeExtension theme;
  final AsyncValue<BatteryInfo> battery;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(theme.spacing.lg),
      decoration: BoxDecoration(
        color: theme.colors.panel,
        borderRadius: BorderRadius.circular(theme.radius.lg),
        border: Border.all(color: theme.colors.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.battery_5_bar, color: theme.colors.accentStrong),
              SizedBox(width: theme.spacing.sm),
              Expanded(
                child: Text('PHONE BATTERY',
                    style: theme.typography.labelMedium.copyWith(
                      color: theme.colors.textSecondary,
                      letterSpacing: 1.1,
                    )),
              ),
              battery.whenOrNull(
                        data: (value) => value.source == DataSource.live,
                      ) ==
                      true
                  ? _LiveTag(theme: theme)
                  : Text(
                      'DEVICE',
                      style: theme.typography.labelSmall.copyWith(
                        color: theme.colors.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
            ],
          ),
          SizedBox(height: theme.spacing.lg),
          battery.when(
            data: (value) => value.source == DataSource.live
                ? _BatteryReading(theme: theme, value: value)
                : _UnavailableBattery(theme: theme),
            loading: () => _BatteryLoading(theme: theme),
            error: (_, _) => _UnavailableBattery(theme: theme),
          ),
        ],
      ),
    );
  }
}

class _BatteryReading extends StatelessWidget {
  const _BatteryReading({required this.theme, required this.value});

  final EdithThemeExtension theme;
  final BatteryInfo value;

  @override
  Widget build(BuildContext context) {
    final percent = (value.level * 100).round();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 78,
          height: 78,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value.level.clamp(0, 1),
                strokeWidth: 5,
                strokeCap: StrokeCap.round,
                backgroundColor: theme.colors.surface,
                valueColor: AlwaysStoppedAnimation(theme.colors.accentStrong),
              ),
              Icon(
                value.isCharging ? Icons.bolt : Icons.battery_full,
                color: theme.colors.accentStrong,
              ),
            ],
          ),
        ),
        SizedBox(width: theme.spacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$percent%', style: theme.typography.displaySmall),
              SizedBox(height: theme.spacing.xs),
              Text(
                value.isCharging ? 'Charging' : 'On battery',
                style: theme.typography.bodyMedium.copyWith(
                  color: theme.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BatteryLoading extends StatelessWidget {
  const _BatteryLoading({required this.theme});
  final EdithThemeExtension theme;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: theme.colors.accentStrong,
        ),
      ),
      SizedBox(width: theme.spacing.md),
      Text('Reading phone battery…', style: theme.typography.bodyMedium),
    ],
  );
}

class _UnavailableBattery extends StatelessWidget {
  const _UnavailableBattery({required this.theme});
  final EdithThemeExtension theme;

  @override
  Widget build(BuildContext context) => Text(
    'Battery reading is unavailable on this device.',
    style: theme.typography.bodyMedium.copyWith(color: theme.colors.textMuted),
  );
}

class _LiveTag extends StatelessWidget {
  const _LiveTag({required this.theme});
  final EdithThemeExtension theme;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colors.success,
        ),
      ),
      SizedBox(width: theme.spacing.xs),
      Text(
        'LIVE',
        style: theme.typography.labelSmall.copyWith(
          color: theme.colors.success,
          letterSpacing: 0.8,
        ),
      ),
    ],
  );
}

class _SystemRow extends StatelessWidget {
  const _SystemRow({required this.theme, required this.component});

  final EdithThemeExtension theme;
  final ComponentStatus component;

  @override
  Widget build(BuildContext context) {
    final available = component.dataSource == DataSource.live;
    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing.md,
        vertical: theme.spacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colors.panel,
        borderRadius: BorderRadius.circular(theme.radius.md),
        border: Border.all(color: theme.colors.panelBorder),
      ),
      child: Row(
        children: [
          Icon(component.icon, size: 21, color: theme.colors.textMuted),
          SizedBox(width: theme.spacing.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(component.name, style: theme.typography.titleSmall),
                SizedBox(height: theme.spacing.xs),
                Text(
                  component.subtitle ?? 'No status reported',
                  style: theme.typography.bodySmall.copyWith(
                    color: theme.colors.textMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: theme.spacing.sm),
          Text(
            available ? 'CONNECTED' : 'NOT CONNECTED',
            style: theme.typography.labelSmall.copyWith(
              color: available ? theme.colors.success : theme.colors.textMuted,
              letterSpacing: 0.35,
            ),
          ),
        ],
      ),
    );
  }
}
