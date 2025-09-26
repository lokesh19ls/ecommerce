import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences _sharedPreferences;

  ThemeBloc({
    required SharedPreferences sharedPreferences,
  })  : _sharedPreferences = sharedPreferences,
        super(const ThemeInitial()) {
    on<ThemeChanged>(_onThemeChanged);
    on<ThemeLoadRequested>(_onThemeLoadRequested);
    on<ThemeToggled>(_onThemeToggled);
  }

  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      await _sharedPreferences.setBool(AppConstants.themeKey, event.isDarkMode);
      emit(ThemeLoaded(isDarkMode: event.isDarkMode));
    } catch (e) {
      // If saving fails, still emit the state
      emit(ThemeLoaded(isDarkMode: event.isDarkMode));
    }
  }

  Future<void> _onThemeLoadRequested(
    ThemeLoadRequested event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final isDarkMode = _sharedPreferences.getBool(AppConstants.themeKey) ?? false;
      emit(ThemeLoaded(isDarkMode: isDarkMode));
    } catch (e) {
      emit(const ThemeLoaded(isDarkMode: false));
    }
  }

  Future<void> _onThemeToggled(
    ThemeToggled event,
    Emitter<ThemeState> emit,
  ) async {
    if (state is ThemeLoaded) {
      final currentState = state as ThemeLoaded;
      add(ThemeChanged(isDarkMode: !currentState.isDarkMode));
    } else {
      add(const ThemeChanged(isDarkMode: true));
    }
  }
}
