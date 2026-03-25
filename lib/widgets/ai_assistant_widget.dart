import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
        return 'Which rides are suitable for a child? Please mention height restrictions.';
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
    final cs = Theme.of(context).colorScheme;
    return FloatingActionButton.extended(
      heroTag: 'ai_$currentTab',
      onPressed: () => _openChat(context),
      backgroundColor: cs.primary,
      icon: const Icon(Icons.smart_toy, color: Colors.white),
      label: const Text('Ask AI', style: TextStyle(color: Colors.white)),
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

  // Voice input
  final SpeechToText _speech = SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;

  // TTS output
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defaultQuestion);
    _initSpeech();
    _initTts();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (e) => setState(() => _isListening = false),
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') {
          setState(() => _isListening = false);
        }
      },
    );
    setState(() {});
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    _tts.setCompletionHandler(() => setState(() => _isSpeaking = false));
    _tts.setStartHandler(() => setState(() => _isSpeaking = true));
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) return;
    _controller.clear();
    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: 'en_US',
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
      return;
    }
    await _tts.speak(text);
  }

  @override
  void dispose() {
    _controller.dispose();
    _speech.cancel();
    _tts.stop();
    super.dispose();
  }

  Future<void> _ask() async {
    final question = _controller.text.trim();
    if (question.isEmpty) return;
    if (_isListening) await _stopListening();
    if (_isSpeaking) await _tts.stop();
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
                'minHeightCm': a.minHeightCm,
                'speedKmh': a.speedKmh,
                'inversions': a.inversions,
                'rating': a.rating,
                'topPick': a.topPick,
              })
          .toList();

      final foodData = widget.food
          .map((f) => {
                'name': f.name,
                'type': f.type,
                'description': f.description,
                'rating': f.rating,
                'topPick': f.topPick,
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
                  Expanded(
                    child: Text(
                      'AI Assistant — ${widget.parkName}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isListening) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.mic, color: Colors.red.shade600),
                            const SizedBox(width: 8),
                            Text('Listening...',
                                style: TextStyle(
                                    color: Colors.red.shade600,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
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
                        child: SelectableText(
                          _answer!,
                          style: const TextStyle(fontSize: 14, height: 1.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _answer = null;
                                _controller.clear();
                              });
                            },
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Ask another'),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () => _speak(_answer!),
                            icon: Icon(
                              _isSpeaking ? Icons.stop : Icons.volume_up,
                              size: 16,
                            ),
                            label: Text(_isSpeaking ? 'Stop' : 'Read aloud'),
                          ),
                        ],
                      ),
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
                    if (!_loading && _answer == null && _error == null && !_isListening) ...[
                      const Text(
                        'I can help you with:',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      _SuggestionChip(
                        label: 'Best rides for kids',
                        onTap: () => setState(() {
                          _controller.text =
                              'Which rides are suitable for children and what are their height requirements at ${widget.parkName}?';
                        }),
                      ),
                      _SuggestionChip(
                        label: 'Plan my day',
                        onTap: () => setState(() {
                          _controller.text =
                              'Help me plan a full day at ${widget.parkName}. I have 8 hours.';
                        }),
                      ),
                      _SuggestionChip(
                        label: 'Best value hotel',
                        onTap: () => setState(() {
                          _controller.text =
                              'Which hotel near ${widget.parkName} offers the best value for money?';
                        }),
                      ),
                      _SuggestionChip(
                        label: 'Opening hours today',
                        onTap: () => setState(() {
                          _controller.text =
                              'What are the opening hours for ${widget.parkName} today?';
                        }),
                      ),
                      _SuggestionChip(
                        label: 'Current ticket prices',
                        onTap: () => setState(() {
                          _controller.text =
                              'What are the current ticket prices for ${widget.parkName}?';
                        }),
                      ),
                    ],
                    const SizedBox(height: 80),
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
                  // Mic button
                  if (_speechAvailable)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: _isListening
                            ? Colors.red.shade100
                            : cs.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic_off : Icons.mic,
                          color: _isListening ? Colors.red : cs.primary,
                        ),
                        onPressed: _isListening ? _stopListening : _startListening,
                        tooltip: _isListening ? 'Stop listening' : 'Speak your question',
                      ),
                    ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: 3,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _ask(),
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

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 13)),
        onPressed: onTap,
        avatar: const Icon(Icons.chat_bubble_outline, size: 14),
      ),
    );
  }
}