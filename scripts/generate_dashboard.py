#!/usr/bin/env python3
import os
import json
import datetime
from PIL import Image

ANDROID_BASE = "android/fastlane/metadata/android"
IOS_SHOTS = "ios/fastlane/screenshots"

play_locales = ["en-US", "fr-FR", "nl-NL", "de-DE", "es-ES", "it-IT", "pt-PT", "ru-RU"]
apple_locales = ["en-US", "fr-FR", "nl-NL", "de-DE", "es-ES", "it", "pt-PT", "ru"]


def list_pngs(path: str):
    if not os.path.exists(path):
        return []
    return [
        os.path.join(path, f)
        for f in sorted(os.listdir(path))
        if f.lower().endswith(".png")
    ]


def first_or_none(arr):
    return arr[0] if arr else None


def mkthumb(src: str, dest: str, width: int = 240) -> bool:
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    try:
        img = Image.open(src).convert("RGB")
        w, h = img.size
        ratio = width / float(w)
        img = img.resize((width, int(h * ratio)))
        img.save(dest, "PNG")
        return True
    except Exception:
        return False


def android_counts_and_thumbs():
    data = {}
    thumbs = {}

    for loc in play_locales:
        phone = os.path.join(ANDROID_BASE, loc, "phoneScreenshots")
        ten = os.path.join(ANDROID_BASE, loc, "tenInchScreenshots")
        seven = os.path.join(ANDROID_BASE, loc, "sevenInchScreenshots")

        phone_files = list_pngs(phone)
        ten_files = list_pngs(ten)
        seven_files = list_pngs(seven)

        data[loc] = {
            "phone": len(phone_files),
            "tenInch": len(ten_files),
            "sevenInch": len(seven_files),
        }

        outdir = "dashboard/thumbs/android"
        p0, t0, s0 = first_or_none(phone_files), first_or_none(ten_files), first_or_none(seven_files)

        if p0:
            mkthumb(p0, f"{outdir}/{loc}_phone.png")
        if t0:
            mkthumb(t0, f"{outdir}/{loc}_ten.png")
        if s0:
            mkthumb(s0, f"{outdir}/{loc}_seven.png")

        thumbs[loc] = {
            "phone": f"thumbs/android/{loc}_phone.png" if p0 else None,
            "tenInch": f"thumbs/android/{loc}_ten.png" if t0 else None,
            "sevenInch": f"thumbs/android/{loc}_seven.png" if s0 else None,
        }

    return data, thumbs


def ios_counts_and_thumbs():
    data = {}
    thumbs = {}

    for loc in apple_locales:
        locdir = os.path.join(IOS_SHOTS, loc)
        files = list_pngs(locdir)

        iph = [f for f in files if os.path.basename(f).startswith("iPhone65_")]
        ipd = [f for f in files if os.path.basename(f).startswith("iPadPro129_")]

        data[loc] = {"iPhone65": len(iph), "iPadPro129": len(ipd)}

        outdir = "dashboard/thumbs/ios"
        iph0, ipd0 = first_or_none(iph), first_or_none(ipd)

        if iph0:
            mkthumb(iph0, f"{outdir}/{loc}_iphone65.png")
        if ipd0:
            mkthumb(ipd0, f"{outdir}/{loc}_ipad129.png")

        thumbs[loc] = {
            "iPhone65": f"thumbs/ios/{loc}_iphone65.png" if iph0 else None,
            "iPadPro129": f"thumbs/ios/{loc}_ipad129.png" if ipd0 else None,
        }

    return data, thumbs


def badge(count: int, target: int):
    if count >= target:
        klass = "ok"
    elif count == 0:
        klass = "none"
    else:
        klass = "warn"
    return f'<span class="badge {klass}">{count}/{target}</span>'


def main():
    a, _a_thumbs = android_counts_and_thumbs()
    i, _i_thumbs = ios_counts_and_thumbs()

    now = datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M UTC")
    target_phone = 5
    target_tablet = 1

    os.makedirs("dashboard", exist_ok=True)

    api = {
        "generated_at_utc": now,
        "targets": {"phone": target_phone, "tablet": target_tablet},
        "android": a,
        "ios": i,
    }
    with open("dashboard/data.json", "w", encoding="utf-8") as f:
        json.dump(api, f, indent=2)

    css = """
<style>
  body{font-family:system-ui,-apple-system,Segoe UI,Roboto,Arial,sans-serif;margin:24px;line-height:1.35}
  h1{margin:0 0 8px 0}
  .muted{color:#666}
  .card{border:1px solid #e5e5e5;border-radius:12px;padding:16px;margin:16px 0}
  table{width:100%;border-collapse:collapse}
  th,td{padding:10px;border-bottom:1px solid #eee;text-align:left;vertical-align:top}
  .badge{display:inline-block;padding:2px 8px;border-radius:999px;font-weight:600;font-size:12px}
  .ok{background:#e8fff0}
  .warn{background:#fff6db}
  .none{background:#ffe8e8}
</style>
"""

    html = [f"<!doctype html><html><head><meta charset='utf-8'><title>Pixel Dashboard</title>{css}</head><body>"]
    html.append("<h1>Pixel Dashboard</h1>")
    html.append(f"<div class='muted'>Generated: {now} · JSON: <code>dashboard/data.json</code></div>")

    # Android
    html.append("<div class='card'><h2>Android (Play)</h2>")
    html.append("<table><thead><tr><th>Locale</th><th>Phone (≥5)</th><th>10&quot; (≥1)</th><th>7&quot; (≥1)</th></tr></thead><tbody>")
    for loc in play_locales:
        c = a.get(loc, {})
        html.append(
            "<tr>"
            f"<td>{loc}</td>"
            f"<td>{badge(c.get('phone', 0), target_phone)}</td>"
            f"<td>{badge(c.get('tenInch', 0), target_tablet)}</td>"
            f"<td>{badge(c.get('sevenInch', 0), target_tablet)}</td>"
            "</tr>"
        )
    html.append("</tbody></table></div>")

    # iOS
    html.append("<div class='card'><h2>iOS (App Store)</h2>")
    html.append("<table><thead><tr><th>Locale</th><th>iPhone 6.5&quot; (≥5)</th><th>iPad Pro 12.9&quot; (≥1)</th></tr></thead><tbody>")
    for loc in apple_locales:
        c = i.get(loc, {})
        html.append(
            "<tr>"
            f"<td>{loc}</td>"
            f"<td>{badge(c.get('iPhone65', 0), target_phone)}</td>"
            f"<td>{badge(c.get('iPadPro129', 0), target_tablet)}</td>"
            "</tr>"
        )
    html.append("</tbody></table></div>")

    html.append("<div class='muted'>Made by Claudiu Olaru · Powered by Pixel Dashboard</div>")
    html.append("</body></html>")

    with open("dashboard/index.html", "w", encoding="utf-8") as f:
        f.write("".join(html))


if __name__ == "__main__":
    main()
