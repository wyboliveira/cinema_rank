import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import 'database_provider.dart';

// Lê o tema salvo no banco e expõe o ThemeData reativo para o app.dart.
final themeProvider =
    AsyncNotifierProvider<ThemeNotifier, AppThemeOption>(ThemeNotifier.new);

class ThemeNotifier extends AsyncNotifier<AppThemeOption> {
  @override
  Future<AppThemeOption> build() async {
    final db = ref.watch(appDatabaseProvider);
    final saved = await db.getSetting(AppConstants.kSettingThemeKey);
    // Converte a string salva de volta para o enum; padrão: blueCyan.
    return AppThemeOption.values.firstWhere(
      (o) => o.settingsValue == saved,
      orElse: () => AppThemeOption.blueCyan,
    );
  }

  Future<void> setTheme(AppThemeOption option) async {
    final db = ref.read(appDatabaseProvider);
    await db.setSetting(AppConstants.kSettingThemeKey, option.settingsValue);
    state = AsyncData(option);
  }
}
