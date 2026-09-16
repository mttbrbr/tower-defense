#!/usr/bin/env bash
# Build an RPM package for RHEL from the Godot project.
#
# Requirements (on the build host, e.g. RHEL 9 with EPEL or a container):
#   - godot 4.x in PATH (or set GODOT=/path/to/godot) with Linux/X11 export templates installed
#   - rpm-build
#
# Usage: ./packaging/build-rpm.sh
set -euo pipefail

NAME=tower-defense
VERSION=1.0.0

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT:-godot}"
TOPDIR="${TOPDIR:-$ROOT/build/rpmbuild}"

if ! command -v "$GODOT" >/dev/null 2>&1; then
    echo "error: Godot not found. Install it or set GODOT=/path/to/godot" >&2
    exit 1
fi

mkdir -p "$TOPDIR"/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
mkdir -p "$ROOT/build/linux"

echo "==> Exporting Linux binary with Godot"
"$GODOT" --headless --path "$ROOT" \
    --export-release "Linux/X11" \
    "$ROOT/build/linux/TowerDefense.x86_64"

if [[ ! -f "$ROOT/build/linux/TowerDefense.x86_64" ]]; then
    echo "error: export failed (missing build/linux/TowerDefense.x86_64)." >&2
    echo "       Make sure the Linux/X11 export templates are installed." >&2
    exit 1
fi

echo "==> Creating source tarball"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
PKGDIR="$STAGE/$NAME-$VERSION"
mkdir -p "$PKGDIR"
cp "$ROOT/build/linux/TowerDefense.x86_64" "$PKGDIR/"
cp "$ROOT/README.md" "$ROOT/LICENSE" "$ROOT/THIRD_PARTY_NOTICES.md" "$PKGDIR/"
tar -czf "$TOPDIR/SOURCES/$NAME-$VERSION.tar.gz" -C "$STAGE" "$NAME-$VERSION"

echo "==> Staging spec sources"
cp "$ROOT/packaging/$NAME.desktop" "$TOPDIR/SOURCES/"
cp "$ROOT/icon.svg" "$TOPDIR/SOURCES/"

echo "==> Building RPM"
rpmbuild -bb --define "_topdir $TOPDIR" "$ROOT/packaging/$NAME.spec"

echo "==> Done. Packages:"
find "$TOPDIR/RPMS" -name '*.rpm' -printf '%p\n'
