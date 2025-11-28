import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuoteState extends Equatable {
  final List<String> quotes;
  final int selectedIndex;

  const QuoteState({required this.quotes, required this.selectedIndex});

  QuoteState copyWith({List<String>? quotes, int? selectedIndex}) => QuoteState(
    quotes: quotes ?? this.quotes,
    selectedIndex: selectedIndex ?? this.selectedIndex,
  );

  @override
  List<Object?> get props => [quotes, selectedIndex];
}

abstract class QuoteEvent {}

class LoadQuotes extends QuoteEvent {}

class AddQuote extends QuoteEvent {
  final String text;
  AddQuote(this.text);
}

class RemoveQuote extends QuoteEvent {
  final int index;
  RemoveQuote(this.index);
}

class SelectQuote extends QuoteEvent {
  final int index;
  SelectQuote(this.index);
}

class QuoteBloc extends Bloc<QuoteEvent, QuoteState> {
  static const _kKey = 'user_quotes';

  QuoteBloc() : super(const QuoteState(quotes: [], selectedIndex: 0)) {
    on<LoadQuotes>(_onLoad);
    on<AddQuote>(_onAdd);
    on<RemoveQuote>(_onRemove);
    on<SelectQuote>(_onSelect);
  }

  Future<void> _onLoad(LoadQuotes e, Emitter<QuoteState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kKey) ?? ['Keep going!', 'Carpe diem'];
    emit(QuoteState(quotes: list, selectedIndex: 0));
  }

  Future<void> _onAdd(AddQuote e, Emitter<QuoteState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final newList = List<String>.from(state.quotes)..add(e.text);
    await prefs.setStringList(_kKey, newList);
    emit(state.copyWith(quotes: newList));
  }

  Future<void> _onRemove(RemoveQuote e, Emitter<QuoteState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final newList = List<String>.from(state.quotes)..removeAt(e.index);
    await prefs.setStringList(_kKey, newList);
    final newIndex = state.selectedIndex.clamp(0, newList.length - 1);
    emit(state.copyWith(quotes: newList, selectedIndex: newIndex));
  }

  Future<void> _onSelect(SelectQuote e, Emitter<QuoteState> emit) async {
    emit(state.copyWith(selectedIndex: e.index));
  }
}
