import 'package:flutter/material.dart';
import '../services/ai_assistant_service.dart';
import '../models/attraction.dart';
import '../models/food_place.dart';
import '../models/hotel.dart';

class AiAssistantButton extends StatelessWidget {
  final String parkName;
  final String parkWebsite;
  final String currentTab;
  final List<Attraction> attractions;
  final List<FoodPlace> food;
  final List<Hotel> hotels;

  const AiAssistantButton({
    super.key,
    required this.parkName,
    required this.parkWebsite,
    required this.currentTab,
    this.attractions = const [],
    this.food = const [],
    this.hotels = const [],
  });

  String _defaultQuestion() {
    switch (currentTab) {
      case 'overview':
        return 'What is the best time of year to visit $parkName?';
      case 'attractions':
        return 'Which rides are suitable for a child? Please tell me their height restrictions.';
      case 'restaurants':
        return 'What is the best restaurant for a family with children at $parkName?';
      case 'hotels':
        return 'Which hotel offers the best value near $parkName?';
      default:
        return 'What can you tell me about $parkName?';
    }
  }

  void _openChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AiChatSheet(
        parkName: parkName,
        parkWebsite: parkWebsite,
        defaultQuestion: _defaultQuestion(),
        attractions: attractions,
        food: food,
        hotels: hotels,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'ai_$currentTab',
      onPressed: () => _openChat(context),
      backgroundColor: Theme.of(context).colorScheme.primary,
      tooltip: 'Ask AI Assistant',
      child: const Icon(Icons.smart_toy, color: Colors.white),
    );
  }
}

class _AiChatSheet extends StatefulWidget {
  final String parkName;
  final String parkWebsite;
  final String defaultQuestion;
  final List<Attraction> attractions;
  final List<FoodPlace> food;
  final List<Hotel> hotels;

  const _AiChatSheet({
    required this.parkName,
    required this.parkWebsite,
    required this.defaultQuestion,
    required this.attractions,
    required this.food,
    required this.hotels,
  });

  @override
  State<_AiChatSheet> createState() => _AiChatSheetState();
}

class _AiChatSheetState extends State<_AiChatSheet> {
  late TextEditingController _controller;
  String? _answer;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defaultQuestion);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    final question = _controller.text.trim();
    if (question.isEmpty) return;
    setState(() {
      _loading = true;
      _answer = null;
      _error = null;
    });
    try {
      final attractionsData = widget.attractions
          .map((a) => {
                'name': a.name,
                'description': a.description,
                'category': a.category,
                'heightM': a.heightM,
                'speedKmh': a.speedKmh,
                'inversions': a.inversions,
                'rating': a.rating,
              })
          .toList();

      final foodData = widget.food
          .map((f) => {
                'name': f.name,
                'type': f.type,
                'description': f.description,
                'rating': f.rating,
              })
          .toList();

      final hotelsData = widget.hotels
          .map((h) => {
                'name': h.name,
                'description': h.description,
                'rating': h.rating,
                'lowestNightPrice': h.lowestNightPrice,
              })
          .toList();

      final answer = await AiAssistantService.ask(
        question: question,
        parkName: widget.parkName,
        parkWebsite: widget.parkWebsite,
        attractions: attractionsData,
        restaurants: foodData,
        hotels: hotelsData,
      );
      setState(() {
        _answer = answer;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Sorry, something went wrong. Please try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.smart_toy, color: cs.primary),
                  const SizedBox(width: 8),
                  Text(
                    'AI Assistant — ${widget.parkName}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_answer != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: cs.primary.withOpacity(0.2)),
                        ),
                        child: Text(
                          _answer!,
                          style: const TextStyle(
                              fontSize: 14, height: 1.6),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_error != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(_error!,
                            style: TextStyle(color: Colors.red.shade700)),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_loading) ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 12),
                              Text('Thinking...',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 8,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: 3,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Ask anything about this park...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _loading ? null : _ask,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}