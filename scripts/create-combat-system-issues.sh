#!/usr/bin/env bash

set -euo pipefail

REPO="drewblue42/Audibility-Quest"
PARENT_ISSUE="10"
PARENT_TITLE="Combat System"
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

# Find an issue only when both its title and parent epic match.
# This prevents same-named issues under other epics from being moved.
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

create_or_update_issue "Enable scoring after all words are selected" <<'BODY'
## Description

Enable combat scoring only after the player has selected one word from every word-grid column.

## Acceptance Criteria

- [ ] Combat begins each round with scoring disabled
- [ ] The word grid reports when every column has a selection
- [ ] Scoring becomes enabled after the final required selection
- [ ] Score input is ignored while the grid is incomplete
- [ ] The interface tells the researcher when scoring is available
- [ ] Resetting the round disables scoring again
- [ ] Scoring cannot be enabled more than once for the same round
BODY

create_or_update_issue "Support scores 0 through 5" <<'BODY'
## Description

Accept researcher score inputs from zero through five during a combat round.

## Acceptance Criteria

- [ ] Scores 0, 1, 2, 3, 4, and 5 are supported
- [ ] Numpad keys zero through five are recognized
- [ ] Standard number-row keys zero through five are recognized where appropriate
- [ ] Scores outside zero through five are ignored
- [ ] Input is accepted only when scoring is enabled
- [ ] The selected score is passed to combat resolution
- [ ] Invalid keyboard input does not cause console errors
BODY

create_or_update_issue "Apply player and monster damage" <<'BODY'
## Description

Apply the appropriate player and monster damage after a valid combat score is entered.

## Acceptance Criteria

- [ ] The score determines how much damage the monster receives
- [ ] The score determines how much damage the player receives
- [ ] Damage values come from the combat score data
- [ ] Player health cannot fall below zero
- [ ] Monster health cannot fall below zero
- [ ] Health state updates only once per combat round
- [ ] The system checks for player or monster defeat after damage
BODY

create_or_update_issue "Display damage numbers" <<'BODY'
## Description

Display the damage received by both the player and monster after scoring a combat round.

## Acceptance Criteria

- [ ] Monster damage is clearly displayed
- [ ] Player damage is clearly displayed
- [ ] Zero damage is displayed correctly
- [ ] Damage text appears after a valid score
- [ ] Damage text remains visible during the attack animation
- [ ] Previous damage text is cleared before the next round
- [ ] Repeated scoring does not create overlapping damage messages
BODY

create_or_update_issue "Display player health" <<'BODY'
## Description

Display the player's current and maximum health in the combat interface.

## Acceptance Criteria

- [ ] Current health is displayed
- [ ] Maximum health is displayed
- [ ] Health is loaded from RunState
- [ ] The display updates immediately after damage
- [ ] Zero health is displayed correctly
- [ ] The display persists between combat rounds
- [ ] The combat scene does not maintain a separate conflicting health value
BODY

create_or_update_issue "Display player stamina" <<'BODY'
## Description

Display the player's current and maximum stamina in the combat interface.

## Acceptance Criteria

- [ ] Current stamina is displayed
- [ ] Maximum stamina is displayed
- [ ] Stamina is loaded from RunState
- [ ] The display updates after the player runs
- [ ] Zero stamina is displayed correctly
- [ ] Stamina persists between fights
- [ ] The combat scene does not maintain a separate conflicting stamina value
BODY

create_or_update_issue "Reset the word grid after scoring" <<'BODY'
## Description

Reset the combat word grid after scoring and completing the current round's animations.

This combat-system issue covers when the reset should happen. The Word Grid epic covers the grid component's internal reset behavior.

## Acceptance Criteria

- [ ] The grid remains disabled while scoring is resolved
- [ ] Attack and damage animations finish before reset
- [ ] Previous selections are cleared
- [ ] All word buttons return to their initial state
- [ ] Scoring becomes disabled after reset
- [ ] The next round begins with an empty grid
- [ ] Player and monster health are preserved during the reset
- [ ] No reset occurs after the fight has ended
BODY

create_or_update_issue "Prevent repeated key input" <<'BODY'
## Description

Prevent rapid or repeated keyboard input from scoring the same combat round more than once.

## Acceptance Criteria

- [ ] Scoring is disabled immediately after accepting a valid score
- [ ] Holding down a number key does not apply repeated damage
- [ ] Additional score inputs are ignored during animations
- [ ] Player damage is applied only once per round
- [ ] Monster damage is applied only once per round
- [ ] Keyboard input becomes available again only after the next grid is complete
- [ ] Input remains disabled when the fight has ended
BODY

create_or_update_issue "End a fight with Enter or Space" <<'BODY'
## Description

Allow the experimenter to end the current fight by pressing Enter or Space.

## Acceptance Criteria

- [ ] Enter triggers the fight-ending behavior
- [ ] Space triggers the fight-ending behavior
- [ ] The fight can be ended even when the word grid is incomplete
- [ ] Ending the fight disables further scoring input
- [ ] The word grid is disabled or destroyed
- [ ] The fight transitions to the configured return scene
- [ ] Repeated Enter or Space input does not trigger multiple transitions
BODY

create_or_update_issue "Add Run button" <<'BODY'
## Description

Add a Run button that allows the player to leave the current fight.

## Acceptance Criteria

- [ ] A clearly labeled Run button appears in the combat scene
- [ ] The button uses the shared Button component where appropriate
- [ ] The button has visible hover or pressed feedback
- [ ] Clicking Run calls a dedicated run-away method
- [ ] Running disables combat input
- [ ] Running prevents additional word selections
- [ ] Running transitions to the configured return scene
- [ ] Repeated clicks do not trigger multiple transitions
BODY

create_or_update_issue "Reduce stamina when running" <<'BODY'
## Description

Reduce the player's stamina when they successfully run away from a fight.

## Acceptance Criteria

- [ ] Running reduces current stamina by one
- [ ] Stamina is changed through RunState
- [ ] Stamina cannot fall below zero
- [ ] The stamina display updates immediately
- [ ] Running changes stamina only once per fight
- [ ] The reduced stamina persists after leaving combat
- [ ] Ending a fight normally does not reduce stamina
BODY

create_or_update_issue "Handle running with zero stamina" <<'BODY'
## Description

Define and implement the behavior that occurs when the player attempts to run with no remaining stamina.

## Acceptance Criteria

- [ ] The game checks stamina before allowing the player to run
- [ ] Running is blocked when current stamina is zero
- [ ] Stamina remains at zero
- [ ] The player stays in the current fight
- [ ] A clear status message explains that the player cannot run
- [ ] Combat controls remain usable after the blocked attempt
- [ ] Repeated attempts do not cause errors or scene transitions
- [ ] The Run button can show a disabled state when stamina is zero
BODY

echo
echo "Finished creating or updating Combat System issues."
echo
echo "Open the epic with:"
echo "gh issue view $PARENT_ISSUE --repo $REPO --web"
