#!/usr/bin/env bash

echo "Usage: $0 repository_dir wallet_path"

repository_path="$1"
wallet_path="$2"
mkdir -p "$repository_dir/.git"
tmpdir="$repository_dir/.git/$$"

# install arkb with yarn or npm
#yarn global add arkb
# or with npm
#npm install --global arkb

# check your wallet address and balance if needed
arkb balance --wallet "$wallet_path"

git clone -- --mirror --bare "$repository_path" "$tmpdir"
git --git-dir "$tmpdir" update-server-info

# keepme files might be unneeded, unsure
find "$tmpdir" -type d -empty | xargs touch

# deploy with arkb
echo "This is a git repository uploaded with arkb." > "$tmpdir"/index.txt
arkb deploy "$tmpdir" --wallet "$wallet_path" --index index.txt --bundle --debug --tag-name git --tag-value git --no-colors

