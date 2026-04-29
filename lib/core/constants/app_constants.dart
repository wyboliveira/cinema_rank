// Constantes globais da aplicação.
// Prefixo "k" (de "konstant") é convenção Dart para constantes de escopo amplo.
class AppConstants {
  AppConstants._();

  // Animações
  static const Duration kAnimationFast = Duration(milliseconds: 150);
  static const Duration kAnimationNormal = Duration(milliseconds: 300);
  static const Duration kAnimationSlow = Duration(milliseconds: 500);

  // Layout
  static const double kCardBorderRadius = 12.0;
  static const double kCardElevation = 2.0;
  static const double kSpacingSmall = 8.0;
  static const double kSpacingMedium = 16.0;
  static const double kSpacingLarge = 24.0;
  static const double kMovieImageWidth = 80.0;
  static const double kMovieImageHeight = 120.0;

  // Banco de dados
  static const String kDatabaseFileName = 'cinema_rank.db';
  static const int kDatabaseVersion = 2;

  // Chave usada na tabela app_settings para a preferência de tema.
  static const String kSettingThemeKey = 'theme';
}
