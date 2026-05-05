const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');

// In _AttractionDetailScreen build - replace force-unwrap with null-safe
// Find the specific one in the detail screen build (not in other widgets)
c=c.replace(
  `  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final a = widget.attraction;`,
  `  Widget build(BuildContext context) {
    final locRaw = AppLocalizations.of(context);
    if (locRaw == null) return Scaffold(backgroundColor: Colors.white, appBar: AppBar(title: Text(widget.attraction.name)), body: const SizedBox.shrink());
    final loc = locRaw;
    final a = widget.attraction;`
);

// Also fix _FoodDetailScreen
c=c.replace(
  `  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final f = widget.food;`,
  `  Widget build(BuildContext context) {
    final locRaw = AppLocalizations.of(context);
    if (locRaw == null) return Scaffold(backgroundColor: Colors.white, appBar: AppBar(title: Text(widget.food.name)), body: const SizedBox.shrink());
    final loc = locRaw;
    final cs = Theme.of(context).colorScheme;
    final f = widget.food;`
);

fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');
console.log('Fixed:', c.includes('if (locRaw == null)') ? 'YES' : 'NO');