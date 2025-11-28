import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/quote_bloc.dart';

class QuoteWidget extends StatefulWidget {
  const QuoteWidget({super.key});

  @override
  State<QuoteWidget> createState() => _QuoteWidgetState();
}

class _QuoteWidgetState extends State<QuoteWidget> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<QuoteBloc>().add(LoadQuotes());
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Quote', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            BlocBuilder<QuoteBloc, QuoteState>(
              builder: (context, state) {
                if (state.quotes.isEmpty) return const Text('No quotes');
                final q =
                    state.quotes[state.selectedIndex.clamp(
                      0,
                      state.quotes.length - 1,
                    )];
                return Column(
                  children: [
                    Text(q),
                    const SizedBox(height: 8),
                    Text('(${state.selectedIndex + 1}/${state.quotes.length})'),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Add quote'),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final t = _controller.text.trim();
                    if (t.isNotEmpty) {
                      context.read<QuoteBloc>().add(AddQuote(t));
                      _controller.clear();
                    }
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
