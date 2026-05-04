const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');

// Fix 1: _LiveWaitText StreamBuilder -> static Text
c=c.replace(
`    final service = WaitTimeService();
    return StreamBuilder<WaitTimeReading?>(
      stream: service.streamLiveWaitReading(
          parkId: parkId, attractionId: attractionId),
      builder: (_, snap) {
        final minutes = snap.data?.minutes ?? fallbackMinutes;
        return Text('\$minutes min (\${loc.liveWait})',
            style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
      },
    );`,
`    return Text('\$fallbackMinutes min (\${loc.liveWait})',
        style: style, maxLines: 1, overflow: TextOverflow.ellipsis);`
);

// Fix 2: _LiveWaitBadge StreamBuilder -> static _SoftBadge
c=c.replace(
`    final service = WaitTimeService();
    return StreamBuilder<WaitTimeReading?>(
      stream: service.streamLiveWaitReading(
          parkId: parkId, attractionId: attractionId),
      builder: (_, snap) {
        final minutes = snap.data?.minutes ?? fallbackMinutes;
        return _SoftBadge(icon: Icons.timer, text: '\${minutes}m');
      },
    );`,
`    return _SoftBadge(icon: Icons.timer, text: '\${fallbackMinutes}m');`
);

// Fix 3: Detail screen StreamBuilder -> static _Pill
c=c.replace(
`                  StreamBuilder<WaitTimeReading?>(
                    stream: service.streamLiveWaitReading(
                        parkId: widget.parkId,
                        attractionId: a.id),
                    builder: (_, snap) {
                      final minutes =
                          snap.data?.minutes ?? a.liveWaitMinutes;
                      return _Pill(
                          icon: Icons.timer,
                          text:
                              '\$minutes min (\${loc.liveWait})');
                    },
                  ),`,
`                  _Pill(icon: Icons.timer, text: '\${a.liveWaitMinutes} min (\${loc.liveWait})'),`
);

// Remove WaitTimeService instantiation in detail screen build
c=c.replace(
`    final service = WaitTimeService();
    final factLines`,
`    final factLines`
);

fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');
const remaining=(c.match(/StreamBuilder/g)||[]).length;
console.log('StreamBuilders remaining:',remaining);
console.log('Done');