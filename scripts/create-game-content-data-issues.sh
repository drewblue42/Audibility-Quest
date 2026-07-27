#!/usr/bin/env bash

set -euo pipefail

REPO="drewblue42/Audibility-Quest"
PARENT_ISSUE="6"
PARENT_TITLE="Game Content Data"
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

# Update the epic itself.
epic_body_file="$(mktemp)"

cat > "$epic_body_file" <<'BODY'
## Overview

This epic makes it possible to add instructions, maps, monsters, word lists, and combat scoring data without rewriting scene code.

Game content should be stored separately from Phaser scene behavior so that study content can be edited without changing the game's core logic.

## Included Work

- [ ] Create editable instructions data
- [ ] Create editable word-table data
- [ ] Create monster data
- [ ] Create map data
- [ ] Create combat score data

## Completion Criteria

- [ ] Scene files load content from dedicated data modules
- [ ] Content can be changed without rewriting scene logic
- [ ] Data structures use consistent and documented formats
- [ ] Invalid or missing data is handled appropriately
- [ ] Content modules can support additional instructions, words, monsters, and maps
BODY

gh issue edit "$PARENT_ISSUE" \
  --repo "$REPO" \
  --body-file "$epic_body_file" \
  --milestone "$MILESTONE_NAME" \
  --add-label "$LABEL_NAME" \
  --add-assignee "@me"

rm -f "$epic_body_file"

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

create_or_update_issue "Create editable instructions data" <<'BODY'
## Description

Move the game's title-screen and instruction content into a dedicated data module that can be edited without changing the scene code.

## Acceptance Criteria

- [ ] Instruction content is stored outside the Phaser scene
- [ ] The data supports multiple instruction sections or screens
- [ ] Instruction headings and body text can be edited
- [ ] The instruction scene reads content from the data module
- [ ] Adding or changing instructions does not require rewriting scene logic
- [ ] The data structure is documented
BODY

create_or_update_issue "Create editable word-table data" <<'BODY'
## Description

Store the study word table in a dedicated data module so researchers can change word choices without modifying the fight or word-grid scenes.

## Acceptance Criteria

- [ ] Word choices are stored outside the scene code
- [ ] Data supports multiple columns of word choices
- [ ] Each column can contain multiple selectable words
- [ ] The word grid is generated from the data
- [ ] Words can be added, removed, or changed without rewriting grid logic
- [ ] The data format is documented
- [ ] Invalid or empty columns are handled appropriately
BODY

create_or_update_issue "Create monster data" <<'BODY'
## Description

Create a dedicated monster data module containing the values needed to generate different monsters during combat.

## Acceptance Criteria

- [ ] Monsters have unique identifiers
- [ ] Monsters have display names
- [ ] Monsters define maximum health
- [ ] Monsters define their visual configuration, such as color or sprite key
- [ ] Fight scenes create monster state from the monster data
- [ ] Additional monsters can be added without rewriting combat logic
- [ ] Random monster selection uses the monster data module
BODY

create_or_update_issue "Create map data" <<'BODY'
## Description

Create a dedicated map data structure that defines maps, nodes, node connections, checkpoints, and node encounter types.

## Acceptance Criteria

- [ ] Each map has a unique identifier
- [ ] Each map defines a starting node
- [ ] Each node has a unique identifier
- [ ] Node positions are stored in the map data
- [ ] Connections between nodes are stored in the map data
- [ ] Nodes can define encounter or destination types
- [ ] Checkpoint nodes can be identified
- [ ] The map scene is generated from the map data
- [ ] Additional maps can be added without rewriting map-scene logic
BODY

create_or_update_issue "Create combat score data" <<'BODY'
## Description

Create editable combat score data that defines how researcher input translates into monster damage and player damage.

## Acceptance Criteria

- [ ] Supported researcher input values are defined in the data
- [ ] Each input value defines monster damage
- [ ] Each input value defines player damage
- [ ] Miss behavior can be configured
- [ ] Strong-hit behavior can be configured
- [ ] Combat resolution reads values from the score data
- [ ] Changing score values does not require rewriting combat logic
- [ ] Invalid score input is handled appropriately
BODY

echo
echo "Finished creating or updating Game Content Data issues."
echo
echo "Open the epic with:"
echo "gh issue view $PARENT_ISSUE --repo $REPO --web"
