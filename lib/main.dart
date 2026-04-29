import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/utils/logger.dart';

void main() {
  // 📖 WidgetsFlutterBinding inicializa o binding Flutter antes de qualquer
  // operação assíncrona (ex: abertura do banco de dados).
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.info('Iniciando cinema_rank');

  // 📖 ProviderScope é o contêiner raiz do Riverpod. Todos os providers
  // ficam disponíveis para a árvore de widgets abaixo dele.
  runApp(const ProviderScope(child: CinemaRankApp()));
}
