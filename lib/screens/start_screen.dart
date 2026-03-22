import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'app_tour_screen.dart';
import '../widgets/ai_assistant_widget.dart';
import '../services/ai_assistant_service.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network('https://firebasestorage.googleapis.com/v0/b/funparks-779c6.firebasestorage.app/o/images%2Fstart_bg.png?alt=media', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF72C8FF))),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.75),
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
                  Text(
                    loc.appTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
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
                  const SizedBox(height: 48),

                  // Take a Tour
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AppTourScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.explore, color: Colors.white),
                      label: const Text(
                        'Take a Tour',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                            color: Colors.white.withOpacity(0.6), width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                    // AI Assistant
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const _GlobalAiSheet(),
                        ),
                        icon: const Icon(Icons.smart_toy, color: Colors.white),
                        label: const Text(
                          'Ask AI Assistant',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                              color: Colors.white.withOpacity(0.6), width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                  // Continue without account
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/home'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      child: Text(loc.continueWithoutAccount,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Register
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pushNamed(context, '/signin',
                          arguments: 'register'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.white.withOpacity(0.15),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(loc.registerAccount,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Login
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/signin'),
                    child: Text(
                      loc.login,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.75), fontSize: 15),
                    ),
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
                  const Expanded(
                    child: Text(
                      'Funparks AI Assistant',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                    if (_answer != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cs.primary.withOpacity(0.2)),
                        ),
                        child: SelectableText(
                          _answer!,
                          style: const TextStyle(fontSize: 14, height: 1.6),
                        ),
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
                    ],
                    if (_loading) ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 12),
                              Text('Thinking...', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (!_loading && _answer == null && _error == null) ...[
                      const Text('I can help you with:',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 8),
                      _chip('Best park for thrill seekers in Europe', () => setState(() =>
                          _controller.text = 'What is the best European theme park for thrill seekers?')),
                      _chip('Best park for families with young children', () => setState(() =>
                          _controller.text = 'Which European theme park is best for families with young children?')),
                      _chip('Best water park in Europe', () => setState(() =>
                          _controller.text = 'What is the best water park in Europe to visit?')),
                      _chip('Compare Phantasialand vs Europa-Park', () => setState(() =>
                          _controller.text = 'Compare Phantasialand and Europa-Park — which should I visit?')),
                      _chip('Best time to visit Tivoli Gardens', () => setState(() =>
                          _controller.text = 'What is the best time of year to visit Tivoli Gardens in Copenhagen?')),
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

  Widget _chip(String label, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 13)),
      onPressed: onTap,
      avatar: const Icon(Icons.chat_bubble_outline, size: 14),
    ),
  );
}
