#!/usr/bin/env bash

set -euo pipefail

REPO="drewblue42/Audibility-Quest"
PARENT_ISSUE="9"
PARENT_TITLE="Word Grid"
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

# Ensure the epic itself has the correct milestone and label.
gh issue edit "$PARENT_ISSUE" \
  --repo "$REPO" \
  --milestone "$MILESTONE_NAME" \
  --add-label "$LABEL_NAME"

find_issue_number() {
  local title="$1"

  gh issue list \
    --repo "$REPO" \
    --state all \
    --limit 500 \
    --json number,title \
    --jq ".[] | select(.title == \"$title\") | .number" |
    head -n 1
}

create_or_update_issue() {
  local title="$1"
  local body_file
  local existing_number
  local issue_url

  body_file="$(mktemp)"
  cat > "$body_file"

  existing_number="$(find_issue_number "$title")"

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

create_or_update_issue "Display word columns" <<'BODY'
## Description

Display the experiment word table as multiple organized columns in the fight interface.

## Acceptance Criteria

- [ ] The grid loads its words from the editable word-table data
- [ ] Every data column is displayed as a visual column
- [ ] Words remain within their assigned columns
- [ ] Column and row spacing is consistent
- [ ] The grid fits within the configured game dimensions
- [ ] Changing the word data updates the displayed grid
- [ ] Empty or invalid word data does not crash the scene
BODY

create_or_update_issue "Make every word clickable" <<'BODY'
## Description

Display every word as an interactive button that can receive player input.

## Acceptance Criteria

- [ ] Every displayed word has an interactive hit area
- [ ] Clicking a word triggers its selection behavior
- [ ] Buttons provide visible hover or pressed feedback
- [ ] The clickable area matches the visible button
- [ ] Disabled words cannot trigger selection callbacks
- [ ] Interaction works consistently across all columns
BODY

create_or_update_issue "Allow one selection per column" <<'BODY'
## Description

Allow the player to select exactly one word from each word-grid column during a combat round.

## Acceptance Criteria

- [ ] The grid tracks the selected word for each column
- [ ] Selecting a word records its column and value
- [ ] Each column can contain only one active selection
- [ ] A selection in one column does not affect another column
- [ ] Repeated clicking does not create duplicate selections
- [ ] The selected word has a distinct visual state
BODY

create_or_update_issue "Gray out other words in the selected column" <<'BODY'
## Description

After a word is selected, visually disable every other word in that same column.

## Acceptance Criteria

- [ ] The selected word remains visibly selected
- [ ] Unselected words in that column become gray
- [ ] Grayed-out words are no longer clickable
- [ ] Words in other columns remain available
- [ ] Disabled styling is visually distinct from selected styling
- [ ] Resetting the grid restores the normal appearance
BODY

create_or_update_issue "Detect when every column has a selection" <<'BODY'
## Description

Detect when the player has selected one word from every available column.

## Acceptance Criteria

- [ ] The grid can report whether all columns are complete
- [ ] Completion remains false while any column is unselected
- [ ] Completion becomes true after the final required selection
- [ ] The completion callback runs only at the appropriate time
- [ ] Empty columns are handled intentionally
- [ ] Combat input remains disabled until the grid is complete
BODY

create_or_update_issue "Return selected words to combat" <<'BODY'
## Description

Provide the selected words to the combat scene after every column has a selection.

## Acceptance Criteria

- [ ] The grid can return the selected word from every column
- [ ] Selected words are returned in a predictable column order
- [ ] The combat scene receives the completed selection
- [ ] The grid does not directly perform combat damage calculations
- [ ] The returned result has a documented structure
- [ ] Incomplete selections are not submitted
- [ ] Combat can use the result for scoring or research output
BODY

create_or_update_issue "Reset the grid after scoring" <<'BODY'
## Description

Restore the word grid to its initial state after a combat round has been scored.

## Acceptance Criteria

- [ ] Stored word selections are cleared
- [ ] All words return to their normal visual state
- [ ] All word buttons become clickable again
- [ ] Grid completion returns to false
- [ ] Old callbacks or game objects are cleaned up
- [ ] The next combat round can use the grid normally
- [ ] Resetting does not alter player or monster health
BODY

create_or_update_issue "Disable the grid during animations" <<'BODY'
## Description

Prevent additional word selections while attack, damage, or round-transition animations are playing.

## Acceptance Criteria

- [ ] The combat scene can disable the entire grid
- [ ] Disabled grid buttons ignore pointer input
- [ ] The grid has a visible disabled state where appropriate
- [ ] Existing selections cannot change during an animation
- [ ] Rapid clicks cannot submit multiple combat rounds
- [ ] The grid is re-enabled or reset after animations finish
- [ ] Disabling the grid does not erase its selections prematurely
BODY

echo
echo "Finished creating or updating Word Grid issues."
echo
echo "Open the epic with:"
echo "gh issue view $PARENT_ISSUE --repo $REPO --web"
