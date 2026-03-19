// lib/screens/my_day_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models/my_day_item.dart';

class MyDayScreen extends StatelessWidget {
  const MyDayScreen({super.key});

  IconData _iconForType(MyDayItemType t) {
    switch (t) {
      case MyDayItemType.attraction: return Icons.roller_skating;
      case MyDayItemType.restaurant: return Icons.restaurant;
      case MyDayItemType.hotel: return Icons.hotel;
    }
  }

  Color _colorForType(MyDayItemType t, BuildContext context) {
    switch (t) {
      case MyDayItemType.attraction: return Colors.deepPurple;
      case MyDayItemType.restaurant: return Colors.orange;
      case MyDayItemType.hotel: return Colors.teal;
    }
  }

  String _labelForType(MyDayItemType t) {
    switch (t) {
      case MyDayItemType.attraction: return 'Attraction';
      case MyDayItemType.restaurant: return 'Restaurant';
      case MyDayItemType.hotel: return 'Hotel';
    }
  }

  Future<void> _editMinutes(BuildContext context, AppState app, MyDayItem item) async {
    final controller = TextEditingController(text: item.estimatedMinutes.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Time for ${item.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Minutes',
            suffixText: 'min',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final v = int.tryParse(controller.text.trim());
              if (v != null && v > 0) Navigator.pop(ctx, v);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) {
      app.updateMyDayItemMinutes(item.id, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final items = app.myDayItems;
    final totalMinutes = app.myDayTotalMinutes;
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    final totalLabel = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Day'),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear My Day'),
                    content: const Text('Remove all items from your day?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear')),
                    ],
                  ),
                );
                if (confirm == true) {
                  for (final item in List.from(items)) {
                    app.removeFromMyDay(item.id);
                  }
                }
              },
              child: const Text('Clear all'),
            ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wb_sunny_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('Your day is empty',
                      style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('Add attractions, restaurants and hotels\nfrom the park tabs.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, size: 18),
                      const SizedBox(width: 8),
                      Text('Total estimated time: $totalLabel',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Text('${items.length} item${items.length == 1 ? '' : 's'}',
                          style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    onReorder: (oldIndex, newIndex) {
                      if (newIndex > oldIndex) newIndex--;
                      final appWrite = context.read<AppState>();
                      final list = List<MyDayItem>.from(appWrite.myDayItems);
                      final item = list.removeAt(oldIndex);
                      list.insert(newIndex, item);
                      appWrite.reorderMyDay(list);
                    },
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final color = _colorForType(item.type, context);
                      return Card(
                        key: ValueKey(item.id),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color.withOpacity(0.15),
                            child: Icon(_iconForType(item.type), color: color, size: 20),
                          ),
                          title: Text(item.name,
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(_labelForType(item.type)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => _editMinutes(context, context.read<AppState>(), item),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: color.withOpacity(0.1),
                                    border: Border.all(color: color.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('${item.estimatedMinutes}m',
                                          style: TextStyle(fontWeight: FontWeight.w700, color: color)),
                                      const SizedBox(width: 4),
                                      Icon(Icons.edit, size: 12, color: color),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                onPressed: () => context.read<AppState>().removeFromMyDay(item.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}