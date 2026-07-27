#!/usr/bin/env bash

set -euo pipefail

REPO="drewblue42/Audibility-Quest"
PARENT_ISSUE="19"
PARENT_TITLE="Monster Variety"
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

# Find the exact repository milestone beginning with "Milestone 2".
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

# Match both title and parent so same-named issues under other epics
# are not moved.
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

create_or_update_issue "Add monsters for Map 1" <<'BODY'
## Description

Add the set of normal monsters required for encounters on Map 1.

The monsters should be defined in editable monster data rather than directly inside the fight scene.

## Acceptance Criteria

- [ ] Map 1 has at least one configured normal monster
- [ ] Each Map 1 monster has a unique identifier
- [ ] Each monster has a display name
- [ ] Each monster defines maximum health
- [ ] Each monster defines an image, sprite, or placeholder appearance
- [ ] Each monster defines its intended display size
- [ ] Map 1 fight nodes reference valid monster data
- [ ] Normal fights load the referenced monster correctly
- [ ] Monster values can be changed without editing fight-scene logic
BODY

create_or_update_issue "Add monsters for Map 2" <<'BODY'
## Description

Add a distinct set of monsters for encounters on Map 2.

Map 2 monsters should use the shared monster and combat systems while presenting different visual or gameplay configurations from Map 1.

## Acceptance Criteria

- [ ] Map 2 has at least one configured normal monster
- [ ] Each Map 2 monster has a unique identifier
- [ ] Each monster has a display name
- [ ] Each monster defines maximum health
- [ ] Each monster defines an image or placeholder appearance
- [ ] Each monster defines its intended display size
- [ ] Map 2 fight nodes reference valid monster data
- [ ] Map 2 monsters are distinguishable from Map 1 monsters
- [ ] Normal fights load the referenced monster correctly
BODY

create_or_update_issue "Add monsters for Map 3" <<'BODY'
## Description

Add a distinct set of monsters for encounters on Map 3.

The monsters should continue using shared data and combat behavior without requiring a Map 3-specific fight implementation.

## Acceptance Criteria

- [ ] Map 3 has at least one configured normal monster
- [ ] Each Map 3 monster has a unique identifier
- [ ] Each monster has a display name
- [ ] Each monster defines maximum health
- [ ] Each monster defines an image or placeholder appearance
- [ ] Each monster defines its intended display size
- [ ] Map 3 fight nodes reference valid monster data
- [ ] Map 3 monsters are distinguishable from earlier monsters
- [ ] Normal fights load the referenced monster correctly
BODY

create_or_update_issue "Add monsters for later maps" <<'BODY'
## Description

Add monsters for Maps 4 and 5 or any other later maps included in the final game.

The amount of content should follow the confirmed project and study requirements.

## Acceptance Criteria

- [ ] The required number of later maps is confirmed
- [ ] Every included later map has configured monster data
- [ ] Every later-map monster has a unique identifier
- [ ] Every monster has a display name and maximum health
- [ ] Every monster has an image or safe visual fallback
- [ ] Every monster defines its intended display size
- [ ] Later-map fight nodes reference valid monsters
- [ ] Later monsters are distinguishable from earlier-map monsters
- [ ] Omitted maps do not leave invalid monster references
- [ ] Adding a later monster does not require rewriting combat logic
BODY

create_or_update_issue "Connect monsters to fight nodes" <<'BODY'
## Description

Connect each fight node to the monster or monster pool that should appear during that encounter.

Monster selection should be controlled through editable map and monster data.

## Acceptance Criteria

- [ ] Fight-node data can contain a monster identifier
- [ ] Fight-node data can contain a monster-pool identifier if required
- [ ] Every configured monster reference points to valid monster data
- [ ] Selecting a fight node passes the encounter information to combat
- [ ] The fight scene loads the node's configured monster
- [ ] Random selection occurs only within the configured monster pool
- [ ] A monster remains consistent throughout one encounter
- [ ] Different nodes can use different monsters
- [ ] Missing monster references use a clear fallback or error
- [ ] Scene code does not hard-code map-to-monster relationships
BODY

create_or_update_issue "Support different monster images and sizes" <<'BODY'
## Description

Allow different monsters to use different image assets and display dimensions in the shared fight scene.

## Acceptance Criteria

- [ ] Monster data can define an image or texture key
- [ ] Monster data can define display width
- [ ] Monster data can define display height
- [ ] The fight scene loads the configured monster image
- [ ] The fight scene applies the configured display size
- [ ] Large monsters remain within the game window
- [ ] Small monsters remain clearly visible
- [ ] Monster placement remains aligned with combat animations
- [ ] Missing image data uses a safe placeholder
- [ ] Missing size data uses reasonable default dimensions
- [ ] Adding a differently sized monster does not require fight-scene changes
BODY

create_or_update_issue "Support simple defeat animations" <<'BODY'
## Description

Support simple configurable defeat animations for different monsters.

The shared fight system should handle the animation instead of requiring a separate defeat implementation for each monster.

## Acceptance Criteria

- [ ] Monster data can define a defeat-animation type
- [ ] Supported animation types are documented
- [ ] At least one fade animation is supported
- [ ] At least one movement or fall animation is supported where needed
- [ ] The animation begins when monster health reaches zero
- [ ] Combat input is disabled before the animation starts
- [ ] The animation plays only once
- [ ] The map-return transition waits for the animation to finish
- [ ] Missing animation configuration uses a safe default
- [ ] Defeat animation settings do not alter combat calculations
- [ ] Additional simple animation types can be added without rewriting fight flow
BODY

echo
echo "Finished creating or updating Monster Variety issues."
echo "Milestone: $MILESTONE_NAME"
echo
echo "Open the epic with:"
echo "gh issue view $PARENT_ISSUE --repo $REPO --web"
