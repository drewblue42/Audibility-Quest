#!/usr/bin/env bash

set -euo pipefail

REPO="drewblue42/Audibility-Quest"
PARENT_ISSUE="18"
PARENT_TITLE="Map Progression"
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

# Locate the exact Milestone 2 title.
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
  exit 1
fi

echo "Found parent epic: $actual_parent_title"
echo "Found milestone: $MILESTONE_NAME"
echo

# Keep the epic itself assigned correctly.
gh issue edit "$PARENT_ISSUE" \
  --repo "$REPO" \
  --milestone "$MILESTONE_NAME" \
  --add-label "$LABEL_NAME" \
  --add-assignee "@me"

# Match both title and parent to avoid moving same-named issues
# that belong to other epics.
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

create_or_update_issue "Track current map" <<'BODY'
## Description

Use the shared run-state system to track which map the player is currently exploring.

This issue focuses on map progression behavior. The Player and Run State epic covers the underlying state field.

## Acceptance Criteria

- [ ] RunState contains a current-map identifier
- [ ] New-game setup assigns the starting map
- [ ] Completing a map updates the current-map identifier
- [ ] Map scenes load data using the current-map identifier
- [ ] Entering fights or campsites does not lose the current map
- [ ] Death and restart preserve the intended current map
- [ ] Invalid map identifiers use a safe fallback or clear error
- [ ] Scene code does not maintain a conflicting current-map value
BODY

create_or_update_issue "Load the next map after Map Complete" <<'BODY'
## Description

Load the next unlocked map after the player continues from a map-complete screen.

## Acceptance Criteria

- [ ] Each map defines its next-map identifier in editable data
- [ ] Completing a map records that map as completed
- [ ] The next map becomes unlocked
- [ ] Continue changes RunState to the next map
- [ ] The shared map scene loads the next map's data
- [ ] The transition occurs only once
- [ ] Temporary map-complete controls are disabled during transition
- [ ] Missing next-map data is handled safely
- [ ] The final map does not attempt to load a nonexistent map
BODY

create_or_update_issue "Start at the new map’s first node" <<'BODY'
## Description

Place the player on the configured starting node whenever a newly unlocked map begins.

## Acceptance Criteria

- [ ] Every map defines a starting-node identifier
- [ ] Loading a new map reads its starting node from map data
- [ ] RunState current position changes to the new starting node
- [ ] The player marker appears on the correct node
- [ ] Position from the previous map is not reused
- [ ] Available movement is calculated from the new starting node
- [ ] The starting node leads to the intended first encounter
- [ ] Missing starting-node data is handled safely
BODY

create_or_update_issue "Make each new map a checkpoint" <<'BODY'
## Description

Treat the beginning of each newly reached map as a progression checkpoint.

After reaching a new map, death should restart that map rather than sending the player back to an earlier map.

## Acceptance Criteria

- [ ] Entering a new map records it as the current checkpoint map
- [ ] The checkpoint position is set to the map's starting node
- [ ] Death restarts the current checkpoint map
- [ ] Earlier completed maps remain completed
- [ ] Previously unlocked maps remain unlocked
- [ ] Restarting does not return the player to Map 1 incorrectly
- [ ] Entering fights and campsites preserves checkpoint state
- [ ] Checkpoint updates occur only after a map is successfully unlocked
BODY

create_or_update_issue "Decide whether health carries between maps" <<'BODY'
## Description

Decide and document whether the player's remaining health carries into the next map or is restored during map progression.

## Decision Questions

- Should health remain unchanged when entering a new map?
- Should health be restored completely?
- Should health be restored by a fixed amount?
- Should the rule differ after a campsite or boss encounter?

## Acceptance Criteria

- [ ] The intended health behavior is confirmed with project stakeholders
- [ ] The decision is documented in the issue
- [ ] The chosen rule is applied consistently between every map
- [ ] Health never exceeds maximum health
- [ ] The health display reflects the resulting value
- [ ] Map-complete and map-loading scenes use the same rule
- [ ] The rule is configured in one place
- [ ] Automated or manual tests cover the chosen behavior
BODY

create_or_update_issue "Decide whether stamina carries between maps" <<'BODY'
## Description

Decide and document whether the player's remaining stamina carries into the next map or is restored during map progression.

## Decision Questions

- Should stamina remain unchanged when entering a new map?
- Should stamina be restored completely?
- Should stamina be restored by a fixed amount?
- Should reaching a new map act like reaching a campsite?

## Acceptance Criteria

- [ ] The intended stamina behavior is confirmed with project stakeholders
- [ ] The decision is documented in the issue
- [ ] The chosen rule is applied consistently between every map
- [ ] Stamina never exceeds maximum stamina
- [ ] The stamina display reflects the resulting value
- [ ] Map-complete and map-loading scenes use the same rule
- [ ] The rule is configured in one place
- [ ] Automated or manual tests cover the chosen behavior
BODY

create_or_update_issue "Detect the final map" <<'BODY'
## Description

Detect when the player completes the final configured map and begin the overall game-completion flow.

## Acceptance Criteria

- [ ] The map data identifies the final map or indicates that no next map exists
- [ ] Completing a non-final map continues normal map progression
- [ ] Completing the final map does not attempt to load another map
- [ ] The final map is recorded as completed
- [ ] Overall game completion is triggered only once
- [ ] Map movement and completion input are disabled during transition
- [ ] The victory or final-results screen opens
- [ ] Missing or inconsistent final-map data is handled safely
- [ ] Adding or removing maps does not require rewriting final-map logic
BODY

echo
echo "Finished creating or updating Map Progression issues."
echo "Milestone: $MILESTONE_NAME"
echo
echo "Open the epic with:"
echo "gh issue view $PARENT_ISSUE --repo $REPO --web"
