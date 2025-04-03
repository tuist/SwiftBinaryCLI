#!/usr/bin/env bash
#MISE description="Release a new version of the CLI"
#USAGE arg "<product>"
#USAGE arg "<version>"
#USAGE flag "--github-token <github-token>" long_help="Token to authenticate the request against the GitHub API"

# Build
echo "Releasing $usage_version"
swift build -c release --triple x86_64-apple-macosx
swift build -c release --triple arm64-apple-macosx
lipo -create -output .build/$usage_product .build/arm64-apple-macosx/release/$usage_product .build/x86_64-apple-macosx/release/$usage_product

# Zip
TMP_DIR=/private$(mktemp -d)
zip_path="$TMP_DIR/$usage_product-macos.zip"
trap "rm -rf $TMP_DIR" EXIT
/usr/bin/ditto -c -k --keepParent .build/$usage_product $zip_path

PAYLOAD=$(jq -n \
  --arg tag_name "$usage_version" \
  --arg name "$usage_version" \
  '{
    tag_name: $tag_name,
    name: $name,
    draft: false,
    prerelease: false
  }')
  echo "Creating release..."
RESPONSE=$(curl -s -X POST "https://api.github.com/repos/tuist/SwiftBinaryCLI/releases" \
-H "Authorization: Bearer $GITHUB_TOKEN" \
-H "Accept: application/vnd.github+json" \
-H "Content-Type: application/json" \
-d "$PAYLOAD")

if echo "$RESPONSE" | grep -q '"id":'; then
    echo "Release created successfully!"
else
    echo "Failed to create release. Response:"
    echo "$RESPONSE"
fi
