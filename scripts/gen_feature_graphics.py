#!/usr/bin/env python3
# Generate a simple 1024x500 featureGraphic.png for all locales under fastlane metadata.
from PIL import Image, ImageDraw, ImageFont
import os

meta_base = "android/fastlane/metadata/android"
locales = ["en-US","fr-FR","nl-NL","de-DE","es-ES","it-IT","pt-PT","ru-RU"]

def make_graphic():
    W,H=1024,500
    img = Image.new("RGB",(W,H),(114,200,255))
    d = ImageDraw.Draw(img)
    # gradient stripe
    for y in range(H):
        c = int(200 + (255-200)*y/H)
        d.line([(0,y),(W,y)], fill=(114,200,c))
    # title
    try:
        f = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 80)
    except:
        f = ImageFont.load_default()
    d.text((40,40), "Funparks — Theme Park Finder", fill=(255,255,255), font=f)
    # simple skyline
    d.rectangle([0,H-140,W,H], fill=(255,255,255))
    d.rectangle([80,H-220,200,H-140], fill=(255,255,255))
    d.rectangle([220,H-260,320,H-140], fill=(255,255,255))
    d.rectangle([360,H-200,480,H-140], fill=(255,255,255))
    d.rectangle([520,H-240,620,H-140], fill=(255,255,255))
    return img

img = make_graphic()
for loc in locales:
    dest = os.path.join(meta_base, loc, "featureGraphic.png")
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    img.save(dest, "PNG")
print("Feature graphics generated.")
