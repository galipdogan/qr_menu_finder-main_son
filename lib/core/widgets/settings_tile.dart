import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Ayarlar sayfası için özelleştirilmiş liste öğesi
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final Color? iconColor;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: enabled
              ? (iconColor ?? ThemeProvider.primary(context))
              : ThemeProvider.textMuted(context),
        ),
        title: Text(title),
        subtitle: subtitle != null
            ? Text(subtitle!, style: const TextStyle(fontSize: 12))
            : null,
        trailing: trailing,
        onTap: enabled ? onTap : null,
        enabled: enabled,
      ),
    );
  }
}

/// Switch ile ayar öğesi
class SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      enabled: enabled,
      trailing: Switch(value: value, onChanged: enabled ? onChanged : null),
    );
  }
}

/// Radio button ile ayar öğesi
class SettingsRadioTile<T> extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final T value;
  final T groupValue;
  final ValueChanged<T?>? onChanged;
  final bool enabled;

  const SettingsRadioTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: RadioListTile<T>(
        secondary: Icon(icon, color: ThemeProvider.primary(context)),
        title: Text(title),
        subtitle: subtitle != null
            ? Text(subtitle!)
            : null, // ignore: deprecated_member_use
        value: value,
        groupValue: groupValue, // ignore: deprecated_member_use
        onChanged: enabled ? onChanged : null, // ignore: deprecated_member_use
        activeColor: ThemeProvider.primary(context),
      ),
    );
  }
}

/// Bölüm başlığı
class SettingsSectionHeader extends StatelessWidget {
  final String title;

  const SettingsSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: ThemeProvider.textSecondary(context),
        ),
      ),
    );
  }
}
