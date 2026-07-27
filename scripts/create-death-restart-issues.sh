#!/usr/bin/env bash

set -euo pipefail

REPO="drewblue42/Audibility-Quest"
PARENT_ISSUE="15"
PARENT_TITLE="Death and Restart"
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

# Find an existing issue only when its title and parent both match.
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

create_or_update_issue "Detect zero health" <<'BODY'
## Description

Detect when the player's health reaches zero and begin the death flow.

## Acceptance Criteria

- [ ] Player health is checked after damage is applied
- [ ] Health equal to zero triggers death
- [ ] Health above zero does not trigger death
- [ ] Death is triggered only once
- [ ] Combat input is disabled immediately
- [ ] Word-grid input is disabled or removed
- [ ] Running and manual fight-ending controls are disabled
- [ ] Normal map-return transitions are cancelled
- [ ] The death screen opens after any required damage animation
BODY

create_or_update_issue "Prevent health from going below zero" <<'BODY'
## Description

Clamp the player's health so damage cannot reduce it below zero.

## Acceptance Criteria

- [ ] Player damage is applied through RunState
- [ ] Health uses zero as its minimum value
- [ ] Damage greater than the remaining health results in zero health
- [ ] The health display never shows a negative number
- [ ] Death detection works when damage would otherwise produce a negative value
- [ ] The rule applies consistently across all combat encounters
- [ ] Direct scene code does not bypass the RunState health method
BODY

create_or_update_issue "Create death screen" <<'BODY'
## Description

Create a dedicated screen that appears after the player's health reaches zero.

## Acceptance Criteria

- [ ] A dedicated Phaser death scene exists
- [ ] The screen clearly communicates that the player was defeated
- [ ] The scene loads after zero health is detected
- [ ] The scene prevents combat input from continuing
- [ ] The screen includes space for restart controls
- [ ] The layout fits within the configured game dimensions
- [ ] The death scene loads without console errors
- [ ] Temporary keyboard and pointer listeners are cleaned up on shutdown
BODY

create_or_update_issue "Add Continue button" <<'BODY'
## Description

Add a Continue button to the death screen that restarts the current map.

## Acceptance Criteria

- [ ] A clearly labeled Continue button appears
- [ ] The button has an appropriate interactive hit area
- [ ] The button provides hover or pressed feedback
- [ ] Selecting Continue begins the restart process
- [ ] The button becomes disabled after it is selected
- [ ] Rapid clicks cannot start multiple resets
- [ ] The button uses the shared Button component where appropriate
- [ ] The scene transitions only after restart state is prepared
BODY

create_or_update_issue "Restore full health" <<'BODY'
## Description

Restore the player's health to maximum health when continuing after death.

## Acceptance Criteria

- [ ] Current health becomes equal to maximum health
- [ ] Health is restored through RunState
- [ ] Maximum health itself is not changed
- [ ] Health is restored before the map scene reloads
- [ ] The next scene displays the restored value
- [ ] Restoration occurs only as part of the death-restart flow
- [ ] Previously earned maximum-health changes are preserved
BODY

create_or_update_issue "Restore full stamina" <<'BODY'
## Description

Restore the player's stamina to maximum stamina when continuing after death.

## Acceptance Criteria

- [ ] Current stamina becomes equal to maximum stamina
- [ ] Stamina is restored through RunState
- [ ] Maximum stamina itself is not changed
- [ ] Stamina is restored before the map scene reloads
- [ ] The next scene displays the restored value
- [ ] Restoration occurs only as part of the death-restart flow
- [ ] Previously earned maximum-stamina changes are preserved
BODY

create_or_update_issue "Reset the current map" <<'BODY'
## Description

Reset progress for the player's current map after death without resetting the entire game.

## Acceptance Criteria

- [ ] The current map identifier is preserved
- [ ] Completed nodes for the current map are cleared or restored to the intended checkpoint state
- [ ] Temporary encounter state for the current map is cleared
- [ ] Progress from earlier completed maps is preserved
- [ ] Tutorial-completion state is preserved
- [ ] The reset does not behave like a new-game reset
- [ ] The reset logic is handled through a dedicated RunState method
- [ ] The map can be restarted repeatedly without accumulating invalid state
BODY

create_or_update_issue "Return to the current map’s starting node" <<'BODY'
## Description

Return the player to the starting node of the current map after continuing from the death screen.

## Acceptance Criteria

- [ ] The current map remains unchanged
- [ ] The map's configured starting node is loaded from map data
- [ ] RunState current position is set to the starting node
- [ ] The player marker appears on the starting node
- [ ] The previous encounter node is not retained
- [ ] The player can move normally after returning
- [ ] The death screen starts only one map transition
- [ ] Missing starting-node data is handled safely
BODY

create_or_update_issue "Preserve previously unlocked maps" <<'BODY'
## Description

Preserve maps that were unlocked before the player died and restarted the current map.

## Acceptance Criteria

- [ ] The unlocked-map collection is not cleared by current-map restart
- [ ] Previously unlocked maps remain accessible
- [ ] Completed-map records are preserved unless intentionally reset
- [ ] Only current-map progress is restarted
- [ ] Tutorial-completion state remains unchanged
- [ ] A full new-game reset can still clear unlocked maps when intended
- [ ] The restart method clearly separates current-map state from overall run progress
- [ ] Restarting Map 1 does not incorrectly lock or erase later unlocked maps
BODY

echo
echo "Finished creating or updating Death and Restart issues."
echo
echo "Open the epic with:"
echo "gh issue view $PARENT_ISSUE --repo $REPO --web"
