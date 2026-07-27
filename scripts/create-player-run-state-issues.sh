#!/usr/bin/env bash

set -euo pipefail

REPO="drewblue42/Audibility-Quest"
PARENT_ISSUE="5"
MILESTONE_NAME="Milestone 1: Core Playable Loop"
LABEL_NAME="M1"

echo "Repository: $REPO"
echo "Parent epic: #$PARENT_ISSUE Player and Run State"
echo

parent_title=$(
  gh issue view "$PARENT_ISSUE" \
    --repo "$REPO" \
    --json title \
    --jq '.title'
)

if [[ "$parent_title" != "Player and Run State" ]]; then
  echo "Error: Issue #$PARENT_ISSUE is titled '$parent_title'."
  echo "Expected: Player and Run State"
  exit 1
fi

echo "Found parent epic: $parent_title"

milestone_exists=$(
  gh api \
    "repos/$REPO/milestones?state=all&per_page=100" \
    --jq ".[] | select(.title == \"$MILESTONE_NAME\") | .title" \
    2>/dev/null || true
)

common_args=(
  --repo "$REPO"
  --parent "$PARENT_ISSUE"
  --label "$LABEL_NAME"
  --assignee "@me"
)

if [[ -n "$milestone_exists" ]]; then
  common_args+=(--milestone "$MILESTONE_NAME")
  echo "Actual milestone found: $MILESTONE_NAME"
else
  echo "No actual milestone named '$MILESTONE_NAME' was found."
  echo "Issues will receive the '$LABEL_NAME' label instead."
fi

echo

issue_exists() {
  local title="$1"

  gh issue list \
    --repo "$REPO" \
    --state all \
    --limit 500 \
    --json title \
    --jq '.[].title' |
    grep -Fqx -- "$title"
}

create_issue() {
  local title="$1"
  local body_file
  local issue_url

  body_file="$(mktemp)"

  # Read the heredoc supplied to this function into a temporary file.
  cat > "$body_file"

  if issue_exists "$title"; then
    echo "Skipping existing issue: $title"
    rm -f "$body_file"
    return
  fi

  echo "Creating: $title"

  if ! issue_url=$(
    gh issue create \
      --title "$title" \
      --body-file "$body_file" \
      "${common_args[@]}"
  ); then
    echo "Failed to create: $title"
    rm -f "$body_file"
    return 1
  fi

  rm -f "$body_file"
  echo "$issue_url"
}

create_issue "Track current and maximum health" <<'BODY'
## Description

Track the player's current health and maximum health as part of the active run.

## Acceptance Criteria

- [ ] Run state stores current health
- [ ] Run state stores maximum health
- [ ] A new game starts at maximum health
- [ ] Health cannot fall below zero
- [ ] Health cannot exceed maximum health
- [ ] Health persists between combat rounds and map nodes
BODY

create_issue "Track current and maximum stamina" <<'BODY'
## Description

Track the player's current stamina and maximum stamina as part of the active run.

## Acceptance Criteria

- [ ] Run state stores current stamina
- [ ] Run state stores maximum stamina
- [ ] A new game starts at maximum stamina
- [ ] Stamina cannot fall below zero
- [ ] Stamina cannot exceed maximum stamina
- [ ] Stamina persists between encounters
BODY

create_issue "Track current map" <<'BODY'
## Description

Track which map the player is currently exploring.

## Acceptance Criteria

- [ ] Run state contains a current map identifier
- [ ] A new game starts on the configured starting map
- [ ] The current map can be updated
- [ ] Game scenes can read the current map
- [ ] Restarting a map preserves the correct map identifier
BODY

create_issue "Track current map position" <<'BODY'
## Description

Track the player's current node or position on the active map.

## Acceptance Criteria

- [ ] Run state contains a current map position
- [ ] A new game starts at the initial map node
- [ ] The position updates when the player moves
- [ ] Returning from combat restores the correct position
- [ ] The stored position references a valid node
BODY

create_issue "Track completed map nodes" <<'BODY'
## Description

Track which map nodes the player has completed during the current run.

## Acceptance Criteria

- [ ] Run state contains a collection of completed node IDs
- [ ] Completing a node adds its ID
- [ ] Completing a node twice does not create duplicates
- [ ] Scenes can check whether a node is completed
- [ ] Starting a new game clears completed nodes
BODY

create_issue "Track current map checkpoint" <<'BODY'
## Description

Track the most recent checkpoint reached by the player.

## Acceptance Criteria

- [ ] Run state contains a checkpoint identifier
- [ ] A new game uses the starting checkpoint
- [ ] Reaching a checkpoint updates the stored value
- [ ] Restarting the current map returns to the checkpoint
- [ ] Starting a new game restores the initial checkpoint
BODY

create_issue "Track tutorial completion" <<'BODY'
## Description

Track whether the player has completed the tutorial.

## Acceptance Criteria

- [ ] Run state contains a tutorial-completed value
- [ ] The value begins as false
- [ ] Completing the tutorial changes it to true
- [ ] Game flow can use the value to skip the tutorial
- [ ] New-game behavior resets it as intended
BODY

create_issue "Create new-game reset" <<'BODY'
## Description

Create a reset operation that restores the complete player and run state to its initial values.

## Acceptance Criteria

- [ ] Health is restored to maximum health
- [ ] Stamina is restored to maximum stamina
- [ ] Current map returns to the starting map
- [ ] Current position returns to the starting node
- [ ] Completed nodes are cleared
- [ ] Checkpoint returns to the initial checkpoint
- [ ] Tutorial state is reset as intended
- [ ] Temporary combat state is cleared
BODY

create_issue "Create current-map restart" <<'BODY'
## Description

Create an operation that restarts the active map without resetting the entire run.

## Acceptance Criteria

- [ ] The player remains on the current map
- [ ] The player returns to the appropriate checkpoint
- [ ] Progress after the checkpoint is reset
- [ ] Progress from earlier maps is preserved
- [ ] Tutorial completion is preserved
- [ ] The operation does not perform a complete new-game reset
BODY

create_issue "Create combat-round reset" <<'BODY'
## Description

Create an operation that clears temporary state before beginning another combat round.

## Acceptance Criteria

- [ ] Previous word selections are cleared
- [ ] Round-ready state becomes false
- [ ] Temporary damage information is cleared
- [ ] Damage input is disabled until selections are complete
- [ ] Player health is preserved
- [ ] Monster health is preserved
- [ ] Map and run progress are unchanged
BODY

echo
echo "Finished creating Player and Run State sub-issues."
echo "Open the epic with:"
echo "gh issue view $PARENT_ISSUE --repo $REPO --web"
