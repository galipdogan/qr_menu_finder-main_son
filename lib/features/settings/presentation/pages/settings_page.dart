import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_menu_finder/core/theme/app_colors.dart';
import '../../../../core/error/error_messages.dart';
import '../../../../core/l10n/locale_cubit.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:qr_menu_finder/features/settings/presentation/blocs/settings_bloc.dart';
import '../../../../injection_container.dart';
import '../../../../core/theme/theme_bloc.dart';
import '../../../../core/theme/theme_event.dart';

class SettingsPage extends StatelessWidget {
  final String settingType;
  const SettingsPage({super.key, this.settingType = 'general'});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SettingsBloc>()..add(LoadSettings()),
      child: Scaffold(
        appBar: AppBar(title: const Text(ErrorMessages.settingsTitle)),
        body: BlocConsumer<SettingsBloc, SettingsState>(
          listener: (context, state) {
            if (state is SettingsFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('${ErrorMessages.errorPrefix} ${state.message}'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is SettingsLoading || state is SettingsInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SettingsLoaded) {
              return _buildSettingsList(context, state);
            }
            return const Center(child: Text(ErrorMessages.settingsLoadFailed));
          },
        ),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context, SettingsLoaded state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle(context, ErrorMessages.generalSection),
        _buildNotificationsTile(context, state),
        const Divider(),
        _buildLanguageTile(context, state),
        const Divider(),
        _buildThemeTile(context, state),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildNotificationsTile(BuildContext context, SettingsLoaded state) {
    return SwitchListTile(
      secondary: const Icon(Icons.notifications_active),
      title: const Text(ErrorMessages.notificationsTitle),
      subtitle: const Text(ErrorMessages.notificationsSubtitle),
      value: state.notificationsEnabled,
      onChanged: (value) {
        context.read<SettingsBloc>().add(NotificationsToggled(value));
      },
    );
  }

  Widget _buildLanguageTile(BuildContext context, SettingsLoaded state) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return ListTile(
          leading: const Icon(Icons.language),
          title: Text(AppLocalizations.of(context)!.languageTitle),
          subtitle: Text(locale.languageCode == 'tr' 
              ? AppLocalizations.of(context)!.turkish 
              : AppLocalizations.of(context)!.english),
          trailing: DropdownButton<String>(
            value: locale.languageCode,
            items: [
              DropdownMenuItem(
                value: 'tr', 
                child: Text(AppLocalizations.of(context)!.turkish)
              ),
              DropdownMenuItem(
                value: 'en', 
                child: Text(AppLocalizations.of(context)!.english)
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                // Update LocaleCubit for instant language change
                context.read<LocaleCubit>().changeLocale(value);
                // Also save to settings
                context.read<SettingsBloc>().add(LanguageChanged(value));
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildThemeTile(BuildContext context, SettingsLoaded state) {
    // Helper to convert string from state to ThemeMode enum
    ThemeMode stringToThemeMode(String mode) {
      switch (mode) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        default:
          return ThemeMode.system;
      }
    }

    return ListTile(
      leading: const Icon(Icons.color_lens),
      title: const Text(ErrorMessages.themeTitle),
      trailing: DropdownButton<String>(
        value: state.themeMode,
        items: const [
          DropdownMenuItem(value: 'system', child: Text(ErrorMessages.system)),
          DropdownMenuItem(value: 'light', child: Text(ErrorMessages.light)),
          DropdownMenuItem(value: 'dark', child: Text(ErrorMessages.dark)),
        ],
        onChanged: (value) {
          if (value != null) {
            // Save the setting via SettingsBloc
            context.read<SettingsBloc>().add(ThemeChanged(value));

            // Instantly update the theme via ThemeBloc
            final themeMode = stringToThemeMode(value);
            context.read<ThemeBloc>().add(ThemeChangeRequested(themeMode));
          }
        },
      ),
    );
  }
}
