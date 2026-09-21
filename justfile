set dotenv-load := true
set shell := ["bash", "-euo", "pipefail", "-c"]

scheme  := "MediJoApp"
bundle  := "com.example.MediJoApp"
project := scheme + ".xcodeproj"
derived := ".build/xcode"

sim_app    := derived / "Build/Products/Debug-iphonesimulator" / (scheme + ".app")
device_app := derived / "Build/Products/Debug-iphoneos" / (scheme + ".app")

sim := env_var_or_default("SIM", "iPhone 16")
os := env_var_or_default("OS", "18.3.1")

# Two different identifiers for the same physical phone:
#   BUILD_ID  -> xcodebuild -destination 'platform=iOS,id=...'   (hardware UDID)
#   DEVICE_ID -> devicectl --device ...                          (CoreDevice UUID)
# Run `just devices` to print both.
build_id  := env_var_or_default("BUILD_ID", "")
device_id := env_var_or_default("DEVICE_ID", "")

default:
    @just --list --unsorted

# ---------------------------------------------------------------- project

gen:
    xcodegen generate

build_log := ".build/last-build.log"

lsp: gen
    mkdir -p .build
    xcodebuild -project {{project}} -scheme {{scheme}} -configuration Debug \
      -destination 'platform=iOS Simulator,OS={{os}},name={{sim}}' \
      -derivedDataPath {{derived}} build \
      | tee {{build_log}} | xcbeautify
    xcode-build-server parse -a {{build_log}}
fmt:
    swiftformat . --swiftversion 6.0

clean:
    rm -rf {{derived}} {{project}}

# ---------------------------------------------------------------- discovery

sims:
    xcrun simctl list devicetypes | grep iPhone

# Print both identifiers for connected hardware.
devices:
    @echo "== BUILD_ID  (xcodebuild -destination id) =="
    @xcodebuild -project {{project}} -scheme {{scheme}} -showdestinations 2>/dev/null \
      | grep 'platform:iOS,' | grep -v 'Simulator' || echo "  (none — is the device unlocked and trusted?)"
    @echo
    @echo "== DEVICE_ID (devicectl --device, the Identifier column) =="
    @xcrun devicectl list devices

# ---------------------------------------------------------------- simulator

build-sim: gen
    xcodebuild -project {{project}} -scheme {{scheme}} -configuration Debug \
      -destination 'platform=iOS Simulator,OS={{os}},name={{sim}}' \
      -derivedDataPath {{derived}} \
      build | xcbeautify

flash-sim:
    xcrun simctl boot "{{sim}}" 2>/dev/null || true
    open -a Simulator
    xcrun simctl install booted {{sim_app}}

launch-sim:
    xcrun simctl launch --console-pty booted {{bundle}}

sim: build-sim flash-sim launch-sim

# ---------------------------------------------------------------- device
# Each recipe takes the identifier as an optional argument, defaulting to .env.
#   just build-device                     # uses BUILD_ID
#   just build-device 00008130-001A2B3C   # override for a second phone

build-device id=build_id: gen
    @test -n "{{id}}" || { echo "BUILD_ID unset. 'just devices', then set it in .env or pass it: just build-device <id>" >&2; exit 1; }
    xcodebuild -project {{project}} -scheme {{scheme}} -configuration Debug \
      -destination 'platform=iOS,id={{id}}' \
      -derivedDataPath {{derived}} \
      -allowProvisioningUpdates \
      build | xcbeautify

flash-device id=device_id:
    @test -n "{{id}}" || { echo "DEVICE_ID unset. 'just devices', then set it in .env or pass it: just flash-device <id>" >&2; exit 1; }
    @test -d {{device_app}} || { echo "No build at {{device_app}} — run 'just build-device' first." >&2; exit 1; }
    xcrun devicectl device install app --device {{id}} {{device_app}}

launch-device id=device_id:
    @test -n "{{id}}" || { echo "DEVICE_ID unset. 'just devices', then set it in .env or pass it: just launch-device <id>" >&2; exit 1; }
    xcrun devicectl device process launch --device {{id}} --console {{bundle}}

device: build-device flash-device launch-device

# Reinstall without rebuilding — the common inner loop once the build is warm.
reflash: flash-device launch-device
