// lib/widgets/closure_badge.dart
//
// Small "closed" label for attractions and parks, plus a banner for the park page.
// Texts live in this file (10 languages) so no l10n regeneration is needed.
import 'package:flutter/material.dart';

import '../models/closure_status.dart';

class ClosureText {
  ClosureText._();

  static const Map<String, Map<String, String>> _t = {
    'en': {
      'perm': 'Permanently closed',
      'temp': 'Temporarily closed',
      'tempUntil': 'Closed until {date}',
      'season': 'Closed for the season',
      'seasonUntil': 'Closed for the season · reopens {date}',
      'limited': 'Limited opening days',
      'limitedUntil': 'Limited opening days until {date}',
      'notice': 'Check status before you go',
      'scheduled': 'Closed {from} – {to}',
      'scheduledFrom': 'Closed from {from}',
      'seasonInfo': 'Season info',
    },
    'es': {
      'perm': 'Cierre definitivo',
      'temp': 'Cierre temporal',
      'tempUntil': 'Cierre temporal hasta el {date}',
      'season': 'Cierre de temporada',
      'seasonUntil': 'Cierre de temporada · reabre el {date}',
      'limited': 'Abierto solo algunos días',
      'limitedUntil': 'Abierto solo algunos días hasta el {date}',
      'notice': 'Consulta el estado antes de ir',
      'scheduled': 'Cierre del {from} al {to}',
      'scheduledFrom': 'Cierre desde el {from}',
      'seasonInfo': 'Información de temporada',
    },
    'fr': {
      'perm': 'Fermeture définitive',
      'temp': 'Fermeture temporaire',
      'tempUntil': 'Fermeture temporaire jusqu\'au {date}',
      'season': 'Fermeture saisonnière',
      'seasonUntil': 'Fermeture saisonnière · réouverture le {date}',
      'limited': 'Jours d\'ouverture limités',
      'limitedUntil': 'Jours d\'ouverture limités jusqu\'au {date}',
      'notice': 'Vérifiez le statut avant de venir',
      'scheduled': 'Fermeture du {from} au {to}',
      'scheduledFrom': 'Fermeture à partir du {from}',
      'seasonInfo': 'Infos saison',
    },
    'de': {
      'perm': 'Dauerhaft geschlossen',
      'temp': 'Vorübergehend geschlossen',
      'tempUntil': 'Geschlossen bis {date}',
      'season': 'Für die Saison geschlossen',
      'seasonUntil': 'Für die Saison geschlossen · öffnet wieder am {date}',
      'limited': 'Eingeschränkte Öffnungstage',
      'limitedUntil': 'Eingeschränkte Öffnungstage bis {date}',
      'notice': 'Status vor dem Besuch prüfen',
      'scheduled': 'Geschlossen {from} – {to}',
      'scheduledFrom': 'Geschlossen ab {from}',
      'seasonInfo': 'Saisoninfos',
    },
    'it': {
      'perm': 'Chiusura definitiva',
      'temp': 'Chiusura temporanea',
      'tempUntil': 'Chiusura temporanea fino al {date}',
      'season': 'Chiusura stagionale',
      'seasonUntil': 'Chiusura stagionale · riapre il {date}',
      'limited': 'Giorni di apertura limitati',
      'limitedUntil': 'Giorni di apertura limitati fino al {date}',
      'notice': 'Controlla lo stato prima di andare',
      'scheduled': 'Chiusura dal {from} al {to}',
      'scheduledFrom': 'Chiusura dal {from}',
      'seasonInfo': 'Info stagione',
    },
    'nl': {
      'perm': 'Definitief gesloten',
      'temp': 'Tijdelijk gesloten',
      'tempUntil': 'Gesloten tot {date}',
      'season': 'Gesloten voor het seizoen',
      'seasonUntil': 'Gesloten voor het seizoen · heropent op {date}',
      'limited': 'Beperkte openingsdagen',
      'limitedUntil': 'Beperkte openingsdagen tot {date}',
      'notice': 'Controleer de status voordat je gaat',
      'scheduled': 'Gesloten van {from} tot {to}',
      'scheduledFrom': 'Gesloten vanaf {from}',
      'seasonInfo': 'Seizoensinfo',
    },
    'pt': {
      'perm': 'Encerramento definitivo',
      'temp': 'Encerramento temporário',
      'tempUntil': 'Encerramento temporário até {date}',
      'season': 'Encerramento sazonal',
      'seasonUntil': 'Encerramento sazonal · reabre em {date}',
      'limited': 'Dias de funcionamento limitados',
      'limitedUntil': 'Dias de funcionamento limitados até {date}',
      'notice': 'Confirme o estado antes de ir',
      'scheduled': 'Encerramento de {from} a {to}',
      'scheduledFrom': 'Encerramento a partir de {from}',
      'seasonInfo': 'Informação da época',
    },
    'ru': {
      'perm': 'Закрыто навсегда',
      'temp': 'Временно закрыто',
      'tempUntil': 'Закрыто до {date}',
      'season': 'Закрыто на сезон',
      'seasonUntil': 'Закрыто на сезон · откроется {date}',
      'limited': 'Открыто не каждый день',
      'limitedUntil': 'Открыто не каждый день до {date}',
      'notice': 'Уточните статус перед визитом',
      'scheduled': 'Закрыто с {from} по {to}',
      'scheduledFrom': 'Закрытие с {from}',
      'seasonInfo': 'О сезоне',
    },
    'zh': {
      'perm': '永久关闭',
      'temp': '暂时关闭',
      'tempUntil': '关闭至 {date}',
      'season': '本季关闭',
      'seasonUntil': '本季关闭 · {date} 重新开放',
      'limited': '仅部分日期开放',
      'limitedUntil': '{date} 前仅部分日期开放',
      'notice': '出发前请确认运营状态',
      'scheduled': '{from} 至 {to} 关闭',
      'scheduledFrom': '自 {from} 起关闭',
      'seasonInfo': '季节信息',
    },
    'ar': {
      'perm': 'مغلق نهائيًا',
      'temp': 'مغلق مؤقتًا',
      'tempUntil': 'مغلق حتى {date}',
      'season': 'مغلق لهذا الموسم',
      'seasonUntil': 'مغلق لهذا الموسم · يُعاد فتحه في {date}',
      'limited': 'أيام التشغيل محدودة',
      'limitedUntil': 'أيام التشغيل محدودة حتى {date}',
      'notice': 'تحقق من الحالة قبل الزيارة',
      'scheduled': 'مغلق من {from} إلى {to}',
      'scheduledFrom': 'مغلق اعتبارًا من {from}',
      'seasonInfo': 'معلومات الموسم',
    },
  };

  static String _get(BuildContext context, String key) {
    final lang = Localizations.localeOf(context).languageCode;
    final table = _t[lang] ?? _t['en']!;
    return table[key] ?? _t['en']![key] ?? '';
  }

  static String _date(BuildContext context, DateTime d) =>
      MaterialLocalizations.of(context).formatMediumDate(d);

  /// The text for the badge or banner. Returns '' when there is nothing to say.
  static String label(BuildContext context, ClosureStatus s, DateTime now) {
    final kind = s.kindAt(now);
    if (kind == null) return '';
    final w = s.windowAt(now);
    switch (kind) {
      case ClosureKind.permanentlyClosed:
        return _get(context, 'perm');
      case ClosureKind.temporarilyClosed:
        final u = w?.until;
        if (u == null) return _get(context, 'temp');
        return _get(context, 'tempUntil').replaceAll('{date}', _date(context, u));
      case ClosureKind.seasonalClosed:
        final u = w?.until;
        if (u == null) return _get(context, 'season');
        final reopen = u.add(const Duration(days: 1));
        return _get(context, 'seasonUntil')
            .replaceAll('{date}', _date(context, reopen));
      case ClosureKind.limitedDays:
        final u = w?.until;
        if (u == null) return _get(context, 'limited');
        return _get(context, 'limitedUntil')
            .replaceAll('{date}', _date(context, u));
      case ClosureKind.scheduledClosure:
        if (w == null) return '';
        final u = w.until;
        if (u == null) {
          return _get(context, 'scheduledFrom')
              .replaceAll('{from}', _date(context, w.from));
        }
        return _get(context, 'scheduled')
            .replaceAll('{from}', _date(context, w.from))
            .replaceAll('{to}', _date(context, u));
      case ClosureKind.notice:
        return _get(context, 'notice');
    }
    return '';
  }

  static String seasonInfoTitle(BuildContext context) =>
      _get(context, 'seasonInfo');
}

class _ClosureStyle {
  final Color bg;
  final Color fg;
  final IconData icon;
  const _ClosureStyle(this.bg, this.fg, this.icon);
}

_ClosureStyle _styleFor(ClosureKind k) {
  switch (k) {
    case ClosureKind.permanentlyClosed:
      return const _ClosureStyle(Color(0xFFFDE8E8), Color(0xFF9B1C1C), Icons.block);
    case ClosureKind.temporarilyClosed:
    case ClosureKind.seasonalClosed:
      return const _ClosureStyle(Color(0xFFFFF1E0), Color(0xFF9A4B00), Icons.lock_clock);
    case ClosureKind.limitedDays:
    case ClosureKind.scheduledClosure:
      return const _ClosureStyle(Color(0xFFFFF8DB), Color(0xFF7A5B00), Icons.event_busy);
    case ClosureKind.notice:
      return const _ClosureStyle(Color(0xFFE8F1FB), Color(0xFF1E4F8C), Icons.info_outline);
  }
  return const _ClosureStyle(Color(0xFFF2F4F7), Color(0xFF344054), Icons.info_outline);
}

/// Pill used on ride rows, top-pick cards and park cards.
class ClosureBadge extends StatelessWidget {
  final ClosureStatus? status;
  final DateTime? now;

  const ClosureBadge({super.key, required this.status, this.now});

  @override
  Widget build(BuildContext context) {
    final s = status;
    if (s == null) return const SizedBox.shrink();
    final t = now ?? DateTime.now();
    final kind = s.kindAt(t);
    if (kind == null) return const SizedBox.shrink();
    final text = ClosureText.label(context, s, t);
    if (text.isEmpty) return const SizedBox.shrink();
    final st = _styleFor(kind);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: st.bg,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(st.icon, size: 14, color: st.fg),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 12, color: st.fg),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dims a card when the item is closed right now. The card stays fully tappable.
class ClosureDim extends StatelessWidget {
  final ClosureStatus? status;
  final Widget child;
  const ClosureDim({super.key, required this.status, required this.child});

  @override
  Widget build(BuildContext context) {
    final s = status;
    if (s != null && s.isClosedAt(DateTime.now())) {
      return Opacity(opacity: 0.62, child: child);
    }
    return child;
  }
}

/// Banner for the park page: current status, English note, and season dates.
class ParkClosureBanner extends StatelessWidget {
  final ClosureStatus? status;
  const ParkClosureBanner({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status;
    if (s == null) return const SizedBox.shrink();
    final now = DateTime.now();
    final kind = s.kindAt(now);
    final label = kind == null ? '' : ClosureText.label(context, s, now);
    final note = s.noteAt(now);
    final season = s.seasonNote;
    if (label.isEmpty && (note == null) && season == null) {
      return const SizedBox.shrink();
    }
    final st = kind == null
        ? const _ClosureStyle(Color(0xFFF2F4F7), Color(0xFF344054), Icons.event)
        : _styleFor(kind);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: st.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Row(
              children: [
                Icon(st.icon, size: 18, color: st.fg),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(label,
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: st.fg)),
                ),
              ],
            ),
          if (note != null) ...[
            if (label.isNotEmpty) const SizedBox(height: 6),
            Text(note, style: TextStyle(color: st.fg, fontSize: 13)),
          ],
          if (season != null) ...[
            const SizedBox(height: 8),
            Text(ClosureText.seasonInfoTitle(context),
                style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 12, color: st.fg)),
            const SizedBox(height: 2),
            Text(season, style: TextStyle(color: st.fg, fontSize: 13)),
          ],
        ],
      ),
    );
  }
}
