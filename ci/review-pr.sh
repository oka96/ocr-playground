#!/usr/bin/env bash
set -euo pipefail

pr_number="${1:-}"
if [[ ! "$pr_number" =~ ^[1-9][0-9]*$ ]]; then
    printf 'Usage: bash ci/review-pr.sh <GitHub PR number>\n' >&2
    exit 2
fi

repo_slug="oka96/ocr-playground"
repo_url="https://github.com/${repo_slug}.git"
report="$PWD/target/ocr-report.txt"
workspace=$(mktemp -d)
trap 'rm -rf -- "$workspace"' EXIT
review_repo="$workspace/repo"
background_file="$workspace/pr-context.md"

api_headers=(--header 'Accept: application/vnd.github+json')
if [[ -n "${GH_TOKEN:-}" ]]; then
    api_headers+=(--header "Authorization: Bearer $GH_TOKEN")
fi
commits=$(curl --fail --silent --show-error --retry 2 \
    "${api_headers[@]}" \
    "https://api.github.com/repos/${repo_slug}/pulls/${pr_number}" |
    node -e '
        const fs = require("node:fs");
        const {base, head, title, body} = JSON.parse(fs.readFileSync(0, "utf8"));
        const isSha = (sha) => typeof sha === "string" && /^[a-f0-9]{40}$/.test(sha);
        if (!isSha(base?.sha) || !isSha(head?.sha)) {
            throw new Error("GitHub did not return the pull request base and head commits.");
        }
        fs.writeFileSync(process.argv[1], `${title}\n\n${body ?? ""}\n`);
        console.log(base.sha, head.sha);
    ' "$background_file")
read -r base_sha head_sha <<< "$commits"

git init --quiet "$review_repo"
git -C "$review_repo" fetch --quiet --no-tags "$repo_url" \
    "$base_sha" "refs/pull/${pr_number}/head:refs/ocr/head"
if [[ "$(git -C "$review_repo" rev-parse refs/ocr/head)" != "$head_sha" ]]; then
    printf 'The pull request changed during fetch. Start a new pipeline for the latest head.\n' >&2
    exit 1
fi

merge_base=$(git -C "$review_repo" merge-base "$base_sha" "$head_sha")
git -C "$review_repo" -c core.hooksPath=/dev/null checkout --quiet --detach "$head_sha"
printf 'Reviewing %s PR #%s (%s...%s)\n' "$repo_slug" "$pr_number" "$merge_base" "$head_sha"

mkdir -p "$(dirname "$report")"
npx --yes --package=@alibaba-group/open-code-review@1.14.0 ocr review \
    --repo "$review_repo" --from "$merge_base" --to "$head_sha" \
    --audience agent --format text \
    --background-file "$background_file" \
    --output "$report"
