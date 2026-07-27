#!/usr/bin/env bash

set -euo pipefail

REPO="drewblue42/Audibility-Quest"
PARENT_ISSUE="23"
PARENT_TITLE="Editable Study Content"
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

# Find the repository milestone whose title begins with "Milestone 3".
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

# Match both the title and parent epic.
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

create_or_update_issue "Move instructions into editable files" <<'BODY'
## Description

Move all player-facing title and instruction text into dedicated editable data files.

Researchers should be able to change instruction wording and page content without modifying Phaser scene logic.

## Acceptance Criteria

- [ ] Instruction text is stored outside Phaser scene files
- [ ] Instruction data supports multiple pages
- [ ] Each page can define a heading
- [ ] Each page can define body text
- [ ] The instruction scene loads pages from the editable data
- [ ] Adding a page does not require rewriting navigation logic
- [ ] Removing a page does not require rewriting navigation logic
- [ ] Missing instruction data uses a safe fallback
- [ ] The editable file has clear comments or documentation
BODY

create_or_update_issue "Move word tables into editable files" <<'BODY'
## Description

Move all tutorial and normal-fight word tables into dedicated editable files.

Researchers should be able to change study words without editing the word-grid or combat systems.

## Acceptance Criteria

- [ ] Word tables are stored outside scene and UI component files
- [ ] Each word table has a unique identifier
- [ ] Each table supports multiple columns
- [ ] Each column supports multiple word choices
- [ ] Tutorial fights can select a tutorial word table
- [ ] Normal fights can select their configured word table
- [ ] The shared word-grid system renders the supplied table
- [ ] Words can be changed without editing grid logic
- [ ] Additional tables can be added without creating new scene classes
- [ ] The editable file format is documented
BODY

create_or_update_issue "Validate word tables" <<'BODY'
## Description

Validate editable word-table data before the game attempts to display or score it.

Validation should provide useful errors for developers while preventing malformed study content from crashing the game.

## Acceptance Criteria

- [ ] The word-table collection must exist
- [ ] Every word table has a unique identifier
- [ ] Every table contains at least one column
- [ ] Every column contains at least one valid word
- [ ] Empty strings are rejected or handled intentionally
- [ ] Invalid non-string word values are detected
- [ ] Duplicate table identifiers are detected
- [ ] Validation identifies which table or column is invalid
- [ ] Invalid data does not cause an unclear Phaser runtime error
- [ ] Validation can run during development or game initialization
- [ ] Valid word tables continue loading normally
BODY

create_or_update_issue "Move maps into editable files" <<'BODY'
## Description

Move map layouts, node definitions, paths, encounter types, checkpoints, and themes into dedicated editable data files.

Researchers and developers should be able to change map content without rewriting the shared map scene.

## Acceptance Criteria

- [ ] Every map is stored outside the Phaser map scene
- [ ] Every map has a unique identifier
- [ ] Every map defines a starting node
- [ ] Every map defines a final node where applicable
- [ ] Every node has a unique identifier
- [ ] Node positions are stored in map data
- [ ] Node connections are stored in map data
- [ ] Node encounter types are stored in map data
- [ ] Fight nodes can reference monsters and word tables
- [ ] Campsite and checkpoint nodes can be identified
- [ ] Visual-theme configuration can be stored or referenced
- [ ] The shared map scene loads the selected map from data
- [ ] Adding a map does not require creating another map-scene class
BODY

create_or_update_issue "Move monsters into editable files" <<'BODY'
## Description

Move monster names, health values, visual settings, sizes, and defeat-animation configuration into dedicated editable files.

Normal and tutorial fights should create monster state from this data rather than hard-coded scene values.

## Acceptance Criteria

- [ ] Monster definitions are stored outside fight-scene files
- [ ] Every monster has a unique identifier
- [ ] Every monster has a display name
- [ ] Every monster defines maximum health
- [ ] Monsters can define an image or texture key
- [ ] Monsters can define display width and height
- [ ] Monsters can define a defeat-animation type
- [ ] Tutorial and normal fights load monsters from the shared data
- [ ] Fight nodes can reference monster identifiers
- [ ] Missing optional values use documented defaults
- [ ] Adding a monster does not require rewriting combat logic
- [ ] The editable monster format is documented
BODY

create_or_update_issue "Document how to edit game content" <<'BODY'
## Description

Create documentation explaining how researchers and developers can edit instructions, word tables, maps, monsters, and related study content.

The documentation should assume the editor may not be familiar with Phaser or the internal scene code.

## Acceptance Criteria

- [ ] Documentation identifies the location of each editable data file
- [ ] Documentation explains how to edit instruction pages
- [ ] Documentation explains how to edit word tables
- [ ] Documentation explains how to add or modify maps
- [ ] Documentation explains how to add or modify monsters
- [ ] Documentation explains how fight nodes reference monsters
- [ ] Documentation explains how fights reference word tables
- [ ] At least one valid example is provided for every data type
- [ ] Required and optional fields are identified
- [ ] Default values are documented
- [ ] Common validation errors and fixes are described
- [ ] Documentation warns users not to edit shared scene logic unnecessarily
- [ ] The instructions are included in the repository README or linked documentation
BODY

echo
echo "Finished creating or updating Editable Study Content issues."
echo "Milestone: $MILESTONE_NAME"
echo
echo "Open the epic with:"
echo "gh issue view $PARENT_ISSUE --repo $REPO --web"
