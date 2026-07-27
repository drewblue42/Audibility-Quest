#!/usr/bin/env bash

set -euo pipefail

REPO="drewblue42/Audibility-Quest"
PARENT_ISSUE="14"
PARENT_TITLE="Campsite"
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

create_or_update_issue "Create campsite screen" <<'BODY'
## Description

Create a dedicated campsite screen that opens when the player reaches a campsite node.

The campsite should allow the player to choose one recovery option before returning to the map.

## Acceptance Criteria

- [ ] A dedicated Phaser campsite scene exists
- [ ] The scene receives the return-map identifier
- [ ] The scene receives the campsite node identifier
- [ ] The campsite clearly displays its purpose
- [ ] Health and stamina restoration controls have dedicated space
- [ ] The interface fits within the configured game dimensions
- [ ] The scene loads without console errors
- [ ] Temporary campsite input is cleaned up when the scene closes
BODY

create_or_update_issue "Display current health and stamina" <<'BODY'
## Description

Display the player's current and maximum health and stamina on the campsite screen.

## Acceptance Criteria

- [ ] Current health is displayed
- [ ] Maximum health is displayed
- [ ] Current stamina is displayed
- [ ] Maximum stamina is displayed
- [ ] Values are loaded directly from RunState
- [ ] Displays update immediately after restoration
- [ ] Zero and maximum values display correctly
- [ ] The campsite does not maintain conflicting copies of player state
BODY

create_or_update_issue "Add Restore Health option" <<'BODY'
## Description

Add an option that restores the player's health at the campsite.

## Acceptance Criteria

- [ ] A clearly labeled Restore Health option is displayed
- [ ] Selecting it restores health according to the configured campsite rule
- [ ] Health cannot exceed maximum health
- [ ] Restoration updates RunState
- [ ] The health display updates immediately
- [ ] The option can be selected only once per campsite visit
- [ ] The option is disabled when the player already has maximum health
- [ ] Selecting it prevents the stamina option from also being selected
BODY

create_or_update_issue "Add Restore Stamina option" <<'BODY'
## Description

Add an option that restores the player's stamina at the campsite.

## Acceptance Criteria

- [ ] A clearly labeled Restore Stamina option is displayed
- [ ] Selecting it restores stamina according to the configured campsite rule
- [ ] Stamina cannot exceed maximum stamina
- [ ] Restoration updates RunState
- [ ] The stamina display updates immediately
- [ ] The option can be selected only once per campsite visit
- [ ] The option is disabled when the player already has maximum stamina
- [ ] Selecting it prevents the health option from also being selected
BODY

create_or_update_issue "Prevent selecting both options" <<'BODY'
## Description

Ensure the player can restore either health or stamina during one campsite visit, but not both.

## Acceptance Criteria

- [ ] No restoration option is selected when the campsite first opens
- [ ] Selecting Restore Health disables Restore Stamina
- [ ] Selecting Restore Stamina disables Restore Health
- [ ] Rapid clicking cannot activate both options
- [ ] Restoration is applied only once
- [ ] Disabled options ignore pointer and keyboard input
- [ ] Leaving and revisiting a campsite follows the intended reuse rules
- [ ] The selection state is separate from permanent player state
BODY

create_or_update_issue "Show restoration feedback" <<'BODY'
## Description

Show clear visual feedback after the player restores health or stamina.

## Acceptance Criteria

- [ ] Health restoration displays a confirmation message
- [ ] Stamina restoration displays a confirmation message
- [ ] The message identifies the amount restored where appropriate
- [ ] Updated health or stamina values are visible
- [ ] The selected option has a completed or disabled appearance
- [ ] The unselected option becomes unavailable
- [ ] Repeated messages do not overlap
- [ ] The player can clearly tell when the campsite action is complete
BODY

create_or_update_issue "Return to the correct map node" <<'BODY'
## Description

Return the player to the correct map and campsite node after completing the campsite interaction.

## Acceptance Criteria

- [ ] The campsite receives the return-map scene identifier
- [ ] The campsite receives its map node identifier
- [ ] RunState preserves the current map
- [ ] RunState preserves the campsite as the current position
- [ ] Reaching the campsite updates the current checkpoint
- [ ] The campsite node is marked completed when appropriate
- [ ] The player returns only after making a valid choice
- [ ] The return transition occurs only once
- [ ] The player marker appears on the correct campsite node
- [ ] Campsite buttons and listeners are cleaned up before transition
BODY

echo
echo "Finished creating or updating Campsite issues."
echo
echo "Open the epic with:"
echo "gh issue view $PARENT_ISSUE --repo $REPO --web"
