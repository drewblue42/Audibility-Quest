#!/usr/bin/env bash

set -euo pipefail

REPO="drewblue42/Audibility-Quest"
PARENT_ISSUE="26"
PARENT_TITLE="Experimenter Documentation"
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

create_or_update_issue "Document how to start the game" <<'BODY'
## Description

Create experimenter-facing instructions for installing, launching, and opening the game before a study session.

The instructions should assume the experimenter may not be familiar with the project's development tools.

## Acceptance Criteria

- [ ] Required software is listed
- [ ] Required software versions are listed where important
- [ ] Repository download or clone instructions are included
- [ ] Dependency-installation instructions are included
- [ ] The command used to start the development server is documented
- [ ] The correct browser address is documented
- [ ] Instructions explain how to stop the development server
- [ ] Instructions explain how to restart the game
- [ ] Successful startup behavior is described
- [ ] Common startup errors are linked to troubleshooting guidance
- [ ] Instructions are available in the README or linked experimenter documentation
BODY

create_or_update_issue "Document scoring controls" <<'BODY'
## Description

Document how the experimenter submits combat scores from zero through five.

## Acceptance Criteria

- [ ] Numpad scores 0 through 5 are documented
- [ ] Regular number-row scores 0 through 5 are documented
- [ ] Documentation explains when scoring becomes enabled
- [ ] Documentation explains that one word must be selected from every column
- [ ] Documentation explains what each accepted score represents
- [ ] Documentation explains how scoring affects player and monster damage
- [ ] Accepted-score feedback is described
- [ ] Controls disabled during animations are explained
- [ ] Optional clickable scoring controls are documented if enabled
- [ ] Invalid and unsupported keys are identified
- [ ] A concise scoring reference is available during study operation
BODY

create_or_update_issue "Document fight-ending controls" <<'BODY'
## Description

Document how the experimenter manually ends tutorial and normal fights.

## Acceptance Criteria

- [ ] Enter is documented as a fight-ending control
- [ ] Space is documented as a fight-ending control
- [ ] Documentation explains when manual fight ending is available
- [ ] Tutorial fight-ending behavior is described
- [ ] Normal fight-ending behavior is described
- [ ] The expected return scene or next step is described
- [ ] Documentation warns against holding or repeatedly pressing the keys
- [ ] Running away is clearly distinguished from experimenter fight ending
- [ ] Death behavior is clearly distinguished from manual fight ending
- [ ] A concise control reference is available to the experimenter
BODY

create_or_update_issue "Document how to restart a map" <<'BODY'
## Description

Document the process and expected behavior for restarting the player's current map.

## Acceptance Criteria

- [ ] Normal death-and-continue restart behavior is explained
- [ ] Health restoration behavior is documented
- [ ] Stamina restoration behavior is documented
- [ ] Starting-node or checkpoint behavior is documented
- [ ] Current-map progress reset behavior is documented
- [ ] Previously completed maps are identified as preserved
- [ ] Previously unlocked maps are identified as preserved
- [ ] Tutorial-completion status is identified as preserved
- [ ] Any developer-only restart shortcut is documented
- [ ] The difference between restarting a map and starting a new game is explained
BODY

create_or_update_issue "Document how to start a new game" <<'BODY'
## Description

Document how to begin a new run and explain which game-state values are reset or preserved.

## Acceptance Criteria

- [ ] Starting from the title screen is documented
- [ ] First-time tutorial behavior is documented
- [ ] Skip Tutorial behavior is documented
- [ ] Play Again behavior is documented
- [ ] Health reset behavior is documented
- [ ] Stamina reset behavior is documented
- [ ] Current-map reset behavior is documented
- [ ] Completed-node and completed-map reset behavior is documented
- [ ] Unlocked-map reset behavior is documented
- [ ] Tutorial-completion preservation is documented
- [ ] The difference between a new run and clearing all saved data is explained
BODY

create_or_update_issue "Document how to clear tutorial completion" <<'BODY'
## Description

Document the developer or experimenter procedure for clearing saved tutorial-completion status.

This allows the first-time tutorial experience to be tested repeatedly.

## Acceptance Criteria

- [ ] The supported developer clear method is documented
- [ ] The exact browser-storage key is documented where appropriate
- [ ] Browser developer-tools steps are included if needed
- [ ] Any development-menu option is documented if available
- [ ] Instructions explain how to confirm the value was cleared
- [ ] Instructions explain whether a page refresh is required
- [ ] Skip Tutorial is expected to disappear after clearing
- [ ] The procedure does not remove unrelated saved browser data
- [ ] The distinction between clearing tutorial completion and resetting a run is explained
- [ ] The procedure is clearly marked as a testing or development operation
BODY

create_or_update_issue "Create troubleshooting instructions" <<'BODY'
## Description

Create experimenter-facing troubleshooting instructions for common setup, browser, input, content, and game-flow problems.

The guide should provide safe recovery steps that do not require understanding the full codebase.

## Required Topics

- Game does not start
- Development server reports an error
- Browser displays a blank screen
- Browser displays an old version of the game
- Keyboard scoring does not work
- Numpad keys do not work
- Word selections remain disabled
- Fight does not advance
- Scene appears stuck during a transition
- Images or monsters are missing
- Map data does not load
- Tutorial completion is incorrect
- Saved progress is invalid
- Console contains an error

## Acceptance Criteria

- [ ] Startup troubleshooting steps are included
- [ ] Dependency-installation problems are covered
- [ ] Browser refresh and cache steps are covered
- [ ] Keyboard focus problems are covered
- [ ] Num Lock behavior is covered where applicable
- [ ] Duplicate or ignored input behavior is explained
- [ ] Missing-content errors are covered
- [ ] Saved-progress recovery steps are included
- [ ] Tutorial-completion reset steps are linked
- [ ] Instructions explain how to open the browser console
- [ ] Instructions explain what error information to record
- [ ] Instructions explain how to report a defect in GitHub
- [ ] Troubleshooting avoids deleting unrelated browser data
- [ ] A final safe-reset procedure is included
- [ ] The guide is linked from the primary experimenter documentation
BODY

echo
echo "Finished creating or updating Experimenter Documentation issues."
echo "Milestone: $MILESTONE_NAME"
echo
echo "Open the epic with:"
echo "gh issue view $PARENT_ISSUE --repo $REPO --web"
