---
name: release
description: Automate release preparation for the context_show package. Determines version bump, updates pubspec.yaml/CHANGELOG.md, regenerates the example lockfile, commits, tags, and pushes. Use when the user wants to publish a new release.
---

You are preparing a new release for the **context_show** Flutter package. The user may optionally provide a version number or bump keyword.

## Step 1: Parse User Input

Extract from `$ARGUMENTS`:
- **Explicit version** (e.g., `0.4.0`, `1.0.0`) — use this exact version
- **Bump keyword** (`major`, `minor`, or `patch`) — apply this bump to the current version
- **Empty** — auto-determine the bump type from commit analysis

## Step 2: Pre-flight Checks

Run these checks before doing anything else. If any fail, **abort immediately** with a clear error message.

1. **Clean working tree**: Run `git status --porcelain`. If there is any output, abort — tell the user to commit or stash their changes first.
2. **On main branch**: Run `git branch --show-current`. If the result is not `main`, abort — tell the user to switch to `main`.
3. **In sync with remote**: Run `git fetch origin main` then compare `git rev-parse HEAD` with `git rev-parse origin/main`. If they differ, abort — tell the user to pull or push first.

## Step 3: Quality Gates

Run the **same checks CI runs** in `.github/workflows/release.yaml`. They are defined in `commands.yaml` at the repo root, so run them verbatim rather than inventing equivalents — a mismatch means CI fails *after* the tag is pushed, which is the expensive failure mode.

1. `dart format --output=none --set-exit-if-changed .` — must report no files needing formatting
2. `flutter analyze --no-pub --no-congratulate` — must produce **zero** issues (errors, warnings, or infos)
3. `flutter test --no-pub --test-randomize-ordering-seed=random` — all tests must pass

If any fail, **abort** and ask the user to fix the issues first.

## Step 4: Analyze Commits & Determine Version

1. Get the latest git tag: `git describe --tags --abbrev=0`
2. Get current version from `pubspec.yaml` (the `version:` field)
3. List all commits since the latest tag: `git log <latest_tag>..HEAD --oneline`
4. Parse each commit using Conventional Commits format (`type(scope): description`):
   - Extract the **type** (e.g., `feat`, `fix`, `refactor`)
   - Extract the **scope** if present (e.g., `lifecycle`, `safe-area`, `core`)
   - Extract the **description**
   - Check for breaking changes: `BREAKING CHANGE:` in body/footer or `!` after type (e.g., `feat!:`)

5. **Determine version bump** (unless user provided explicit version or keyword):
   - Any breaking change → **MAJOR** bump
   - Any `feat` commit → **MINOR** bump
   - Only `fix`, `refactor`, `style`, `perf`, `docs` → **PATCH** bump
   - No user-facing commits (only `chore`, `test`, `ci`, `build`) → Use `AskUserQuestion` to ask whether to proceed with a PATCH release or abort

   **While the package is pre-1.0** (`0.x.y`), follow the convention already used by this
   repo's history: breaking changes bump the **minor** (`0.2.0` → `0.3.0`), and features
   and fixes bump the **patch**. Do not silently jump to `1.0.0` — if the analysis
   suggests a MAJOR bump, use `AskUserQuestion` to confirm whether the user wants
   `0.(x+1).0` or a genuine `1.0.0` release.

6. If user provided a bump keyword (`major`/`minor`/`patch`), apply it to the current version.
7. If user provided an explicit version, validate it is higher than the current version.

## Step 5: Generate CHANGELOG Entry

This repo's `CHANGELOG.md` does **not** follow plain Keep a Changelog — it uses emoji
category headings and a short prose summary line under the version heading. **Match the
existing style** (read the `## 0.3.0` and `## 0.2.0` sections first to confirm the
conventions still hold).

Map commits to categories:

| Commit type                    | CHANGELOG category      | Include? |
|--------------------------------|-------------------------|----------|
| breaking (`!` / `BREAKING CHANGE:`) | **💥 Breaking Changes** | Yes      |
| `feat`                         | **✨ New Features**      | Yes      |
| `fix`                          | **🐛 Bug Fixes**         | Yes      |
| `refactor`                     | **🏗️ API**              | Yes      |
| `perf`                         | **🏗️ API**              | Yes      |
| `docs`                         | **📝 Documentation**     | Yes      |
| `style`                        | —                       | Skip     |
| `chore`                        | —                       | Skip     |
| `test`                         | —                       | Skip     |
| `ci`                           | —                       | Skip     |
| `build`                        | —                       | Skip     |
| `chore(release)`               | —                       | Skip     |

Rules:
- **Only include categories that have actual entries.** Do NOT add empty categories.
- Write **human-friendly descriptions**, not raw commit messages. Entries in this changelog
  are written for package users: lead with a bolded statement of the user-visible change,
  then indented sub-bullets explaining the cause and the fix where it helps.
- Group related commits when appropriate (e.g., multiple fixes for the same behavior).
- Breaking changes should include a **Migration Guide** subsection when the change requires
  user action, following the `## 0.2.0` precedent.

### Handling the `## Unreleased` section

`CHANGELOG.md` currently keeps an `## Unreleased` section at the top that is written
incrementally as work lands. If it exists:

- **Rename it in place** to `## X.Y.Z` rather than inserting a fresh section above it.
- Reconcile its contents against the commit analysis — add anything that landed but was
  never written into `Unreleased`, and fix anything now stale.
- If it does not exist, insert a new `## X.Y.Z` section at the very top of the file,
  above the previous version's section, preserving all existing content below.

Format (note: no brackets around the version, and **no date** — the CI release job extracts
notes with `awk "/## $VERSION/{flag=1; next} /^## /{flag=0} flag"`, so the heading must be
exactly `## X.Y.Z` for the GitHub Release body to be populated correctly):

```markdown
## X.Y.Z

One-sentence summary of what this release delivers.

### ✨ New Features

- **Short statement of the user-visible change**
  - Supporting detail explaining the behavior.

### 🐛 Bug Fixes

- **Short statement of what was broken and is now fixed**
  - Supporting detail explaining cause and fix.
```

## Step 6: Review & Confirm

Present a summary to the user before making any file changes:

```
Release Summary
───────────────
Current version: A.B.C
New version:     X.Y.Z (BUMP_TYPE bump)

Commits since last release: N total (M user-facing, K skipped)

CHANGELOG preview:
──────────────────
## X.Y.Z

Summary line.

### ✨ New Features
- ...

### 🐛 Bug Fixes
- ...
```

Use `AskUserQuestion` to confirm: "Does this release summary look correct? Should I proceed with updating files?"

Allow the user to request edits to the CHANGELOG content before proceeding.

## Step 7: Update Files

1. **`pubspec.yaml`**: Update the `version:` field to the new version.

2. **`CHANGELOG.md`**: Apply the entry from Step 5 (rename `## Unreleased` → `## X.Y.Z`, or
   insert the new section at the top). Preserve all existing content below.

3. **`README.md`**: This README currently has **no version-pinned install snippet** (it
   points users at `flutter pub add`), so normally there is nothing to update. Still grep for
   `context_show: ^` and `version: ^` before concluding that — if a pinned snippet has since
   been added, update every occurrence to `^X.Y.Z` by pattern matching, never by line number.

4. **`example/pubspec.lock`**: The example app depends on the package by relative path
   (`path: ".."`), so its lockfile pins `context_show`'s `version:` and goes stale after
   every bump. It **is** tracked in git (unlike the root `pubspec.lock`, which is
   gitignored), so regenerate it:

   ```bash
   (cd example && flutter pub get)
   ```

   Then verify and clean up:

   - Confirm the lockfile diff is **only** the `context_show` `version:` line changing to
     `X.Y.Z`. If `pub get` also bumped unrelated transitive dependencies, revert those — a
     release commit should not smuggle in dependency upgrades.
   - `flutter pub get` may regenerate CocoaPods artifacts (`example/ios/Podfile`,
     `example/macos/Podfile`, and `#include?` lines in `example/ios/Flutter/*.xcconfig` and
     `example/macos/Flutter/Flutter-*.xcconfig`). This repo does not track Podfiles, so
     discard anything of that kind that appears:
     ```bash
     git checkout -- 'example/**/*.xcconfig'
     rm -f example/ios/Podfile example/macos/Podfile
     ```
   - Re-run `git status --short` and confirm only `example/pubspec.lock` remains modified
     (plus the files from steps 1–3).

## Step 8: Commit & Tag

1. Stage changes: `git add pubspec.yaml CHANGELOG.md example/pubspec.lock` (add `README.md` only if step 7.3 actually changed it)
2. Create commit:
   ```
   git commit -m "chore(release): bump version to X.Y.Z"
   ```
3. Create annotated tag:
   ```
   git tag -a vX.Y.Z -m "Release version X.Y.Z"
   ```

## Step 9: Push to Repository

**IMPORTANT**: Pushing the tag will trigger the `release.yaml` CI workflow, which publishes to pub.dev. This is irreversible.

Use `AskUserQuestion` to confirm: "Ready to push? This will trigger pub.dev publishing and create a GitHub release."

If confirmed:
```
git push origin main --follow-tags
```

After pushing, inform the user:
- The `release.yaml` workflow has been triggered
- It will: run format/analyze/tests, validate that `pubspec.yaml` matches the tag, dry-run publish, publish to pub.dev via OIDC, and create a GitHub release with the changelog section as its body
- They can monitor progress at the repository's Actions tab (derive the URL from `git remote get-url origin` — note the remote may not match the package name)

If something goes wrong after push, provide rollback instructions:
```bash
# Delete remote tag
git push origin :refs/tags/vX.Y.Z
# Delete local tag
git tag -d vX.Y.Z
# Revert the release commit
git revert HEAD
git push origin main
```
