#!/usr/bin/env bash

set -euo pipefail

REPO="drewblue42/Audibility-Quest"
PARENT_ISSUE="20"
PARENT_TITLE="Victory and Play Again"
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

# Match both title and parent so same-named issues under other epics
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

create_or_update_issue "Create Win screen" <<'BODY'
## Description

Create a dedicated victory screen that appears after the player completes the final map.

## Acceptance Criteria

- [ ] A dedicated Phaser victory scene exists
- [ ] The scene opens after final-map completion
- [ ] The victory screen opens only once
- [ ] Map and combat input are disabled before the transition
- [ ] The layout fits within the configured game dimensions
- [ ] The screen includes space for a victory message
- [ ] The screen includes space for the Play Again button
- [ ] The scene loads without console errors
- [ ] Temporary keyboard and pointer listeners are cleaned up on shutdown
BODY

create_or_update_issue "Display victory message" <<'BODY'
## Description

Display a clear message confirming that the player completed the game.

## Acceptance Criteria

- [ ] The victory message is clearly visible
- [ ] The message communicates that the final dungeon or map was completed
- [ ] Long text wraps within the game window
- [ ] The message remains separate from button labels
- [ ] Victory text can be loaded from editable data where appropriate
- [ ] Changing the message does not require changing reset logic
- [ ] Missing message data uses a safe default
BODY

create_or_update_issue "Add Play Again button" <<'BODY'
## Description

Add a Play Again button to the victory screen that begins the new-run reset process.

## Acceptance Criteria

- [ ] A clearly labeled Play Again button appears
- [ ] The button has an appropriate interactive hit area
- [ ] The button provides hover or pressed feedback
- [ ] Selecting it calls a dedicated play-again method
- [ ] The button becomes disabled after selection
- [ ] Rapid clicks cannot trigger multiple resets
- [ ] The shared Button component is used where appropriate
- [ ] The next scene loads only after reset state is prepared
BODY

create_or_update_issue "Reset health and stamina" <<'BODY'
## Description

Restore the player's health and stamina when Play Again starts a new run.

## Acceptance Criteria

- [ ] Current health becomes equal to maximum health
- [ ] Current stamina becomes equal to maximum stamina
- [ ] Maximum health is preserved
- [ ] Maximum stamina is preserved
- [ ] Values are reset through RunState
- [ ] Health cannot exceed maximum health
- [ ] Stamina cannot exceed maximum stamina
- [ ] The reset occurs before the next playable scene loads
- [ ] New displays show the restored values
BODY

create_or_update_issue "Reset map progress" <<'BODY'
## Description

Clear the previous run's map progression when the player chooses Play Again.

## Acceptance Criteria

- [ ] Current map returns to the configured starting map
- [ ] Current map position returns to the starting node
- [ ] Completed map nodes are cleared
- [ ] Current checkpoint returns to the initial checkpoint
- [ ] Completed maps are cleared
- [ ] Unlocked maps return to the intended new-run state
- [ ] Temporary combat and campsite state is cleared
- [ ] The reset uses a dedicated RunState method
- [ ] Repeated play-again resets do not create invalid state
- [ ] Tutorial-completion state is not cleared by this operation
BODY

create_or_update_issue "Return to the title screen" <<'BODY'
## Description

Return the player to the title screen after the Play Again reset is complete.

## Acceptance Criteria

- [ ] Play Again completes the required state reset first
- [ ] The victory scene transitions to the title scene
- [ ] The transition occurs only once
- [ ] The title screen loads without requiring a page refresh
- [ ] Victory-screen controls are disabled during transition
- [ ] Victory-screen listeners and game objects are cleaned up
- [ ] Pressing Start begins a new run using the reset values
- [ ] Previous map or combat scenes do not remain active
BODY

create_or_update_issue "Keep tutorial completion saved" <<'BODY'
## Description

Preserve tutorial-completion status when the player finishes the game and chooses Play Again.

This allows returning players to skip the tutorial while still resetting ordinary run progress.

## Acceptance Criteria

- [ ] Tutorial completion is stored separately from temporary run progress
- [ ] Play Again does not change a completed tutorial value back to false
- [ ] Map progress is reset independently of tutorial completion
- [ ] Health and stamina resets do not affect tutorial completion
- [ ] The title and instruction scenes can read the preserved value
- [ ] A full data-clear operation can still reset tutorial completion when intended
- [ ] The distinction between new-run state and saved preference state is documented
BODY

create_or_update_issue "Make Skip Tutorial available" <<'BODY'
## Description

Make the Skip Tutorial option available after returning to the title or instruction flow when the tutorial has already been completed.

## Acceptance Criteria

- [ ] The title or instruction flow checks tutorial-completion state
- [ ] Skip Tutorial is available when completion is true
- [ ] Skip Tutorial remains unavailable when completion is false
- [ ] Play Again preserves the value used by this check
- [ ] Selecting Skip Tutorial starts the player at the intended first map
- [ ] Skipping sets the current map to the starting map
- [ ] Skipping sets the current position to the starting node
- [ ] Skipping does not restore old map progress
- [ ] Repeated button input cannot trigger multiple transitions
- [ ] The button state updates correctly after completing the tutorial
BODY

echo
echo "Finished creating or updating Victory and Play Again issues."
echo "Milestone: $MILESTONE_NAME"
echo
echo "Open the epic with:"
echo "gh issue view $PARENT_ISSUE --repo $REPO --web"
