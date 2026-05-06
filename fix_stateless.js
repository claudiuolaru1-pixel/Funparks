const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');

// Find and replace _AttractionDetailScreen class definition
// Change from StatefulWidget to StatelessWidget
c=c.replace(
  'class _AttractionDetailScreen extends StatefulWidget {',
  'class _AttractionDetailScreen extends StatelessWidget {'
);

// Remove createState method
c=c.replace(
  `  @override
  State<_AttractionDetailScreen> createState() =>
      _AttractionDetailScreenState();
}

class _AttractionDetailScreenState
    extends State<_AttractionDetailScreen> {
  late final TextEditingController _commentCtrl;
  late final TextEditingController _myWaitCtrl;
  double _rating = 4.5;
  bool _showTranslated = false;

  @override
  void initState() {
    super.initState();
    _commentCtrl = TextEditingController();
    _myWaitCtrl = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (!mounted) return;
        final app = context.read<AppState>();
        await app.ensureLoadedForAttraction(widget.attraction.id);
        final r = app.ratingForAttraction(widget.attraction.id) ?? widget.attraction.rating;
        final c = app.commentForAttraction(widget.attraction.id) ?? '';
        final myWait = app.myWaitFor(widget.attraction.id);
        if (!mounted) return;
        setState(() { _rating = r; _commentCtrl.text = c; _myWaitCtrl.text = myWait?.toString() ?? ''; });
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _myWaitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {`,
  `  @override
  Widget build(BuildContext context) {`
);

fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');
console.log('Converted to StatelessWidget:', c.includes('class _AttractionDetailScreen extends StatelessWidget') ? 'YES' : 'NO');
console.log('createState removed:', !c.includes('_AttractionDetailScreenState') ? 'YES' : 'NO');