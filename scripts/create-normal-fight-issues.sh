#!/usr/bin/env bash

set -euo pipefail

REPO="drewblue42/Audibility-Quest"
PARENT_ISSUE="13"
PARENT_TITLE="Normal Fight"
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

# Ensure the parent epic has the correct milestone, label, and assignee.
gh issue edit "$PARENT_ISSUE" \
  --repo "$REPO" \
  --milestone "$MILESTONE_NAME" \
  --add-label "$LABEL_NAME" \
  --add-assignee "@me"

# Find an existing issue only when its title and parent epic both match.
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

create_or_update_issue "Create normal monster data" <<'BODY'
## Description

Create the monster data needed for normal combat encounters.

Normal fights should load monsters from editable data rather than defining monster values directly inside the fight scene.

## Acceptance Criteria

- [ ] Normal monsters are stored in the shared monster data module
- [ ] Each monster has a unique identifier
- [ ] Each monster has a display name
- [ ] Each monster defines maximum health
- [ ] Each monster defines a sprite, texture, or placeholder appearance
- [ ] Normal fights can select the correct monster from the data
- [ ] Additional monsters can be added without rewriting fight-scene logic
- [ ] Invalid or missing monster data is handled safely
BODY

create_or_update_issue "Display player and monster" <<'BODY'
## Description

Display the player and selected monster in the normal fight scene.

## Acceptance Criteria

- [ ] The player appears in the fight scene
- [ ] The selected monster appears in the fight scene
- [ ] The monster name is displayed
- [ ] Player health is displayed
- [ ] Monster health is displayed
- [ ] Player stamina is displayed
- [ ] Player and monster positions leave enough room for the word grid
- [ ] The scene loads without overlapping critical interface elements
- [ ] Missing visual assets use an appropriate fallback
BODY

create_or_update_issue "Load the correct word table" <<'BODY'
## Description

Load the correct editable word table for the current normal fight.

## Acceptance Criteria

- [ ] The fight receives or determines the required word-table identifier
- [ ] The word table is loaded from editable data
- [ ] The selected table is passed to the shared word-grid system
- [ ] The fight scene does not hard-code the table contents
- [ ] Different encounters can use different word tables
- [ ] The word table remains consistent throughout one encounter
- [ ] Missing or invalid table data is handled without crashing
- [ ] Returning to another encounter can load a different table
BODY

create_or_update_issue "Use the shared word-grid system" <<'BODY'
## Description

Use the reusable word-grid component in normal fights.

This issue applies specifically to the Normal Fight epic and should not replace the equivalent Tutorial Fight issue.

## Acceptance Criteria

- [ ] Normal fights use the shared word-grid component
- [ ] The fight scene does not contain a duplicate grid implementation
- [ ] The selected word-table data is passed into the component
- [ ] One word can be selected from each column
- [ ] Other words in a selected column become disabled
- [ ] The grid reports when all columns are complete
- [ ] Selected words are returned in a predictable order
- [ ] The shared grid reset behavior works between combat rounds
BODY

create_or_update_issue "Use the shared combat system" <<'BODY'
## Description

Use the reusable scoring and damage-resolution system in normal fights.

This issue applies specifically to the Normal Fight epic and should not replace the equivalent Tutorial Fight issue.

## Acceptance Criteria

- [ ] Scores zero through five use the shared score data
- [ ] Player damage uses the shared combat logic
- [ ] Monster damage uses the shared combat logic
- [ ] Health cannot fall below zero
- [ ] Damage numbers use the shared display behavior
- [ ] Repeated score input is prevented
- [ ] The word grid resets after the round finishes
- [ ] Combat checks for player and monster defeat
- [ ] Normal-fight configuration does not duplicate combat logic
BODY

create_or_update_issue "Allow the experimenter to end the fight" <<'BODY'
## Description

Allow the experimenter to manually end a normal fight with Enter or Space.

## Acceptance Criteria

- [ ] Enter triggers the manual fight-ending behavior
- [ ] Space triggers the manual fight-ending behavior
- [ ] The fight can be ended while the word grid is incomplete
- [ ] Further scoring input is disabled immediately
- [ ] The word grid is disabled or destroyed
- [ ] Active attack input cannot resolve after the fight ends
- [ ] Repeated Enter or Space input does not start multiple transitions
- [ ] Keyboard listeners are cleaned up when the scene shuts down
- [ ] The player returns to the intended map location
BODY

create_or_update_issue "Add monster defeat animation" <<'BODY'
## Description

Play a visible defeat animation when the monster reaches zero health.

## Acceptance Criteria

- [ ] Monster defeat begins when monster health reaches zero
- [ ] Combat input is disabled before the animation begins
- [ ] The word grid is disabled or removed
- [ ] The monster visibly fades, falls, disappears, or plays its configured animation
- [ ] The animation plays only once
- [ ] The monster cannot receive more damage after defeat
- [ ] The corresponding map node is marked completed
- [ ] Scene transition occurs after the animation finishes
- [ ] Missing animation assets use a safe fallback
BODY

create_or_update_issue "Return to the correct map node" <<'BODY'
## Description

Return the player to the correct map and node after a normal fight ends.

## Acceptance Criteria

- [ ] The fight receives the return-scene identifier
- [ ] The fight receives the encounter node identifier
- [ ] RunState preserves the player's current map
- [ ] RunState preserves the player's current map position
- [ ] Winning marks the encounter node as completed
- [ ] Manually ending the fight follows the intended completion behavior
- [ ] Running follows the intended node-position behavior
- [ ] Returning to the map displays the player on the correct node
- [ ] The fight triggers only one scene transition
- [ ] Temporary combat objects and listeners are cleaned up
BODY

create_or_update_issue "Open the death screen when health reaches zero" <<'BODY'
## Description

Open the death screen when the player's health reaches zero during a normal fight.

## Acceptance Criteria

- [ ] Player health is checked after combat damage is applied
- [ ] Zero health triggers the death flow
- [ ] Negative health values are prevented
- [ ] Combat input is disabled immediately
- [ ] The word grid is disabled or destroyed
- [ ] Running and manual fight-ending controls are disabled
- [ ] The normal map-return transition is cancelled
- [ ] The death scene opens only once
- [ ] The death scene receives the information needed for restart behavior
- [ ] Keyboard listeners and temporary combat objects are cleaned up
BODY

echo
echo "Finished creating or updating Normal Fight issues."
echo
echo "Open the epic with:"
echo "gh issue view $PARENT_ISSUE --repo $REPO --web"
