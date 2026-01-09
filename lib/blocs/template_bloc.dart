import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/templates.dart';
import '../core/models/clock_template.dart';

// Events
abstract class TemplateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTemplate extends TemplateEvent {}

class ApplyTemplate extends TemplateEvent {
  final ClockTemplate template;
  ApplyTemplate(this.template);

  @override
  List<Object?> get props => [template];
}

class CustomizeTemplate extends TemplateEvent {
  final ClockTemplate template;
  CustomizeTemplate(this.template);

  @override
  List<Object?> get props => [template];
}

// State
class TemplateState extends Equatable {
  final ClockTemplate? currentTemplate;
  final bool isLoading;
  final String? error;

  const TemplateState({
    this.currentTemplate,
    this.isLoading = false,
    this.error,
  });

  TemplateState copyWith({
    ClockTemplate? currentTemplate,
    bool? isLoading,
    String? error,
  }) {
    return TemplateState(
      currentTemplate: currentTemplate ?? this.currentTemplate,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [currentTemplate, isLoading, error];
}

// Bloc
class TemplateBloc extends Bloc<TemplateEvent, TemplateState> {
  static const String _kCurrentTemplate = 'current_template';

  TemplateBloc() : super(const TemplateState()) {
    on<LoadTemplate>(_onLoadTemplate);
    on<ApplyTemplate>(_onApplyTemplate);
    on<CustomizeTemplate>(_onCustomizeTemplate);
  }

  Future<void> _onLoadTemplate(
    LoadTemplate event,
    Emitter<TemplateState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final prefs = await SharedPreferences.getInstance();
      final templateJson = prefs.getString(_kCurrentTemplate);

      if (templateJson != null) {
        final template = ClockTemplate.fromJson(jsonDecode(templateJson));
        emit(state.copyWith(currentTemplate: template, isLoading: false));
      } else {
        // Load default minimalist template
        emit(
          state.copyWith(
            currentTemplate: TemplatePresets.minimalist,
            isLoading: false,
          ),
        );
        await _saveTemplate(TemplatePresets.minimalist);
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onApplyTemplate(
    ApplyTemplate event,
    Emitter<TemplateState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _saveTemplate(event.template);
      emit(state.copyWith(currentTemplate: event.template, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onCustomizeTemplate(
    CustomizeTemplate event,
    Emitter<TemplateState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _saveTemplate(event.template);
      emit(state.copyWith(currentTemplate: event.template, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _saveTemplate(ClockTemplate template) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCurrentTemplate, jsonEncode(template.toJson()));
  }
}
