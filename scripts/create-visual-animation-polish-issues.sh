#!/usr/bin/env bash

set -euo pipefail

REPO="drewblue42/Audibility-Quest"
PARENT_ISSUE="27"
PARENT_TITLE="Visual and Animation Polish"
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

create_or_update_issue "Improve title and instructions layout" <<'BODY'
## Description

Improve the title and instructions screens so the text, controls, and page navigation are visually clear and consistent.

## Acceptance Criteria

- [ ] The game title is clearly visible
- [ ] Instruction headings have a consistent style
- [ ] Instruction body text is easy to read
- [ ] Long instruction text wraps correctly
- [ ] Start, Next, Back, and Skip Tutorial buttons are aligned consistently
- [ ] Buttons do not overlap instruction text
- [ ] Page indicators are displayed where useful
- [ ] The layout fits within the configured game dimensions
- [ ] Text remains readable against the background
- [ ] The layout works for instruction pages of different lengths
- [ ] Keyboard and pointer controls remain accessible
BODY

create_or_update_issue "Improve word-button states" <<'BODY'
## Description

Improve the visual states of word-grid buttons so normal, hovered, selected, disabled, and animation-locked states are easy to distinguish.

## Acceptance Criteria

- [ ] Normal word buttons are clearly interactive
- [ ] Hovered buttons provide visible feedback
- [ ] Selected words have a distinct visual state
- [ ] Unselected words in a completed column appear disabled
- [ ] Disabled buttons do not look clickable
- [ ] Animation-locked buttons are visually distinguishable where appropriate
- [ ] Button text remains readable in every state
- [ ] State changes happen immediately after selection
- [ ] Resetting the grid restores the normal button style
- [ ] Button styling is consistent across tutorial and normal fights
- [ ] Styling does not change word-grid selection behavior
BODY

create_or_update_issue "Improve player attack animations" <<'BODY'
## Description

Improve successful player attack animations so attacks feel clear, responsive, and consistent with the amount of damage dealt.

## Acceptance Criteria

- [ ] The player visibly moves toward the monster
- [ ] The player returns to the original position
- [ ] Character position does not drift between rounds
- [ ] The animation timing matches the damage feedback
- [ ] Normal hits are visually distinct from misses
- [ ] Strong hits are visually distinct from normal hits
- [ ] Combat controls remain disabled during the animation
- [ ] Multiple attack animations cannot overlap
- [ ] The animation works with different monster sizes
- [ ] Scene transitions wait for the animation when appropriate
- [ ] Missing player artwork uses a safe placeholder animation
BODY

create_or_update_issue "Improve miss animation" <<'BODY'
## Description

Improve the zero-damage miss animation so it clearly communicates that the player's attack failed.

## Acceptance Criteria

- [ ] A score of zero triggers the miss animation
- [ ] The player visibly misses, trips, or attacks short of the monster
- [ ] The monster does not react as if it received damage
- [ ] The status message clearly identifies the miss
- [ ] Player damage feedback still appears
- [ ] The player returns to the correct position and angle
- [ ] The animation plays only once per round
- [ ] Controls remain disabled during the animation
- [ ] The miss animation does not interfere with the next grid reset
- [ ] Camera movement or shake remains subtle and readable
BODY

create_or_update_issue "Improve damage feedback" <<'BODY'
## Description

Improve visual feedback for player damage, monster damage, accepted scores, and remaining health.

## Acceptance Criteria

- [ ] The accepted score is clearly displayed
- [ ] Player damage is clearly displayed
- [ ] Monster damage is clearly displayed
- [ ] Zero damage is represented correctly
- [ ] Player and monster health displays update immediately
- [ ] Damage feedback remains visible long enough to read
- [ ] Old damage feedback is cleared before the next round
- [ ] Damage numbers do not overlap critical controls
- [ ] Player and monster reactions match the applied damage
- [ ] Strong hits receive more noticeable feedback
- [ ] Repeated input cannot create overlapping damage messages
- [ ] Feedback remains readable against every fight background
BODY

create_or_update_issue "Improve Run animation" <<'BODY'
## Description

Improve the animation and feedback shown when the player successfully runs away from a fight.

## Acceptance Criteria

- [ ] The player visibly moves away from the monster
- [ ] The animation direction clearly suggests leaving the fight
- [ ] Stamina is reduced only once
- [ ] Updated stamina is displayed before or during the exit
- [ ] A message confirms that the player ran away
- [ ] Combat and word-grid controls are disabled immediately
- [ ] Repeated Run clicks do not create overlapping animations
- [ ] The return-to-map transition waits for the animation
- [ ] The player does not briefly return to the original position
- [ ] Running with zero stamina does not play the successful Run animation
- [ ] A blocked Run attempt receives separate feedback
BODY

create_or_update_issue "Improve monster defeat animation" <<'BODY'
## Description

Improve the monster defeat animation so victory in an encounter is visually clear before returning to the map.

## Acceptance Criteria

- [ ] The animation begins when monster health reaches zero
- [ ] The monster visibly fades, falls, shrinks, or disappears
- [ ] The animation type can use monster configuration where available
- [ ] The animation works with different monster images and sizes
- [ ] The monster cannot receive more damage after defeat
- [ ] Combat controls are disabled before the animation starts
- [ ] The word grid is disabled or removed
- [ ] The defeated node is recorded correctly
- [ ] The animation plays only once
- [ ] The map transition waits for the animation to finish
- [ ] Missing animation configuration uses a safe default
BODY

create_or_update_issue "Improve campsite feedback" <<'BODY'
## Description

Improve campsite visuals and restoration feedback so the player can clearly understand their choice and resulting health or stamina change.

## Acceptance Criteria

- [ ] Current health and stamina are clearly displayed
- [ ] Restore Health and Restore Stamina options are visually distinct
- [ ] Available options appear interactive
- [ ] Unavailable options appear disabled
- [ ] The selected option receives a completed state
- [ ] The unselected option becomes visibly unavailable
- [ ] Restoration feedback identifies what was restored
- [ ] The amount restored is shown where appropriate
- [ ] Updated values are immediately visible
- [ ] Rapid input cannot activate both choices
- [ ] The Continue or return control becomes clear after restoration
- [ ] Campsite visuals remain consistent with the rest of the game
BODY

create_or_update_issue "Improve map transitions" <<'BODY'
## Description

Improve transitions between maps, fights, campsites, completion screens, death, and victory so scene changes feel intentional and do not appear abrupt or duplicated.

## Acceptance Criteria

- [ ] Entering a fight has a clear transition
- [ ] Returning from a fight has a clear transition
- [ ] Entering and leaving a campsite has a clear transition
- [ ] Map-complete transitions are visually distinct
- [ ] Death transitions clearly interrupt normal map return
- [ ] Victory transitions clearly follow final-map completion
- [ ] Fade or camera effects do not block required information
- [ ] Controls are disabled while transitions are active
- [ ] Each transition runs only once
- [ ] Delayed callbacks cannot trigger an old transition
- [ ] Player map position remains correct after transitions
- [ ] No blank or inactive screen remains between scenes
- [ ] Transition timing remains short enough for study operation
BODY

echo
echo "Finished creating or updating Visual and Animation Polish issues."
echo "Milestone: $MILESTONE_NAME"
echo
echo "Open the epic with:"
echo "gh issue view $PARENT_ISSUE --repo $REPO --web"
