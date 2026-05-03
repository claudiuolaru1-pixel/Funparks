const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');

// Find _AttractionRow build and replace InkWell with GestureDetector
// The AttractionRow InkWell is the one before borderRadius: BorderRadius.circular(16) and Container with padding:12
c=c.replace(
  `    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(color: Colors.grey.withOpacity(0.15)),`,
  `    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(color: Colors.grey.withOpacity(0.15)),`
);

// Also fix _AttractionTopCard InkWell
c=c.replace(
  `    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,`,
  `    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,`
);

fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');
console.log('Replaced InkWell with GestureDetector');
console.log('InkWell remaining:',(c.match(/InkWell/g)||[]).length);
console.log('GestureDetector count:',(c.match(/GestureDetector/g)||[]).length);