#!/usr/bin/env bash

set -euo pipefail

REPO="drewblue42/Audibility-Quest"
PARENT_ISSUE="16"
PARENT_TITLE="Map 1 Completion"
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

create_or_update_issue "Detect the final Map 1 node" <<'BODY'
## Description

Detect when the player reaches and completes the final node on Map 1.

## Acceptance Criteria

- [ ] Map 1 data identifies its final node
- [ ] The map scene recognizes when the player selects the final node
- [ ] The final node cannot be completed before its requirements are met
- [ ] Reaching the final node updates the player's map position
- [ ] Completing the final node marks Map 1 as completed
- [ ] Map completion is triggered only once
- [ ] Normal movement input is disabled during the completion transition
- [ ] Invalid or missing final-node data is handled safely
BODY

create_or_update_issue "Create map-complete screen" <<'BODY'
## Description

Create a dedicated screen shown after the player completes Map 1.

## Acceptance Criteria

- [ ] A dedicated Phaser map-complete scene exists
- [ ] The scene opens after Map 1 completion is detected
- [ ] The screen clearly communicates that the map was completed
- [ ] The layout fits within the configured game dimensions
- [ ] The scene includes space for the completion message and Continue button
- [ ] Map input cannot continue behind the completion screen
- [ ] The screen loads without console errors
- [ ] Temporary keyboard and pointer listeners are cleaned up on shutdown
BODY

create_or_update_issue "Display the dungeon message" <<'BODY'
## Description

Display the required dungeon-completion message on the Map 1 completion screen.

## Acceptance Criteria

- [ ] The completion message is clearly visible
- [ ] The message identifies that the dungeon or Map 1 was completed
- [ ] Long text wraps within the game window
- [ ] The message is separate from button labels
- [ ] The message can be loaded from editable data where appropriate
- [ ] Changing the message does not require rewriting transition logic
- [ ] Missing message data uses a safe fallback
BODY

create_or_update_issue "Add Continue button" <<'BODY'
## Description

Add a Continue button to the Map 1 completion screen.

## Acceptance Criteria

- [ ] A clearly labeled Continue button appears
- [ ] The button has an appropriate interactive hit area
- [ ] The button provides hover or pressed feedback
- [ ] Selecting Continue begins the next game-flow transition
- [ ] The button becomes disabled after selection
- [ ] Rapid clicks cannot trigger multiple transitions
- [ ] The shared Button component is used where appropriate
- [ ] Map 1 completion state is saved before leaving the screen
BODY

create_or_update_issue "Prepare loading of Map 2" <<'BODY'
## Description

Prepare the Map 1 completion flow so the Continue button can load Map 2 when Map 2 is implemented.

## Acceptance Criteria

- [ ] Map 1 is recorded as completed
- [ ] Map 2 can be added to the unlocked-map collection
- [ ] RunState supports changing the current map to Map 2
- [ ] RunState supports setting the player to Map 2's starting node
- [ ] The destination map identifier is defined in one place
- [ ] The Continue button does not contain hard-coded Map 2 scene logic
- [ ] A temporary fallback destination can be used until Map 2 exists
- [ ] Missing Map 2 data does not crash the game
- [ ] The transition can later be enabled without rewriting the completion screen
BODY

echo
echo "Finished creating or updating Map 1 Completion issues."
echo
echo "Open the epic with:"
echo "gh issue view $PARENT_ISSUE --repo $REPO --web"
