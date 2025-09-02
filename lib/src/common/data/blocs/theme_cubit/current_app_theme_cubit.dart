import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_journal/src/common/common.dart';

class CurrentAppThemeCubit extends Cubit<CurrentAppTheme> {
  final CurrentAppThemeService _currentAppThemeService;

  CurrentAppThemeCubit({
    required CurrentAppThemeService currentAppThemeService,
  })  : _currentAppThemeService = currentAppThemeService,
        super(CurrentAppTheme.system) {
    loadCurrentAppTheme();
  }

  Future<void> loadCurrentAppTheme() async {
    final theme = await _currentAppThemeService.getCurrentAppTheme();
    emit(theme);
  }

  Future<void> updateCurrentAppTheme(String themeName) async {
    await _currentAppThemeService.setCurrentAppTheme(themeName);
    await loadCurrentAppTheme();
  }
}
