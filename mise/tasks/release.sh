#!/usr/bin/env bash
#MISE description="Release a new version of the CLI"
#USAGE arg "<product>"
#USAGE arg "<version>"

set -eo pipefail

echo "Releasing $usage_version"
swift build -c release --triple x86_64-apple-macosx --triple arm64-apple-macosx
lipo -create -output .build/"$usage_product" .build/{arm64,x86_64}-apple-macosx/release/"$usage_product"

zip_path=$(mktemp -t "$usage_product-macos.zip")
/usr/bin/ditto -c -k --keepParent .build/"$usage_product" "$zip_path"
trap 'rm -f "$zip_path"' EXIT

gh release create "$usage_version" \
  --title "$usage_version" \
  --notes "Release $usage_version" \
  "$zip_path"
echo "Release $usage_version created and uploaded successfully"
