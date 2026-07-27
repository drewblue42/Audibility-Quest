#!/usr/bin/env bash

set -euo pipefail

REPO="drewblue42/Audibility-Quest"
PARENT_ISSUE="11"
PARENT_TITLE="Tutorial Fight"
MILESTONE_NAME="Milestone 1: Core Playable Loop"
LABEL_NAME="M1"

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

milestone_exists=$(
  gh api \
    "repos/$REPO/milestones?state=all&per_page=100" \
    --jq ".[] | select(.title == \"$MILESTONE_NAME\") | .title" \
    2>/dev/null || true
)

if [[ -z "$milestone_exists" ]]; then
  echo "Error: Could not find milestone '$MILESTONE_NAME'."
  exit 1
fi

echo "Found parent epic: $actual_parent_title"
echo "Found milestone: $MILESTONE_NAME"
echo

# Keep the parent epic assigned to the correct milestone and label.
gh issue edit "$PARENT_ISSUE" \
  --repo "$REPO" \
  --milestone "$MILESTONE_NAME" \
  --add-label "$LABEL_NAME" \
  --add-assignee "@me"

# Find an existing issue only when both its title and parent match.
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

create_or_update_issue "Create dummy monster" <<'BODY'
## Description

Create a predictable dummy monster for the tutorial fight.

The dummy should let the player practice combat without relying on random monster selection.

## Acceptance Criteria

- [ ] A tutorial dummy is defined in the monster data
- [ ] The dummy has a unique identifier
- [ ] The dummy has a display name
- [ ] The dummy has a configured maximum-health value
- [ ] The dummy has a visual appearance or placeholder
- [ ] The tutorial always loads the dummy instead of a random monster
- [ ] Dummy health resets when a new tutorial starts
BODY

create_or_update_issue "Load tutorial word table" <<'BODY'
## Description

Load a tutorial-specific word table that can be used to teach the word-selection mechanics.

## Acceptance Criteria

- [ ] Tutorial words are stored in editable data
- [ ] The tutorial scene loads the correct word table
- [ ] The data contains the required number of columns
- [ ] Each column contains selectable words
- [ ] Tutorial word data is separate from scene logic
- [ ] The tutorial grid renders from the supplied data
- [ ] Missing or invalid tutorial word data is handled safely
BODY

create_or_update_issue "Add tutorial instructions" <<'BODY'
## Description

Display instructions during the tutorial fight that explain what the player should do.

## Acceptance Criteria

- [ ] Instructions explain that one word must be selected per column
- [ ] Instructions explain when scoring input becomes available
- [ ] Instructions explain scores zero through five
- [ ] Instructions explain player and monster damage
- [ ] Instructions explain how to end the tutorial
- [ ] Instruction text is readable during the fight
- [ ] Tutorial instructions can be updated without rewriting combat logic
BODY

create_or_update_issue "Guide the player through selecting words" <<'BODY'
## Description

Guide the player through the word-selection process during the tutorial.

## Acceptance Criteria

- [ ] The tutorial identifies the next required action
- [ ] The player is prompted to select a word from each column
- [ ] Completed columns are visually distinguishable
- [ ] The status message updates as selections are made
- [ ] The player is notified when every column is complete
- [ ] Scoring input remains disabled until all selections are complete
- [ ] Guidance resets correctly for each practice round
BODY

create_or_update_issue "Use the shared word-grid system" <<'BODY'
## Description

Use the same reusable word-grid component in both tutorial and normal combat.

## Acceptance Criteria

- [ ] The tutorial uses the shared GridOfButtons or word-grid component
- [ ] The tutorial does not contain a separate duplicate grid implementation
- [ ] Tutorial word data can be passed into the shared component
- [ ] One-selection-per-column behavior works
- [ ] Disabled and selected button states work
- [ ] Grid completion is reported to the tutorial scene
- [ ] The shared reset behavior works between practice rounds
BODY

create_or_update_issue "Use the shared combat system" <<'BODY'
## Description

Use the reusable combat-resolution behavior during the tutorial instead of creating a separate damage system.

## Acceptance Criteria

- [ ] Tutorial scores use the shared score rules
- [ ] Player damage uses the shared damage logic
- [ ] Monster damage uses the shared damage logic
- [ ] Health values cannot fall below zero
- [ ] Damage numbers use the shared display behavior
- [ ] Repeated score input is prevented
- [ ] Tutorial-specific behavior is configured without duplicating combat logic
BODY

create_or_update_issue "Allow multiple practice rounds" <<'BODY'
## Description

Allow the player to complete multiple scoring rounds against the tutorial dummy.

## Acceptance Criteria

- [ ] The tutorial continues after the first score
- [ ] The word grid resets after each completed round
- [ ] The dummy's remaining health persists between rounds
- [ ] The player's remaining health persists between rounds
- [ ] Each round requires a new set of word selections
- [ ] Scoring is disabled during round animations
- [ ] Temporary damage text is cleared before the next round
- [ ] Practice rounds stop after the tutorial ends
BODY

create_or_update_issue "End tutorial with Enter or Space" <<'BODY'
## Description

Allow the experimenter to finish the tutorial fight by pressing Enter or Space.

## Acceptance Criteria

- [ ] Enter ends the tutorial
- [ ] Space ends the tutorial
- [ ] The tutorial can be ended between practice rounds
- [ ] Further score input is disabled immediately
- [ ] The word grid is disabled or destroyed
- [ ] Repeated key input does not trigger multiple transitions
- [ ] Tutorial-completion behavior runs before leaving the scene
BODY

create_or_update_issue "Unlock Skip Tutorial" <<'BODY'
## Description

Unlock the Skip Tutorial option after the player completes the tutorial for the first time.

## Acceptance Criteria

- [ ] Tutorial completion is recorded in RunState or persistent game state
- [ ] Completing the tutorial changes the completion value to true
- [ ] The title or instructions flow reads the completion value
- [ ] Skip Tutorial is unavailable before completion
- [ ] Skip Tutorial becomes available after completion
- [ ] Replaying the tutorial does not incorrectly lock the button
- [ ] Starting a new game follows the intended tutorial-reset behavior
BODY

create_or_update_issue "Continue to Map 1" <<'BODY'
## Description

Transition the player from the completed tutorial to Map 1.

## Acceptance Criteria

- [ ] Completing the tutorial updates tutorial-completion state
- [ ] Current map state is set to Map 1
- [ ] Current map position is set to Map 1's starting node
- [ ] The tutorial scene transitions to the Map 1 scene
- [ ] The transition occurs only once
- [ ] Tutorial game objects and keyboard listeners are cleaned up
- [ ] Map 1 loads without requiring a page refresh
- [ ] Skipping an unlocked tutorial can use the same destination
BODY

echo
echo "Finished creating or updating Tutorial Fight issues."
echo
echo "Open the epic with:"
echo "gh issue view $PARENT_ISSUE --repo $REPO --web"
