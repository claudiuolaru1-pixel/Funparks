import 'package:flutter/material.dart';

class AppTourScreen extends StatefulWidget {
  const AppTourScreen({super.key});

  @override
  State<AppTourScreen> createState() => _AppTourScreenState();
}

class _AppTourScreenState extends State<AppTourScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  static const _slides = [
    _TourSlide(
      icon: Icons.explore,
      color: Color(0xFF2196F3),
      title: 'Welcome to Funparks',
      body: 'Funparks is your all-in-one guide to theme parks around the world. Browse parks, track wait times, and explore hundreds of destinations across every continent.',
    ),
    _TourSlide(
      icon: Icons.map,
      color: Color(0xFF4CAF50),
      title: 'Pick a Park',
      body: 'On the home screen you will see a map with park pins. Tap any pin or scroll the list below the map to select a park and open its detail page.',
    ),
    _TourSlide(
      icon: Icons.info_outline,
      color: Color(0xFF9C27B0),
      title: 'Overview Tab',
      body: 'Every park has an Overview tab showing opening hours, entry prices, location and highlights. Use the Directions button to get there with Google Maps.',
    ),
    _TourSlide(
      icon: Icons.confirmation_number,
      color: Color(0xFFFF5722),
      title: 'Buy Tickets',
      body: 'The "Buy Tickets" button takes you directly to the park\'s official website. It is the same as visiting the park\'s own site — the safest place to book.',
    ),
    _TourSlide(
      icon: Icons.roller_skating,
      color: Color(0xFFE91E63),
      title: 'Attractions',
      body: 'The Attractions tab lists all rides with live wait times, ratings and categories. Sort by lowest wait or highest rated. Tap any ride for full details.',
    ),
    _TourSlide(
      icon: Icons.notifications_active,
      color: Color(0xFFFFC107),
      title: 'Wait Time Alerts',
      body: 'Tap the bell icon next to any ride''s wait time and set a threshold. You will get a notification the moment the wait drops below it, so you never have to keep checking.',
    ),
    _TourSlide(
      icon: Icons.wb_sunny_outlined,
      color: Color(0xFFFF9800),
      title: 'My Day',
      body: 'Tap the heart icon on any attraction, restaurant or hotel to add it to My Day. Then use the Route button to get a walking route through your picks.',
    ),
    _TourSlide(
      icon: Icons.restaurant,
      color: Color(0xFF00BCD4),
      title: 'Food & Hotels',
      body: 'Browse on-site restaurants with menus and prices, and on-site hotels with room types and nightly rates — all without leaving the app.',
    ),
    _TourSlide(
      icon: Icons.language,
      color: Color(0xFF607D8B),
      title: 'Switch Language',
      body: 'Funparks supports 10 languages. Tap the Settings icon inside any park page to switch language. All descriptions, overviews and tips will update instantly.',
    ),
    _TourSlide(
      icon: Icons.person_outline,
      color: Color(0xFF795548),
      title: 'Account (Optional)',
      body: 'You can use Funparks without an account. Register if you want to save your favourites and reviews across devices. You can always register later.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  const SizedBox(width: 48),
                  const Spacer(),
                  Text(
                    ' / ',
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Skip tour',
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) => _SlidePage(slide: _slides[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final active = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: active
                          ? _slides[_currentPage].color
                          : Colors.grey.shade300,
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(
                    backgroundColor: _slides[_currentPage].color,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    isLast ? 'Got it!' : 'Next',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TourSlide {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _TourSlide({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });
}

class _SlidePage extends StatelessWidget {
  final _TourSlide slide;
  const _SlidePage({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: slide.color.withOpacity(0.12),
            ),
            child: Icon(slide.icon, size: 52, color: slide.color),
          ),
          const SizedBox(height: 36),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
