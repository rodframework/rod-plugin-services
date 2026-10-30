#!/bin/sh
# Builds the reference plugin's Linux artifact into the package tree.
# rod mod publish packs plugin/services-linux-amd64 as the package's
# execution half, so this script runs before a release publish; the
# binary is build output and nothing under plugin/ is committed. The
# Rust source half lives in the Rod platform tree (or an unpacked
# rod-src.tar.gz): ROD_RUST_TREE names its src/implant/rust.
set -eu

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
rust_tree=${ROD_RUST_TREE:-}

if [ -z "$rust_tree" ]; then
    # Walk up from this checkout towards a Rod checkout laid out beside it.
    dir=$here
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/../src/implant/rust/modules/services" ]; then
            rust_tree="$dir/../src/implant/rust"
            break
        fi
        dir=$(dirname "$dir")
    done
fi

if [ -z "$rust_tree" ] || [ ! -d "$rust_tree/modules/services" ]; then
    echo "services: no Rust tree found -- set ROD_RUST_TREE to a Rod checkout's src/implant/rust (or an unpacked rod-src.tar.gz)" >&2
    exit 1
fi

crate="$rust_tree/modules/services"

(cd "$crate" && cargo build --release)
mkdir -p "$here/plugin"
cp "$crate/target/release/rod-module-services" "$here/plugin/services-linux-amd64"
echo "artifact: $here/plugin/services-linux-amd64"
