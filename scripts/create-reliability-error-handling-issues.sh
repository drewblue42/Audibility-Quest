#!/usr/bin/env bash

set -euo pipefail

REPO="drewblue42/Audibility-Quest"
PARENT_ISSUE="24"
PARENT_TITLE="Reliability and Error Handling"
MILESTONE_PREFIX="Milestone 3"
LABEL_NAME="M3"

echo "Repository: $REPO"
echo "Parent epic: #$PARENT_ISSUE $PARENT_TITLE"
echo

actual_parent_title=$(
  gh issue view "$PARENT_ISSUE" \
    --repo "$REPO" \
    --json title \
    --jq '.title'
)

if [[ "$actual_parent_title" != "$PARENT_TITLE" ]]; then
  echo "Error: Issue #$PARENT_ISSUE is titled '$actual_parent_title'."
  echo "Expected: $PARENT_TITLE"
  exit 1
fi

# Find the exact repository milestone beginning with "Milestone 3".
MILESTONE_NAME=$(
  gh api \
    "repos/$REPO/milestones?state=all&per_page=100" \
    --jq ".[] | select(.title | startswith(\"$MILESTONE_PREFIX\")) | .title" \
    2>/dev/null || true
)

MILESTONE_COUNT=$(
  printf '%s\n' "$MILESTONE_NAME" |
    sed '/^[[:space:]]*$/d' |
    wc -l |
    tr -d ' '
)

if [[ "$MILESTONE_COUNT" -eq 0 ]]; then
  echo "Error: No milestone beginning with '$MILESTONE_PREFIX' was found."
  echo
  echo "Available milestones:"

  gh api \
    "repos/$REPO/milestones?state=all&per_page=100" \
    --jq '.[].title'

  exit 1
fi

if [[ "$MILESTONE_COUNT" -gt 1 ]]; then
  echo "Error: Multiple milestones begin with '$MILESTONE_PREFIX':"
  printf '%s\n' "$MILESTONE_NAME"
  echo
  echo "Set MILESTONE_NAME manually near the top of the script."
  exit 1
fi

echo "Found parent epic: $actual_parent_title"
echo "Found milestone: $MILESTONE_NAME"
echo

# Keep the parent epic assigned correctly.
gh issue edit "$PARENT_ISSUE" \
  --repo "$REPO" \
  --milestone "$MILESTONE_NAME" \
  --add-label "$LABEL_NAME" \
  --add-assignee "@me"

# Match both title and parent so similarly named issues under
# other epics are not moved.
find_child_issue_number() {
  local title="$1"

  gh issue list \
    --repo "$REPO" \
    --state all \
    --limit 500 \
    --json number,title,parent \
    --jq "
      .[] |
      select(
        .title == \"$title\" and
        ((.parent.number // 0) == $PARENT_ISSUE)
      ) |
      .number
    " |
    head -n 1
}

create_or_update_issue() {
  local title="$1"
  local body_file
  local existing_number
  local issue_url

  body_file="$(mktemp)"
  cat > "$body_file"

  existing_number="$(find_child_issue_number "$title")"

  if [[ -n "$existing_number" ]]; then
    echo "Updating existing issue #$existing_number: $title"

    gh issue edit "$existing_number" \
      --repo "$REPO" \
      --body-file "$body_file" \
      --milestone "$MILESTONE_NAME" \
      --add-label "$LABEL_NAME" \
      --add-assignee "@me" \
      --parent "$PARENT_ISSUE"

    rm -f "$body_file"
    return
  fi

  echo "Creating: $title"

  issue_url=$(
    gh issue create \
      --repo "$REPO" \
      --title "$title" \
      --body-file "$body_file" \
      --milestone "$MILESTONE_NAME" \
      --label "$LABEL_NAME" \
      --assignee "@me" \
      --parent "$PARENT_ISSUE"
  )

  rm -f "$body_file"
  echo "$issue_url"
}

create_or_update_issue "Prevent duplicate scene changes" <<'BODY'
## Description

Prevent multiple callbacks, rapid input, or delayed events from starting the same Phaser scene transition more than once.

## Acceptance Criteria

- [ ] Scenes track whether a transition has already begun
- [ ] Pointer controls are disabled after a transition starts
- [ ] Keyboard controls are disabled after a transition starts
- [ ] Rapid button clicks do not start duplicate scenes
- [ ] Repeated Enter or Space input does not start duplicate scenes
- [ ] Delayed callbacks check whether the scene is still active
- [ ] Fight-ending and death transitions cannot both run
- [ ] Monster-defeat and manual-exit transitions cannot both run
- [ ] Transition flags reset when a scene is created again
- [ ] Scene shutdown removes temporary input listeners
BODY

create_or_update_issue "Handle missing monster data" <<'BODY'
## Description

Handle missing, invalid, or unknown monster data without causing an unclear runtime crash.

## Acceptance Criteria

- [ ] Monster identifiers are checked before use
- [ ] Unknown monster identifiers are detected
- [ ] Missing maximum-health values are detected
- [ ] Invalid health values are rejected or replaced safely
- [ ] Missing names use a clear fallback
- [ ] Missing images use a placeholder appearance
- [ ] Missing size values use documented defaults
- [ ] Missing defeat-animation settings use a safe default
- [ ] Development errors identify the affected monster or fight node
- [ ] The game either loads a fallback monster or exits the encounter safely
BODY

create_or_update_issue "Handle missing map data" <<'BODY'
## Description

Handle unknown maps and malformed map data without leaving the game in an unusable state.

## Acceptance Criteria

- [ ] Current-map identifiers are validated before loading
- [ ] Unknown map identifiers are detected
- [ ] Missing starting nodes are detected
- [ ] Missing final nodes are handled according to map requirements
- [ ] Invalid node identifiers are detected
- [ ] Connections to nonexistent nodes are detected
- [ ] Invalid encounter types are detected
- [ ] Missing map themes use a safe default
- [ ] Development errors identify the affected map and node
- [ ] The game falls back to a safe map or title screen when recovery is possible
- [ ] Invalid data does not produce an endless scene-transition loop
BODY

create_or_update_issue "Handle missing images" <<'BODY'
## Description

Provide safe visual fallbacks when player, monster, map, button, or background images fail to load.

## Acceptance Criteria

- [ ] Image-loading errors are detected
- [ ] Missing monster images use a placeholder
- [ ] Missing player images use a placeholder
- [ ] Missing map backgrounds use a default background
- [ ] Missing node images use a basic shape or default texture
- [ ] Game controls remain usable when decorative images are missing
- [ ] Placeholder dimensions fit within the scene
- [ ] Development output identifies the missing texture key or path
- [ ] A missing image does not stop unrelated game logic
- [ ] Required and optional images are documented
BODY

create_or_update_issue "Handle empty word columns" <<'BODY'
## Description

Detect empty or malformed word-table columns before the word grid attempts to display them.

## Acceptance Criteria

- [ ] Word tables are checked before grid creation
- [ ] A table with no columns is detected
- [ ] Empty columns are detected
- [ ] Columns containing only empty strings are detected
- [ ] Invalid non-array columns are detected
- [ ] Invalid non-string word values are detected
- [ ] The grid does not wait forever for an empty column selection
- [ ] Scoring remains disabled when required data is invalid
- [ ] Development errors identify the table and column
- [ ] The scene displays a safe error message or returns to a safe screen
- [ ] Valid tables continue working normally
BODY

create_or_update_issue "Prevent negative health and stamina" <<'BODY'
## Description

Ensure health and stamina values never fall below zero, regardless of where damage or stamina costs are applied.

## Acceptance Criteria

- [ ] Player health has a minimum value of zero
- [ ] Player stamina has a minimum value of zero
- [ ] Monster health has a minimum value of zero
- [ ] Damage greater than remaining health results in zero
- [ ] Running cannot reduce stamina below zero
- [ ] Direct state methods clamp invalid values
- [ ] Scene code does not bypass shared state methods
- [ ] Health displays never show negative values
- [ ] Stamina displays never show negative values
- [ ] Zero-health death detection still works
- [ ] Zero-stamina run restrictions still work
BODY

create_or_update_issue "Recover from invalid saved progress" <<'BODY'
## Description

Validate saved browser progress and recover safely when saved values are missing, malformed, outdated, or inconsistent with the current game data.

## Acceptance Criteria

- [ ] Saved data is parsed inside error handling
- [ ] Invalid JSON does not crash game startup
- [ ] Missing saved fields receive safe defaults
- [ ] Unknown saved map identifiers are detected
- [ ] Unknown saved node identifiers are detected
- [ ] Invalid completed-node collections are repaired or reset
- [ ] Invalid health and stamina values are clamped
- [ ] Tutorial-completion data is validated
- [ ] Older save formats can be migrated or safely reset
- [ ] Recovery preserves valid saved fields where practical
- [ ] Unrecoverable progress falls back to a documented safe state
- [ ] The player receives a clear message if progress must be reset
- [ ] Development logs explain why recovery occurred
BODY

create_or_update_issue "Add useful development error messages" <<'BODY'
## Description

Add clear development-facing error and warning messages for invalid content, state, and scene behavior.

Messages should help identify the source of a problem without exposing unnecessary technical information in the player interface.

## Acceptance Criteria

- [ ] Errors identify the relevant scene or system
- [ ] Monster errors include the monster identifier
- [ ] Map errors include the map and node identifiers
- [ ] Word-table errors include the table and column
- [ ] Missing-image errors include the texture key or file path
- [ ] Invalid saved-state errors identify the affected field
- [ ] Duplicate-transition warnings identify the scene
- [ ] Errors distinguish required-data failures from optional-data warnings
- [ ] Player-facing messages remain understandable and brief
- [ ] Development details are written to the console
- [ ] Repeated identical errors do not flood the console unnecessarily
- [ ] Error-message conventions are documented
BODY

echo
echo "Finished creating or updating Reliability and Error Handling issues."
echo "Milestone: $MILESTONE_NAME"
echo
echo "Open the epic with:"
echo "gh issue view $PARENT_ISSUE --repo $REPO --web"
