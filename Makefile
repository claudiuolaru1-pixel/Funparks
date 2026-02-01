.PHONY: setup icons splash build-aab build-ipa play-upload ios-beta gen-fg countries-eu countries-world ios-territories ios-metadata

setup:
	flutter pub get

icons:
	dart run flutter_launcher_icons

splash:
	dart run flutter_native_splash:create

build-aab:
	flutter build appbundle --release

build-ipa:
	flutter build ipa --no-codesign

play-upload:
	python3 scripts/gen_feature_graphics.py && cd android && fastlane internal

ios-beta:
	cd ios && fastlane beta

gen-fg:
	python3 scripts/gen_feature_graphics.py

countries-eu:
	python3 scripts/toggle_countries.py eu

countries-world:
	python3 scripts/toggle_countries.py world

ios-territories:
	cd ios && fastlane set_territories

ios-metadata:
	cd ios && fastlane deliver_upload


screenshots-en:
	bash scripts/capture_screenshots.sh `flutter devices | awk 'NR==3{print $$1}'` en

screenshots-fr:
	bash scripts/capture_screenshots.sh `flutter devices | awk 'NR==3{print $$1}'` fr
