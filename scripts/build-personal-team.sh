#!/bin/bash
set -euo pipefail

team_id=${1:-}
if [[ $# -ne 1 || ! $team_id =~ ^[A-Z0-9]{10}$ ]]; then
    printf 'Usage: %s APPLE_TEAM_ID\n' "$0" >&2
    exit 64
fi

repo_root=$(cd -- "$(dirname -- "$0")/.." && pwd)
build_dir="$repo_root/build/PersonalTeam"
staging_dir=$(/usr/bin/mktemp -d "${TMPDIR:-/tmp}/xcreds-personal-team.XXXXXX")
trap '/bin/rm -rf -- "$staging_dir"' EXIT

# Build from a copy so the shared project keeps its full AutoFill configuration.
/usr/bin/rsync -a --exclude='/.git' --exclude='/build' --exclude='xcuserdata/' \
    "$repo_root/" "$staging_dir/"

project="$staging_dir/XCreds.xcodeproj"
project_file="$project/project.pbxproj"
# Detach both the explicit target dependency and the resource that would link it implicitly.
/usr/bin/awk '
    /^[[:space:]]*760292062C116EEE0075FBD8 .*[,][[:space:]]*$/ { dependency++; next }
    /^[[:space:]]*760291EF2C116E5F0075FBD8 .*[,][[:space:]]*$/ { resource++; next }
    { print }
    END {
        if (dependency != 1 || resource != 1) {
            print "Could not identify both AutoFill entries in XCreds.xcodeproj" > "/dev/stderr"
            exit 1
        }
    }
' "$project_file" > "$project_file.without-autofill"
/bin/mv -- "$project_file.without-autofill" "$project_file"
/usr/bin/plutil -lint "$project_file"

/usr/bin/xcodebuild -project "$project" -scheme XCreds -configuration Debug \
    -destination "platform=macOS,arch=$(/usr/bin/uname -m)" \
    -derivedDataPath "$build_dir" -allowProvisioningUpdates \
    CODE_SIGN_STYLE=Automatic DEVELOPMENT_TEAM="$team_id" \
    CODE_SIGN_IDENTITY='Apple Development' ONLY_ACTIVE_ARCH=YES build

app="$build_dir/Build/Products/Debug/XCreds.app"
if [[ -e "$app/Contents/Resources/XCreds Login Autofill.app" ]]; then
    printf 'The Personal Team build unexpectedly contains AutoFill.\n' >&2
    exit 1
fi
/usr/bin/codesign --verify --deep --strict "$app"
signature=$(/usr/bin/codesign -dv "$app" 2>&1)
if ! /usr/bin/grep -Fxq "TeamIdentifier=$team_id" <<< "$signature"; then
    printf 'The app was not signed by the requested Apple Team.\n' >&2
    exit 1
fi
printf 'Personal Team build: %s\n' "$app"
