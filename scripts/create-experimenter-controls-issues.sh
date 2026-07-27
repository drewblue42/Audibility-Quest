#!/usr/bin/env bash

set -euo pipefail

REPO="drewblue42/Audibility-Quest"
PARENT_ISSUE="22"
PARENT_TITLE="Experimenter Controls"
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
# Combat System or another epic are not moved.
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

create_or_update_issue "Support numpad keys 0 through 5" <<'BODY'
## Description

Allow the experimenter to submit combat scores using numpad keys zero through five.

## Acceptance Criteria

- [ ] Numpad 0 is recognized
- [ ] Numpad 1 is recognized
- [ ] Numpad 2 is recognized
- [ ] Numpad 3 is recognized
- [ ] Numpad 4 is recognized
- [ ] Numpad 5 is recognized
- [ ] Scores outside zero through five are ignored
- [ ] Numpad input works consistently in tutorial and normal fights
- [ ] Num Lock behavior is tested and documented where relevant
- [ ] Invalid input does not cause console errors
BODY

create_or_update_issue "Support regular number keys 0 through 5" <<'BODY'
## Description

Allow the experimenter to submit combat scores using the regular keyboard number row as a fallback to the numpad.

## Acceptance Criteria

- [ ] Number-row keys 0 through 5 are recognized
- [ ] Number-row input produces the same scores as numpad input
- [ ] Scores outside zero through five are ignored
- [ ] Shifted symbols do not accidentally submit scores
- [ ] Input works consistently in tutorial and normal fights
- [ ] Supporting number-row keys does not cause duplicate score handling
- [ ] Invalid input does not cause console errors
BODY

create_or_update_issue "Support Enter and Space to end fights" <<'BODY'
## Description

Allow the experimenter to end the active tutorial or normal fight by pressing Enter or Space.

## Acceptance Criteria

- [ ] Enter ends the active fight
- [ ] Space ends the active fight
- [ ] The fight can be ended while the word grid is incomplete
- [ ] The fight can be ended between combat rounds
- [ ] Further scoring input is disabled immediately
- [ ] The word grid is disabled or removed
- [ ] The correct return or continuation behavior is triggered
- [ ] Repeated key input does not start multiple transitions
- [ ] Keyboard listeners are cleaned up when the fight scene shuts down
BODY

create_or_update_issue "Prevent keys from registering twice" <<'BODY'
## Description

Prevent a single key press, held key, or repeated browser keyboard event from submitting more than one combat score or scene transition.

## Acceptance Criteria

- [ ] A valid score is accepted only once per combat round
- [ ] Holding a number key does not apply repeated damage
- [ ] Repeated keydown events are ignored where appropriate
- [ ] Enter or Space triggers only one fight-ending transition
- [ ] Input is locked immediately after a score is accepted
- [ ] Multiple keyboard listeners are not attached after scene restarts
- [ ] Scene shutdown removes the fight's keyboard listeners
- [ ] The next round accepts input after its controls are intentionally unlocked
BODY

create_or_update_issue "Disable controls during animations" <<'BODY'
## Description

Disable experimenter keyboard and optional clickable controls while combat animations or scene transitions are active.

## Acceptance Criteria

- [ ] Score controls are disabled when an attack animation begins
- [ ] Enter and Space follow the documented animation behavior
- [ ] Clickable experimenter buttons are disabled during animations
- [ ] Input remains disabled during damage feedback
- [ ] Input remains disabled during monster-defeat animations
- [ ] Input remains disabled during scene transitions
- [ ] Additional damage cannot be applied during an animation
- [ ] Controls are restored only when the next combat round is ready
- [ ] Controls remain disabled after the fight ends
BODY

create_or_update_issue "Disable scoring until words are selected" <<'BODY'
## Description

Keep experimenter score controls disabled until the player has selected one word from every required word-grid column.

## Acceptance Criteria

- [ ] Scoring begins disabled at the start of every round
- [ ] Number keys are ignored while the grid is incomplete
- [ ] Clickable score buttons are disabled while the grid is incomplete
- [ ] The grid reports when every column has a selection
- [ ] Scoring becomes available after the final required selection
- [ ] Resetting the grid disables scoring again
- [ ] The interface communicates when scoring is available
- [ ] Enter and Space behavior remains separate from score availability
BODY

create_or_update_issue "Display which score was accepted" <<'BODY'
## Description

Display clear feedback showing which experimenter score was accepted for the current combat round.

## Acceptance Criteria

- [ ] The accepted score from zero through five is displayed
- [ ] The display updates only after valid score input
- [ ] Invalid or ignored input does not change the displayed score
- [ ] The score remains visible during damage and attack feedback
- [ ] The previous score is cleared before the next round
- [ ] The accepted score agrees with the applied damage
- [ ] Rapid input cannot display conflicting scores
- [ ] The feedback is readable without covering important combat information
BODY

create_or_update_issue "Add optional clickable experimenter buttons" <<'BODY'
## Description

Add optional on-screen score buttons for experimenters who cannot or do not want to use keyboard controls.

The buttons should use the same control and scoring methods as keyboard input.

## Acceptance Criteria

- [ ] Optional buttons for scores 0 through 5 can be displayed
- [ ] Each button clearly shows its score value
- [ ] Clicking a button uses the same scoring method as keyboard input
- [ ] The buttons do not duplicate combat-resolution logic
- [ ] Buttons are disabled until all words are selected
- [ ] Buttons are disabled during animations
- [ ] Buttons are disabled after the fight ends
- [ ] Rapid clicks cannot submit multiple scores
- [ ] The buttons can be enabled or hidden through configuration
- [ ] Keyboard controls continue working when buttons are enabled
- [ ] The controls have usable hit areas and visible interaction states
BODY

echo
echo "Finished creating or updating Experimenter Controls issues."
echo "Milestone: $MILESTONE_NAME"
echo
echo "Open the epic with:"
echo "gh issue view $PARENT_ISSUE --repo $REPO --web"
