#!/usr/bin/env python3
# Toggle Play countries.json from templates (EU-only or worldwide)
import sys, json, os
TEMPLATES = {
  "eu": "android/fastlane/countries.eu.json",
  "world": "android/fastlane/countries.worldwide.json"
}
if len(sys.argv)<2 or sys.argv[1] not in TEMPLATES:
  print("Usage: toggle_countries.py [eu|world]")
  sys.exit(1)
src = TEMPLATES[sys.argv[1]]
with open(src,"r") as f:
  data = json.load(f)
# expand 'ww' to an empty list meaning all countries (handled by Fastlane block as 'no targeting')
if data.get("countries")==["ww"]:
  data["countries"] = []
open("android/fastlane/countries.json","w").write(json.dumps(data, indent=2))
print("Wrote android/fastlane/countries.json from", src)
