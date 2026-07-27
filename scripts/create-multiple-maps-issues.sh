#!/usr/bin/env bash

set -euo pipefail

REPO="drewblue42/Audibility-Quest"
PARENT_ISSUE="17"
PARENT_TITLE="Multiple Maps"
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

# Find the repository milestone whose title begins with "Milestone 2".
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
  echo "Error: More than one milestone begins with '$MILESTONE_PREFIX':"
  printf '%s\n' "$MILESTONE_NAME"
  echo
  echo "Set MILESTONE_NAME manually near the top of this script."
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
# This prevents matching titles under other epics from being moved.
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

create_or_update_issue "Create Map 2" <<'BODY'
## Description

Create the second playable dungeon map using the shared map system and editable map data.

Map 2 should build on the mechanics established by Map 1 while presenting a different layout and visual identity.

## Acceptance Criteria

- [ ] Map 2 has a unique map identifier
- [ ] Map 2 defines a starting node
- [ ] Map 2 defines a final node
- [ ] Map 2 includes fight nodes
- [ ] Map 2 includes campsite nodes where required
- [ ] Every node has a unique identifier and screen position
- [ ] Connections between nodes are defined in map data
- [ ] Map 2 loads through the shared map scene
- [ ] Player position persists between Map 2 encounters
- [ ] Completing Map 2 updates run progress
- [ ] Map 2 can unlock the next configured map
BODY

create_or_update_issue "Create Map 3" <<'BODY'
## Description

Create the third playable dungeon map using the shared map system and editable map data.

Map 3 should present a distinct progression path without requiring a separate hard-coded map scene.

## Acceptance Criteria

- [ ] Map 3 has a unique map identifier
- [ ] Map 3 defines a starting node
- [ ] Map 3 defines a final node
- [ ] Map 3 includes fight nodes
- [ ] Map 3 includes campsite nodes where required
- [ ] Every node has a unique identifier and screen position
- [ ] Connections between nodes are defined in map data
- [ ] Map 3 loads through the shared map scene
- [ ] Player position persists between Map 3 encounters
- [ ] Completing Map 3 updates run progress
- [ ] Map 3 supports the intended next-map or victory transition
BODY

create_or_update_issue "Create Maps 4 and 5 if needed" <<'BODY'
## Description

Determine whether the study and gameplay requirements need fourth and fifth maps, then create them when required.

This work should remain optional until the required game length, encounter count, and research flow are confirmed.

## Acceptance Criteria

- [ ] The required total number of maps is confirmed with the project requirements
- [ ] The decision to include or omit Maps 4 and 5 is documented
- [ ] Map 4 is created from editable map data when required
- [ ] Map 5 is created from editable map data when required
- [ ] Each additional map has a starting node and final node
- [ ] Each additional map uses the shared map scene
- [ ] Each additional map has a distinct layout
- [ ] Each additional map has a distinct visual theme
- [ ] Map progression supports the additional maps
- [ ] Omitting Maps 4 and 5 does not leave broken transitions
BODY

create_or_update_issue "Give each map a different branching layout" <<'BODY'
## Description

Give each playable map a distinct arrangement of nodes and branches while continuing to use the shared map system.

## Acceptance Criteria

- [ ] Each map defines its own node connections in map data
- [ ] Map layouts are not copies of one another
- [ ] Each map contains at least one meaningful branch where required
- [ ] Every branch leads to a valid destination
- [ ] Invalid or unreachable nodes are avoided
- [ ] Each map has a valid path from its starting node to its final node
- [ ] Available next nodes are calculated from the active map data
- [ ] Branching does not require map-specific movement code
- [ ] Completed-node and checkpoint behavior works on every branch
- [ ] Layouts remain readable within the game dimensions
BODY

create_or_update_issue "Give each map a different visual theme" <<'BODY'
## Description

Give each map a recognizable visual theme while preserving the shared map behavior.

Themes may change backgrounds, node appearances, paths, labels, or other presentation settings.

## Acceptance Criteria

- [ ] Each map defines a visual-theme identifier or configuration
- [ ] Each map can use a different background
- [ ] Node styling can vary by map theme
- [ ] Path styling can vary by map theme
- [ ] Current, available, and completed nodes remain distinguishable
- [ ] Visual themes do not change movement rules
- [ ] Theme configuration is stored outside the shared map-scene logic
- [ ] Missing theme data uses a safe default
- [ ] Text and controls remain readable on every theme
- [ ] Adding a theme does not require duplicating the map scene
BODY

create_or_update_issue "Load maps from map data" <<'BODY'
## Description

Load every playable map from editable data through one shared map implementation.

Map-specific nodes, connections, starting positions, encounter types, checkpoints, and themes should not be hard-coded in the scene.

## Acceptance Criteria

- [ ] Every map has a data object with a unique identifier
- [ ] Map data defines the starting node
- [ ] Map data defines the final node
- [ ] Map data defines node positions
- [ ] Map data defines node connections
- [ ] Map data defines node encounter types
- [ ] Map data can identify checkpoints
- [ ] Map data contains or references visual-theme configuration
- [ ] The shared map scene selects data using RunState's current map
- [ ] Adding another map does not require creating another map-scene class
- [ ] Invalid map IDs use a safe fallback or clear error
- [ ] Invalid node connections do not crash the game
BODY

create_or_update_issue "Make the first node on each map a fight" <<'BODY'
## Description

Configure the beginning of each playable map so the player's first movement leads to a fight encounter.

The starting node itself may act as the entry position, with its first reachable destination configured as a fight node.

## Acceptance Criteria

- [ ] Every map defines a valid starting node
- [ ] The first reachable destination is a fight node
- [ ] The first fight node is connected to the starting node
- [ ] The first fight node is highlighted as an available destination
- [ ] Selecting it updates the player's map position
- [ ] Selecting it opens the normal fight scene
- [ ] The fight receives the correct map and node identifiers
- [ ] Returning from combat restores the correct position
- [ ] Winning marks the first fight node completed
- [ ] The rule is configured through map data rather than map-specific scene code
- [ ] Invalid movement cannot bypass the first encounter
BODY

echo
echo "Finished creating or updating Multiple Maps issues."
echo
echo "Milestone: $MILESTONE_NAME"
echo
echo "Open the epic with:"
echo "gh issue view $PARENT_ISSUE --repo $REPO --web"
