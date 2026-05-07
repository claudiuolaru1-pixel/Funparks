const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');

// Find and replace the ENTIRE _AttractionDetailScreenState class with minimal version
const stateStart = 'class _AttractionDetailScreenState\n    extends State<_AttractionDetailScreen> {';

// Find the end of this class (before "// FOOD TAB")
const classEnd = `}

// ===============================================================
// FOOD TAB`;

const oldClass = c.substring(c.indexOf(stateStart), c.indexOf(classEnd));

const newClass = `class _AttractionDetailScreenState
    extends State<_AttractionDetailScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.attraction.name),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Text(widget.attraction.name,
            style: const TextStyle(fontSize: 24, color: Colors.black)),
      ),
    );
  }
`;

c = c.replace(oldClass, newClass);
fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');
console.log('Replaced state class');
console.log('Has TextEditingController:', c.includes('TextEditingController') ? 'YES' : 'NO');