#!/usr/bin/env bash

set -euo pipefail

REPO="drewblue42/Audibility-Quest"
PARENT_ISSUE="12"
PARENT_TITLE="Map 1"
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

create_or_update_issue "Create Map 1 layout" <<'BODY'
## Description

Create the visual and logical layout for the first playable dungeon map.

The map should be generated from the editable Map 1 data rather than hard-coded directly into the Phaser scene.

## Acceptance Criteria

- [ ] Map 1 has a unique map identifier
- [ ] Map 1 defines a starting node
- [ ] Every node has a unique identifier
- [ ] Every node has a configured screen position
- [ ] The map scene loads Map 1 from editable map data
- [ ] Nodes fit within the configured game dimensions
- [ ] Map 1 loads without console errors
- [ ] The layout can be changed without rewriting scene logic
BODY

create_or_update_issue "Add fight nodes" <<'BODY'
## Description

Add fight nodes to Map 1 that begin a normal combat encounter when selected.

## Acceptance Criteria

- [ ] Fight nodes are identified in the map data
- [ ] Fight nodes have a distinct visual appearance
- [ ] Selecting an available fight node starts the normal fight scene
- [ ] The selected node ID is passed into combat
- [ ] The map scene is passed as the combat return destination
- [ ] Completed fight nodes are recorded in RunState
- [ ] Returning from combat restores the correct map position
- [ ] Completed fight nodes cannot be completed repeatedly unless intended
BODY

create_or_update_issue "Add campsite nodes" <<'BODY'
## Description

Add campsite nodes to Map 1 that allow the player to recover and establish progress checkpoints.

## Acceptance Criteria

- [ ] Campsite nodes are identified in the map data
- [ ] Campsite nodes have a distinct visual appearance
- [ ] Selecting an available campsite opens the campsite behavior
- [ ] The player's position updates to the campsite node
- [ ] Reaching a campsite updates the current checkpoint
- [ ] Campsite completion is recorded appropriately
- [ ] Returning to the map preserves the campsite position
- [ ] Campsite nodes are distinguishable from fight nodes
BODY

create_or_update_issue "Add end node" <<'BODY'
## Description

Add an end node that represents successful completion of Map 1.

## Acceptance Criteria

- [ ] Map 1 contains one configured end node
- [ ] The end node has a distinct visual appearance
- [ ] The end node is initially unavailable unless its requirements are met
- [ ] Selecting the available end node triggers Map 1 completion
- [ ] Map 1 completion is recorded in RunState
- [ ] The player cannot move past the end node through ordinary movement
- [ ] The completion behavior runs only once
- [ ] The end node is generated from editable map data
BODY

create_or_update_issue "Draw paths between nodes" <<'BODY'
## Description

Draw visible paths between connected Map 1 nodes.

## Acceptance Criteria

- [ ] Node connections are loaded from the map data
- [ ] A path is drawn for every valid connection
- [ ] Paths connect the correct node positions
- [ ] Duplicate paths are not drawn unnecessarily
- [ ] Paths appear behind the node controls
- [ ] Unconnected nodes do not display a path
- [ ] Updating map connections updates the displayed paths
- [ ] Invalid connection references are handled safely
BODY

create_or_update_issue "Display player position" <<'BODY'
## Description

Display the player's current location on Map 1.

## Acceptance Criteria

- [ ] A player marker appears on the current node
- [ ] The current node is loaded from RunState
- [ ] A new run begins on Map 1's starting node
- [ ] The marker moves when the player selects a valid next node
- [ ] The marker remains aligned with the node position
- [ ] Returning from an encounter restores the marker correctly
- [ ] The map scene does not maintain a conflicting position value
- [ ] Missing position data falls back safely to the starting node
BODY

create_or_update_issue "Highlight available next nodes" <<'BODY'
## Description

Clearly identify which connected nodes the player may move to next.

## Acceptance Criteria

- [ ] Available nodes are calculated from the current node's connections
- [ ] Available nodes have a distinct visual state
- [ ] Unavailable nodes do not use the available-node styling
- [ ] Completed-node styling remains distinguishable
- [ ] Available-node highlights update after movement
- [ ] The current node is not presented as a next-node option
- [ ] Only valid connected nodes become interactive
- [ ] Availability is recalculated after returning from encounters
BODY

create_or_update_issue "Prevent invalid movement" <<'BODY'
## Description

Prevent the player from moving to nodes that are not valid destinations from the current position.

## Acceptance Criteria

- [ ] Only connected next nodes accept movement input
- [ ] Unavailable nodes ignore pointer input
- [ ] The player cannot jump across unrelated nodes
- [ ] The player cannot move to an unknown node ID
- [ ] Invalid movement does not change RunState
- [ ] Invalid movement does not start an encounter
- [ ] Rapid clicks cannot trigger multiple movements
- [ ] Movement is disabled during scene transitions
BODY

create_or_update_issue "Make the first movement lead to a fight" <<'BODY'
## Description

Configure Map 1 so the player's first movement from the starting node leads to a normal fight.

## Acceptance Criteria

- [ ] The starting node connects to at least one fight node
- [ ] The intended first destination is clearly available
- [ ] Selecting the first destination updates the player's position
- [ ] Selecting the first destination begins a normal fight
- [ ] The fight receives the correct Map 1 node ID
- [ ] The fight returns the player to Map 1
- [ ] The first fight uses the shared combat system
- [ ] Completing the fight marks the destination node as completed
BODY

create_or_update_issue "Preserve map position after encounters" <<'BODY'
## Description

Keep the player's Map 1 position when entering and returning from fights, campsites, or other encounters.

## Acceptance Criteria

- [ ] Position is written to RunState before leaving the map
- [ ] Fight scenes receive Map 1 as their return scene
- [ ] Returning from a fight restores the correct node
- [ ] Returning from a campsite restores the correct node
- [ ] Reloading the map scene does not reset to the starting node
- [ ] Failed or escaped encounters follow the intended position behavior
- [ ] Position changes only through valid map movement or restart logic
- [ ] Map position persists independently of temporary scene objects
BODY

create_or_update_issue "Mark completed nodes" <<'BODY'
## Description

Visually mark nodes that the player has completed during the current run.

## Acceptance Criteria

- [ ] Completed node IDs are loaded from RunState
- [ ] Completed nodes have a distinct visual appearance
- [ ] A node is marked after its completion requirements are met
- [ ] Completing the same node does not create duplicate state entries
- [ ] Completed styling is restored when the map scene reloads
- [ ] Current, available, and completed states remain distinguishable
- [ ] New-game reset clears Map 1 completion markers
- [ ] Current-map restart follows the intended checkpoint rules
BODY

echo
echo "Finished creating or updating Map 1 issues."
echo
echo "Open the epic with:"
echo "gh issue view $PARENT_ISSUE --repo $REPO --web"
