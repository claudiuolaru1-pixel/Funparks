#!/usr/bin/env python3
import os, json, datetime
from PIL import Image

ANDROID_BASE = "android/fastlane/metadata/android"
IOS_SHOTS = "ios/fastlane/screenshots"

play_locales = ["en-US","fr-FR","nl-NL","de-DE","es-ES","it-IT","pt-PT","ru-RU"]
apple_locales = ["en-US","fr-FR","nl-NL","de-DE","es-ES","it","pt-PT","ru"]

def list_pngs(path):
    return [os.path.join(path,f) for f in sorted(os.listdir(path)) if f.lower().endswith(".png")] if os.path.exists(path) else []

def count_pngs(path_glob_root):
    total = 0
    for root, _, files in os.walk(path_glob_root):
        total += len([f for f in files if f.lower().endswith(".png")])
    return total

def first_or_none(arr):
    return arr[0] if arr else None

def mkthumb(src, dest, width=240):
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    try:
        img = Image.open(src).convert("RGB")
        w,h = img.size
        ratio = width / float(w)
        img = img.resize((width, int(h*ratio)))
        img.save(dest, "PNG")
        return True
    except Exception as e:
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

        # Thumbs
        thumbs[loc] = {}
        outdir = "dashboard/thumbs/android"
        p0, t0, s0 = first_or_none(phone_files), first_or_none(ten_files), first_or_none(seven_files)
        if p0: mkthumb(p0, f"{outdir}/{loc}_phone.png")
        if t0: mkthumb(t0, f"{outdir}/{loc}_ten.png")
        if s0: mkthumb(s0, f"{outdir}/{loc}_seven.png")
        thumbs[loc]["phone"] = f"thumbs/android/{loc}_phone.png" if p0 else None
        thumbs[loc]["tenInch"] = f"thumbs/android/{loc}_ten.png" if t0 else None
        thumbs[loc]["sevenInch"] = f"thumbs/android/{loc}_seven.png" if s0 else None

    return data, thumbs

def ios_counts_and_thumbs():
    data = {}
    thumbs = {}
    for loc in apple_locales:
        locdir = os.path.join(IOS_SHOTS, loc)
        iph = [f for f in list_pngs(locdir) if os.path.basename(f).startswith("iPhone65_")]
        ipd = [f for f in list_pngs(locdir) if os.path.basename(f).startswith("iPadPro129_")]
        data[loc] = {"iPhone65": len(iph), "iPadPro129": len(ipd)}

        outdir = "dashboard/thumbs/ios"
        iph0, ipd0 = first_or_none(iph), first_or_none(ipd)
        if iph0: mkthumb(iph0, f"{outdir}/{loc}_iphone65.png")
        if ipd0: mkthumb(ipd0, f"{outdir}/{loc}_ipad129.png")
        thumbs[loc] = {
            "iPhone65": f"thumbs/ios/{loc}_iphone65.png" if iph0 else None,
            "iPadPro129": f"thumbs/ios/{loc}_ipad129.png" if ipd0 else None
        }
    return data, thumbs

def badge(count, target, thumb=None):
    klass = "ok" if count >= target else ("none" if count == 0 else "warn")
    img = f"<img class='mini' src='{thumb}' alt='thumb'/>" if thumb else ""
    return f'<span class="badge {klass}">{count}/{target}</span>{img}'

def main():
    a, a_thumbs = android_counts_and_thumbs()
    i, i_thumbs = ios_counts_and_thumbs()
    now = datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M UTC")
    target_phone = 5
    target_tablet = 1

    # Write JSON API
    os.makedirs("dashboard", exist_ok=True)
    api = {
        "generated_at_utc": now,
        "targets": {"phone": target_phone, "tablet": target_tablet},
        "android": a,
        "android_thumbs": a_thumbs,
        "ios": i,
        "ios_thumbs": i_thumbs
    }
    with open("dashboard/data.json", "w", encoding="utf-8") as f:
        json.dump(api, f, indent=2)

    # HTML
    css = """
    <style>
    body{font-family:ui-sans-serif,system-ui,-apple-system,Segoe UI,Roboto,Ubuntu,Helvetica,Arial,sans-serif;margin:24px;background:#fafcff;color:#222}
    h1{margin:0 0 6px 0;font-size:28px}
    .sub{color:#555;margin-bottom:18px}
    .grid{display:grid;grid-template-columns:160px repeat(3,160px);gap:6px 10px;margin-bottom:28px}
    .grid.ios{grid-template-columns:160px repeat(2,200px)}
    .head{font-weight:600;color:#333;border-bottom:1px solid #e5e9f2;padding-bottom:6px;margin-bottom:6px}
    .loc{font-weight:600}
    .badge{display:inline-block;padding:4px 8px;border-radius:999px;font-weight:600;margin-right:6px}
    .ok{background:#e6ffed;color:#036400;border:1px solid #b7f5c2}
    .warn{background:#fff7e6;color:#7a4a00;border:1px solid #ffe1a6}
    .none{background:#ffeaea;color:#7a0000;border:1px solid #ffc4c4}
    .card{background:#fff;border:1px solid #e6eef7;border-radius:12px;padding:16px;margin-bottom:20px;box-shadow:0 1px 2px rgba(0,0,0,0.03)}
    .legend span{margin-right:14px}
    code{background:#f1f5fb;padding:2px 6px;border-radius:6px}
    footer{margin-top:30px;color:#666;font-size:12px}
    .mini{vertical-align:middle; height: 80px; border-radius: 8px; border:1px solid #e5e9f2; box-shadow:0 1px 2px rgba(0,0,0,0.06);}
    .cell{position:relative}
    .cell .hover{display:none; position:absolute; top:90px; left:0; background:#fff; border:1px solid #e6eef7; padding:6px; border-radius:8px; box-shadow:0 4px 20px rgba(0,0,0,0.12); z-index:10}
    .cell:hover .hover{display:block}
    .hover img{height:320px; border-radius:12px}
    </style>
    """
    html = [f"<html><head><link rel='icon' href='favicon.ico'><meta charset='utf-8'><title>Pixel Dashboard</title>{css}</head><body>"]
    html.append("<h1>Pixel Dashboard</h1>")
    html.append(f"<div class='sub'>Generated: {now} · JSON: <code>dashboard/data.json</code></div>")
    html.append("<div class='legend'><span><span class='badge ok'>ok</span> complete</span>"
                "<span><span class='badge warn'>warn</span> partial</span>"
                "<span><span class='badge none'>none</span> missing</span></div>")

    # Android card
    html.append("<div class='card'>")
    html.append("<div class='head'>Android (Play)</div>")
    html.append("<div class='grid'>")
    html.append("<div class='head'>Locale</div><div class='head'>Phone (≥5)</div><div class='head'>10\" (≥1)</div><div class='head'>7\" (≥1)</div>")
    for loc in play_locales:
        c = a.get(loc, {})
        t = a_thumbs.get(loc, {})
        html.append(f"<div class='loc'>{loc}</div>"
                    f"<div class='cell'>{badge(c.get('phone',0), target_phone, t.get('phone'))}"
                    f"{f'<div class=\"hover\"><img src=\"{t.get(\"phone\")}\"></div>' if t.get('phone') else ''}</div>"
                    f"<div class='cell'>{badge(c.get('tenInch',0), target_tablet, t.get('tenInch'))}"
                    f"{f'<div class=\"hover\"><img src=\"{t.get(\"tenInch\")}\"></div>' if t.get('tenInch') else ''}</div>"
                    f"<div class='cell'>{badge(c.get('sevenInch',0), target_tablet, t.get('sevenInch'))}"
                    f"{f'<div class=\"hover\"><img src=\"{t.get(\"sevenInch\")}\"></div>' if t.get('sevenInch') else ''}</div>")
    html.append("</div></div>")

    # iOS card
    html.append("<div class='card'>")
    html.append("<div class='head'>iOS (App Store)</div>")
    html.append("<div class='grid ios'>")
    html.append("<div class='head'>Locale</div><div class='head'>iPhone 6.5\" (≥5)</div><div class='head'>iPad Pro 12.9\" (≥1)</div>")
    for loc in apple_locales:
        c = i.get(loc, {})
        t = i_thumbs.get(loc, {})
        html.append(f"<div class='loc'>{loc}</div>"
                    f"<div class='cell'>{badge(c.get('iPhone65',0), target_phone, t.get('iPhone65'))}"
                    f"{f'<div class=\"hover\"><img src=\"{t.get(\"iPhone65\")}\"></div>' if t.get('iPhone65') else ''}</div>"
                    f"<div class='cell'>{badge(c.get('iPadPro129',0), target_tablet, t.get('iPadPro129'))}"
                    f"{f'<div class=\"hover\"><img src=\"{t.get(\"iPadPro129\")}\"></div>' if t.get('iPadPro129') else ''}</div>")
    html.append("</div></div>")

    html.append("<footer>Made by <strong>Claudiu Olaru</strong> · Powered by Pixel Dashboard</footer>")
    html.append("</body></html>")

    out_dir = "dashboard"
    os.makedirs(out_dir, exist_ok=True)
    with open(os.path.join(out_dir, "index.html"), "w", encoding="utf-8") as f:
        f.write("".join(html))

if __name__ == "__main__":
    main()
