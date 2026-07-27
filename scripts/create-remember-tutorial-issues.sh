#!/usr/bin/env bash

set -euo pipefail

REPO="drewblue42/Audibility-Quest"
PARENT_ISSUE="21"
PARENT_TITLE="Remember Tutorial Completion"
MILESTONE_PREFIX="Milestone 2"
LABEL_NAME="M2"

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

# Find the exact milestone whose title begins with "Milestone 2".
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

# Match both title and parent so same-named issues elsewhere
# are not moved.
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

create_or_update_issue "Save tutorial completion in browser storage" <<'BODY'
## Description

Save tutorial-completion status in browser storage so the game remembers that the player has already completed the tutorial.

The saved value should remain available after refreshing or reopening the game.

## Acceptance Criteria

- [ ] The game uses browser storage, such as `localStorage`
- [ ] The storage key is defined in one shared location
- [ ] Completing the tutorial saves a true completion value
- [ ] The saved value persists after refreshing the page
- [ ] Replaying the tutorial does not create duplicate or conflicting values
- [ ] Storage logic is kept outside the tutorial scene where practical
- [ ] Storage errors do not crash the game
- [ ] The saved value contains only the information required for tutorial completion
BODY

create_or_update_issue "Read tutorial completion when the game starts" <<'BODY'
## Description

Read the saved tutorial-completion value when the game starts and load it into the appropriate game state.

## Acceptance Criteria

- [ ] Browser storage is checked during game initialization
- [ ] A saved true value marks the tutorial as completed
- [ ] A missing value defaults to false
- [ ] An invalid saved value uses a safe default
- [ ] RunState or saved-preference state receives the loaded value
- [ ] The instructions flow can use the value to show Skip Tutorial
- [ ] The game does not require the tutorial scene to load before reading the value
- [ ] Initialization completes without delaying or duplicating scene startup
BODY

create_or_update_issue "Preserve it after death and Play Again" <<'BODY'
## Description

Keep tutorial-completion status saved when the player dies, restarts a map, or chooses Play Again after winning.

Tutorial completion should be treated as a saved preference rather than temporary run progress.

## Acceptance Criteria

- [ ] Death does not clear tutorial completion
- [ ] Current-map restart does not clear tutorial completion
- [ ] New-run reset from Play Again does not clear tutorial completion
- [ ] Health and stamina resets do not affect the saved value
- [ ] Map-progress resets do not affect the saved value
- [ ] Skip Tutorial remains available after Play Again
- [ ] Refreshing the page after death or victory still preserves completion
- [ ] Only an intentional clear operation removes the saved value
BODY

create_or_update_issue "Add a developer option to clear it" <<'BODY'
## Description

Add a developer-only way to clear the saved tutorial-completion value for testing.

This allows developers and researchers to test the first-time tutorial flow without manually editing browser storage.

## Acceptance Criteria

- [ ] A dedicated developer method clears the saved completion value
- [ ] The in-memory tutorial-completion value also resets to false
- [ ] Clearing the value does not reset unrelated browser data
- [ ] The developer option is not presented as a normal player control
- [ ] The option can be called from the browser console or a development menu
- [ ] The storage key is referenced from the shared storage configuration
- [ ] The game safely handles clearing an already-missing value
- [ ] After clearing and refreshing, Skip Tutorial is unavailable
- [ ] The developer reset behavior is documented
BODY

echo
echo "Finished creating or updating Remember Tutorial Completion issues."
echo "Milestone: $MILESTONE_NAME"
echo
echo "Open the epic with:"
echo "gh issue view $PARENT_ISSUE --repo $REPO --web"
