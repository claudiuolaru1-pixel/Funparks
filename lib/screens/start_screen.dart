// lib/screens/start_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../l10n/app_localizations.dart';
import 'app_tour_screen.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/ai_assistant_service.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});
  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final AnimationController _appearCtrl;
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
    _appearCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _player.setVolume(0.75);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _appearCtrl.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _tap() async {
    HapticFeedback.mediumImpact();
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/water_plop.wav'));
    } catch (_) {}
  }

  Widget _float(Widget child, {required double phase, double amp = 5.0}) {
    return AnimatedBuilder(
      animation: _floatCtrl,
      builder: (_, c) => Transform.translate(
        offset: Offset(0, sin((_floatCtrl.value + phase) * 2 * pi) * amp),
        child: c,
      ),
      child: child,
    );
  }

  Widget _appear(Widget child, {double delay = 0.0}) {
    final start = delay.clamp(0.0, 0.85);
    final end = (start + 0.4).clamp(0.0, 1.0);
    final anim = CurvedAnimation(
      parent: _appearCtrl,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (_, c) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, 22 * (1 - anim.value)),
          child: c,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://firebasestorage.googleapis.com/v0/b/funparks-779c6.firebasestorage.app/o/images%2Fstart_bg.png?alt=media',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: const Color(0xFF72C8FF)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.25),
                  Colors.black.withOpacity(0.78),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Title + subtitle
                  _appear(
                    Column(children: [
                      Text(
                        loc.appTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        loc.welcomeSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ]),
                    delay: 0.0,
                  ),

                  const SizedBox(height: 48),

                  // Take a Tour
                  _appear(
                    _float(
                      _OutlinedBtn(
                        icon: Icons.explore,
                        label: 'Take a Tour',
                        onTap: () async {
                          await _tap();
                          if (!mounted) return;
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const AppTourScreen()));
                        },
                      ),
                      phase: 0.0,
                    ),
                    delay: 0.15,
                  ),
                  const SizedBox(height: 12),

                  // AI Assistant
                  _appear(
                    _float(
                      _OutlinedBtn(
                        icon: Icons.smart_toy,
                        label: 'Ask AI Assistant',
                        onTap: () async {
                          await _tap();
                          if (!mounted) return;
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const _GlobalAiSheet(),
                          );
                        },
                      ),
                      phase: 0.18,
                    ),
                    delay: 0.25,
                  ),
                  const SizedBox(height: 12),

                  // Continue without account
                  _appear(
                    _float(
                      _PressBtn(
                        onTap: () async {
                          await _tap();
                          if (!mounted) return;
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                loc.continueWithoutAccount,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      phase: 0.36,
                    ),
                    delay: 0.35,
                  ),
                  const SizedBox(height: 12),

                  // Register
                  _appear(
                    _float(
                      _PressBtn(
                        onTap: () async {
                          await _tap();
                          if (!mounted) return;
                          Navigator.pushNamed(context, '/signin',
                              arguments: 'register');
                        },
                        child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                loc.registerAccount,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3)),
                        ),
                      ),
                      phase: 0.54,
                    ),
                    delay: 0.45,
                  ),
                  const SizedBox(height: 8),

                  // Login
                  _appear(
                    _float(
                      _PressBtn(
                        onTap: () async {
                          await _tap();
                          if (!mounted) return;
                          Navigator.pushNamed(context, '/signin');
                        },
                        decoration: const BoxDecoration(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Text(
                            loc.login,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 15),
                          ),
                        ),
                      ),
                      phase: 0.72,
                      amp: 3.5,
                    ),
                    delay: 0.55,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Outlined button helper ────────────────────────────────────────────────
class _OutlinedBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _OutlinedBtn(
      {required this.icon, required this.label, required this.onTap});
  @override
  State<_OutlinedBtn> createState() => _OutlinedBtnState();
}

class _OutlinedBtnState extends State<_OutlinedBtn> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.963 : 1.0,
        duration: const Duration(milliseconds: 90),
        child: AnimatedOpacity(
          opacity: _down ? 0.85 : 1.0,
          duration: const Duration(milliseconds: 90),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: Colors.white.withOpacity(_down ? 0.9 : 0.6),
                  width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(widget.label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Generic press-scale wrapper ──────────────────────────────────────────
class _PressBtn extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final BoxDecoration decoration;
  const _PressBtn(
      {required this.child,
      required this.onTap,
      required this.decoration});
  @override
  State<_PressBtn> createState() => _PressBtnState();
}

class _PressBtnState extends State<_PressBtn> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.963 : 1.0,
        duration: const Duration(milliseconds: 90),
        child: AnimatedOpacity(
          opacity: _down ? 0.85 : 1.0,
          duration: const Duration(milliseconds: 90),
          child: DecoratedBox(
            decoration: widget.decoration,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// ─── Global AI Sheet (unchanged logic) ───────────────────────────────────
class _GlobalAiSheet extends StatefulWidget {
  const _GlobalAiSheet();
  @override
  State<_GlobalAiSheet> createState() => _GlobalAiSheetState();
}

class _GlobalAiSheetState extends State<_GlobalAiSheet> {
  final TextEditingController _controller = TextEditingController(
      text: 'Which European theme park should I visit with my family?');
  String? _answer;
  bool _loading = false;
  String? _error;
  final SpeechToText _speech = SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      _speechAvailable = await _speech.initialize(
          onError: (e) => setState(() => _isListening = false),
          onStatus: (s) {
            if (s == 'done' || s == 'notListening')
              setState(() => _isListening = false);
          });
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      _tts.setCompletionHandler(() => setState(() => _isSpeaking = false));
      _tts.setStartHandler(() => setState(() => _isSpeaking = true));
      setState(() {});
    });
  }

  @override
  void dispose() {
    _speech.cancel();
    _tts.stop();
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
      final answer = await AiAssistantService.ask(
        question: question,
        parkName: 'Multiple European Theme Parks',
        parkWebsite: 'https://funparks.app',
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
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
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
                  const Expanded(
                    child: Text('Funparks AI Assistant',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
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
                        child: SelectableText(_answer!,
                            style: const TextStyle(
                                fontSize: 14, height: 1.6)),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () => setState(() {
                          _answer = null;
                          _controller.clear();
                        }),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Ask another question'),
                      ),
                    ],
                    if (_answer != null)
                      TextButton.icon(
                        onPressed: () async {
                          if (_isSpeaking) {
                            await _tts.stop();
                            setState(() => _isSpeaking = false);
                          } else {
                            await _tts.speak(_answer!);
                          }
                        },
                        icon: Icon(
                            _isSpeaking ? Icons.stop : Icons.volume_up,
                            size: 16),
                        label:
                            Text(_isSpeaking ? 'Stop' : 'Read aloud'),
                      ),
                    if (_error != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(_error!,
                            style:
                                TextStyle(color: Colors.red.shade700)),
                      ),
                    if (_loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text('Thinking...',
                                style: TextStyle(color: Colors.grey)),
                          ]),
                        ),
                      ),
                    if (!_loading && _answer == null && _error == null) ...[
                      const Text('I can help you with:',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 8),
                      _chip(
                          'Best park for thrill seekers in Europe',
                          () => setState(() => _controller.text =
                              'What is the best European theme park for thrill seekers?')),
                      _chip(
                          'Best park for families with young children',
                          () => setState(() => _controller.text =
                              'Which European theme park is best for families with young children?')),
                      _chip(
                          'Best water park in Europe',
                          () => setState(() => _controller.text =
                              'What is the best water park in Europe to visit?')),
                      _chip(
                          'Compare Phantasialand vs Europa-Park',
                          () => setState(() => _controller.text =
                              'Compare Phantasialand and Europa-Park — which should I visit?')),
                      _chip(
                          'Best time to visit Tivoli Gardens',
                          () => setState(() => _controller.text =
                              'What is the best time of year to visit Tivoli Gardens in Copenhagen?')),
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
                      offset: const Offset(0, -2)),
                ],
              ),
              child: Row(
                children: [
                  if (_speechAvailable)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: _isListening
                            ? Colors.red.shade100
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                            _isListening ? Icons.mic_off : Icons.mic,
                            color: _isListening
                                ? Colors.red
                                : Colors.grey.shade700),
                        onPressed: () async {
                          if (_isListening) {
                            await _speech.stop();
                            setState(() => _isListening = false);
                          } else {
                            _controller.clear();
                            setState(() => _isListening = true);
                            await _speech.listen(
                              onResult: (r) => setState(() =>
                                  _controller.text = r.recognizedWords),
                              listenFor: const Duration(seconds: 30),
                              pauseFor: const Duration(seconds: 3),
                            );
                          }
                        },
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
                        hintText: 'Ask anything about theme parks...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
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
                          borderRadius: BorderRadius.circular(12)),
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

  Widget _chip(String label, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: ActionChip(
          label: Text(label, style: const TextStyle(fontSize: 13)),
          onPressed: onTap,
          avatar: const Icon(Icons.chat_bubble_outline, size: 14),
        ),
      );
}
