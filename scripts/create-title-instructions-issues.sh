#!/usr/bin/env bash

set -euo pipefail

REPO="drewblue42/Audibility-Quest"
PARENT_ISSUE="8"
PARENT_TITLE="Title and Instructions"
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

# Keep the epic itself assigned to the correct milestone and label.
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

create_or_update_issue "Create title screen" <<'BODY'
## Description

Create the opening title screen shown when the game first launches.

## Acceptance Criteria

- [ ] A dedicated Phaser scene displays the game title
- [ ] The title is clearly visible and centered appropriately
- [ ] The screen uses the game's intended dimensions
- [ ] The title screen loads without console errors
- [ ] The title screen provides space for navigation controls
- [ ] The scene can transition to the instructions flow
BODY

create_or_update_issue "Add Start button" <<'BODY'
## Description

Add a Start button to the title screen that begins the game's introductory flow.

## Acceptance Criteria

- [ ] A clearly labeled Start button appears on the title screen
- [ ] The button has an appropriate interactive hit area
- [ ] The button provides hover or pressed feedback
- [ ] Selecting Start opens the instructions screen
- [ ] Repeated clicks do not start multiple scene transitions
- [ ] Keyboard activation is supported where appropriate
BODY

create_or_update_issue "Create instructions screen" <<'BODY'
## Description

Create a dedicated instructions screen that explains the game's basic objective and controls.

## Acceptance Criteria

- [ ] Instructions are displayed in a dedicated Phaser scene
- [ ] Text is readable within the game window
- [ ] Long text wraps instead of leaving the screen
- [ ] The screen supports a heading and instruction body
- [ ] Navigation controls have dedicated space
- [ ] The scene loads without console errors
BODY

create_or_update_issue "Add multiple instruction pages" <<'BODY'
## Description

Allow the instruction flow to display multiple pages instead of placing all instructions on one screen.

## Acceptance Criteria

- [ ] The instruction scene tracks the current page
- [ ] Only one instruction page is shown at a time
- [ ] The total number of pages comes from the instruction data
- [ ] Page content updates when the current page changes
- [ ] The first page is selected when the scene starts
- [ ] Page navigation cannot move outside the valid range
- [ ] The layout supports instruction pages of different lengths
BODY

create_or_update_issue "Add Next and Back buttons" <<'BODY'
## Description

Add navigation buttons that allow the player to move forward and backward through the instruction pages.

## Acceptance Criteria

- [ ] A Next button moves to the following instruction page
- [ ] A Back button moves to the previous instruction page
- [ ] Back is hidden or disabled on the first page
- [ ] Next changes appropriately on the final page
- [ ] Buttons do not move beyond the available page range
- [ ] Button state updates whenever the current page changes
- [ ] Navigation does not create duplicate scene transitions
BODY

create_or_update_issue "Load instructions from editable data" <<'BODY'
## Description

Load instruction headings and text from the editable instructions data instead of hard-coding the content inside the Phaser scene.

## Acceptance Criteria

- [ ] The instruction scene imports the instruction data module
- [ ] Page headings are loaded from the data
- [ ] Page body text is loaded from the data
- [ ] The number of pages is determined by the data
- [ ] Changing instruction text does not require editing scene logic
- [ ] Adding a page does not require rewriting navigation logic
- [ ] Missing or empty instruction data is handled without crashing
BODY

create_or_update_issue "Prepare Skip Tutorial button" <<'BODY'
## Description

Add a Skip Tutorial control to the instruction flow so it can later connect to tutorial-completion and game-flow logic.

## Acceptance Criteria

- [ ] A Skip Tutorial button is available in the instruction flow
- [ ] The button uses the shared game button component where appropriate
- [ ] Skip behavior is handled through a dedicated callback or method
- [ ] The destination scene is defined in one place
- [ ] The control can be hidden or disabled through configuration
- [ ] Selecting Skip does not trigger multiple scene transitions
- [ ] The button is ready to connect to tutorial-completion state
BODY

echo
echo "Finished creating or updating Title and Instructions issues."
echo
echo "Open the epic with:"
echo "gh issue view $PARENT_ISSUE --repo $REPO --web"
