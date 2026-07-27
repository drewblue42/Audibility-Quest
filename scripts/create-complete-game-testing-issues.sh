#!/usr/bin/env bash

set -euo pipefail

REPO="drewblue42/Audibility-Quest"
PARENT_ISSUE="25"
PARENT_TITLE="Complete Game Testing"
MILESTONE_PREFIX="Milestone 3"
LABEL_NAME="M3"

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

# Find the exact repository milestone beginning with "Milestone 3".
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

# Match both title and parent so similarly named issues under
# other epics are not moved.
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

create_or_update_issue "Test word selection" <<'BODY'
## Description

Test the shared word-grid selection behavior in tutorial and normal fights.

## Test Cases

- Select one word from each column
- Attempt to select a second word from the same column
- Select columns in different orders
- Reset the grid between rounds
- Attempt to click disabled words
- Test tables with different numbers of rows and columns

## Acceptance Criteria

- [ ] Every visible word can be clicked when enabled
- [ ] Only one word can be selected per column
- [ ] Other words in the selected column become disabled
- [ ] Words in unselected columns remain available
- [ ] The grid detects when every column has a selection
- [ ] Selected words are returned in the correct column order
- [ ] Resetting clears all selections
- [ ] Resetting restores all enabled button states
- [ ] Tutorial and normal fights use the same working behavior
- [ ] No console errors occur during selection or reset
BODY

create_or_update_issue "Test every score from 0 through 5" <<'BODY'
## Description

Test every supported experimenter score and confirm that each produces the intended player and monster damage.

## Test Cases

- Submit score 0
- Submit score 1
- Submit score 2
- Submit score 3
- Submit score 4
- Submit score 5
- Test numpad input
- Test regular number-row input

## Acceptance Criteria

- [ ] Score 0 produces the configured damage values
- [ ] Score 1 produces the configured damage values
- [ ] Score 2 produces the configured damage values
- [ ] Score 3 produces the configured damage values
- [ ] Score 4 produces the configured damage values
- [ ] Score 5 produces the configured damage values
- [ ] Accepted score feedback displays the correct value
- [ ] Damage numbers agree with the accepted score
- [ ] Numpad and regular number keys behave identically
- [ ] Unsupported scores and keys are ignored
- [ ] Health values never fall below zero
BODY

create_or_update_issue "Test repeated keyboard input" <<'BODY'
## Description

Test rapid, repeated, and held keyboard input to ensure combat actions and scene transitions occur only once.

## Test Cases

- Hold a score key
- Rapidly press the same score key
- Rapidly press different score keys
- Hold Enter
- Hold Space
- Alternate Enter and Space
- Submit input during attack animations
- Submit input during scene transitions

## Acceptance Criteria

- [ ] One combat round accepts only one score
- [ ] Holding a score key does not apply repeated damage
- [ ] Rapid score keys do not apply multiple rounds of damage
- [ ] Enter starts only one fight-ending transition
- [ ] Space starts only one fight-ending transition
- [ ] Enter and Space together do not start duplicate transitions
- [ ] Input during animations is ignored
- [ ] Input during transitions is ignored
- [ ] Keyboard listeners are not duplicated after scene restarts
- [ ] No console errors occur during repeated input
BODY

create_or_update_issue "Test health and death" <<'BODY'
## Description

Test player health, damage, zero-health detection, and the death-screen transition.

## Test Cases

- Take normal damage
- Take damage greater than remaining health
- Reach exactly zero health
- Attempt additional damage after death
- Continue from the death screen
- Die repeatedly during separate runs

## Acceptance Criteria

- [ ] Player health decreases by the correct amount
- [ ] Health persists between combat rounds
- [ ] Health cannot fall below zero
- [ ] Reaching zero opens the death screen
- [ ] Death is triggered only once
- [ ] Combat controls are disabled after death
- [ ] Normal map-return transitions are cancelled after death
- [ ] Continue restores full health
- [ ] Continue returns to the correct map
- [ ] The player can continue playing after restarting
BODY

create_or_update_issue "Test stamina and running" <<'BODY'
## Description

Test stamina display, stamina reduction, running behavior, and attempts to run with zero stamina.

## Test Cases

- Run with full stamina
- Run with one stamina remaining
- Attempt to run with zero stamina
- Click Run repeatedly
- Return to combat after running
- Restore stamina at a campsite

## Acceptance Criteria

- [ ] Running reduces stamina by the configured amount
- [ ] Stamina cannot fall below zero
- [ ] The stamina display updates immediately
- [ ] Reduced stamina persists after leaving combat
- [ ] Running triggers only one scene transition
- [ ] Running with zero stamina is blocked
- [ ] A clear message appears when running is blocked
- [ ] Combat remains usable after a blocked run attempt
- [ ] Campsite restoration updates stamina correctly
- [ ] Death restart restores stamina according to the requirements
BODY

create_or_update_issue "Test campsites" <<'BODY'
## Description

Test campsite entry, restoration options, feedback, checkpoints, and return-to-map behavior.

## Test Cases

- Enter a campsite with missing health
- Enter a campsite with missing stamina
- Enter with full health
- Enter with full stamina
- Choose Restore Health
- Choose Restore Stamina
- Rapidly click both choices
- Return to the map
- Die after reaching a campsite

## Acceptance Criteria

- [ ] The campsite displays current and maximum health
- [ ] The campsite displays current and maximum stamina
- [ ] Restore Health applies the intended amount
- [ ] Restore Stamina applies the intended amount
- [ ] Values cannot exceed their maximums
- [ ] The player cannot select both options
- [ ] Restoration is applied only once
- [ ] Clear feedback identifies the selected restoration
- [ ] The player returns to the correct campsite node
- [ ] The campsite updates the intended checkpoint
- [ ] Restart behavior uses the correct checkpoint rules
BODY

create_or_update_issue "Test map movement" <<'BODY'
## Description

Test valid and invalid movement on every map layout.

## Test Cases

- Move from each node to every connected node
- Attempt to move to an unconnected node
- Rapidly click multiple available nodes
- Return from fights and campsites
- Reload the map scene
- Move through every branch

## Acceptance Criteria

- [ ] Available next nodes are highlighted correctly
- [ ] Only connected nodes accept movement
- [ ] Invalid movement does not change RunState
- [ ] Invalid movement does not open an encounter
- [ ] Rapid clicks trigger only one movement
- [ ] Player position updates to the selected node
- [ ] Returning from an encounter restores the correct position
- [ ] Completed nodes remain marked
- [ ] Paths match the configured node connections
- [ ] Every required branch can reach the final node
- [ ] No required nodes are unreachable
BODY

create_or_update_issue "Test death on every map" <<'BODY'
## Description

Test the death-and-restart flow from every playable map.

## Test Cases

- Die on Map 1
- Die on Map 2
- Die on Map 3
- Die on each later included map
- Die at different nodes and branches
- Die before and after reaching a campsite
- Die repeatedly after restarting

## Acceptance Criteria

- [ ] Death opens the death screen on every map
- [ ] Continue preserves the correct current map
- [ ] Health is restored
- [ ] Stamina is restored according to the requirements
- [ ] The current map resets according to the checkpoint rules
- [ ] The player returns to the correct starting or checkpoint node
- [ ] Earlier completed maps remain preserved
- [ ] Previously unlocked maps remain unlocked
- [ ] No restart incorrectly returns the player to Map 1
- [ ] The player can continue progressing after every restart
BODY

create_or_update_issue "Test progression through every map" <<'BODY'
## Description

Test progression from Map 1 through every included map and verify that each transition updates RunState correctly.

## Test Cases

- Complete Map 1
- Continue to Map 2
- Complete Map 2
- Continue to Map 3
- Complete each later included map
- Test progression after death and restart
- Test map checkpoints and unlocked-map state

## Acceptance Criteria

- [ ] Completing a map records it as completed
- [ ] The next map becomes unlocked
- [ ] Continue loads the correct next map
- [ ] The new map starts at its configured first node
- [ ] Current-map state updates correctly
- [ ] Current-position state updates correctly
- [ ] Earlier map completion remains preserved
- [ ] Death does not erase unlocked maps
- [ ] The final map is detected correctly
- [ ] The final map does not attempt to load a nonexistent next map
- [ ] No transition requires a page refresh
BODY

create_or_update_issue "Test victory and Play Again" <<'BODY'
## Description

Test final-map completion, the victory screen, and the Play Again reset flow.

## Test Cases

- Complete the final map
- Open the victory screen
- Click Play Again once
- Rapidly click Play Again
- Begin another run
- Complete multiple Play Again cycles

## Acceptance Criteria

- [ ] Final-map completion opens the victory screen
- [ ] The victory message displays correctly
- [ ] The victory screen opens only once
- [ ] Play Again triggers only one reset
- [ ] Health resets to maximum
- [ ] Stamina resets to maximum
- [ ] Current map returns to the starting map
- [ ] Current position returns to the starting node
- [ ] Completed nodes and maps reset as intended
- [ ] Tutorial-completion status remains saved
- [ ] The title screen opens after reset
- [ ] A complete new run can begin successfully
BODY

create_or_update_issue "Test Skip Tutorial" <<'BODY'
## Description

Test tutorial-completion storage and the Skip Tutorial option across first-time play, page refresh, death, and Play Again.

## Test Cases

- Start with no saved tutorial completion
- Complete the tutorial
- Refresh the page
- Choose Play Again
- Die and restart
- Use the developer option to clear completion
- Select Skip Tutorial

## Acceptance Criteria

- [ ] Skip Tutorial is unavailable before tutorial completion
- [ ] Completing the tutorial saves the completion value
- [ ] Skip Tutorial becomes available afterward
- [ ] Refreshing the page preserves availability
- [ ] Death and restart preserve availability
- [ ] Play Again preserves availability
- [ ] Clearing the saved value removes availability
- [ ] Skip Tutorial loads the correct starting map
- [ ] Skip Tutorial sets the correct starting node
- [ ] Old map progress is not restored when starting a new run
- [ ] Repeated clicks do not trigger duplicate transitions
BODY

create_or_update_issue "Complete a full start-to-finish playthrough" <<'BODY'
## Description

Complete a full player journey from the title screen through the tutorial, every map, final victory, and Play Again.

This is the final integrated test of the game's primary flow.

## Playthrough Path

1. Open the title screen
2. Read the instruction pages
3. Complete the tutorial
4. Enter Map 1
5. Complete fights and campsites
6. Complete Map 1
7. Progress through every later map
8. Complete the final map
9. Reach the victory screen
10. Select Play Again
11. Confirm a new run can begin
12. Confirm Skip Tutorial is available

## Acceptance Criteria

- [ ] The game starts without console errors
- [ ] Instructions can be navigated
- [ ] The tutorial can be completed
- [ ] Every required map can be completed
- [ ] Every required fight can be resolved
- [ ] Campsites work during normal progression
- [ ] Health and stamina remain consistent
- [ ] Death and restart work during the playthrough
- [ ] Map progression remains consistent
- [ ] The final map opens the victory screen
- [ ] Play Again resets run progress
- [ ] Tutorial completion remains saved
- [ ] Skip Tutorial is available for the next run
- [ ] No scene becomes stuck
- [ ] No required control becomes permanently disabled
- [ ] No uncaught console errors occur
- [ ] All discovered defects are recorded as separate GitHub issues
BODY

echo
echo "Finished creating or updating Complete Game Testing issues."
echo "Milestone: $MILESTONE_NAME"
echo
echo "Open the epic with:"
echo "gh issue view $PARENT_ISSUE --repo $REPO --web"
