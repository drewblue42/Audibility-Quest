#!/usr/bin/env bash

set -euo pipefail

REPO="drewblue42/Audibility-Quest"
PARENT_ISSUE="28"
PARENT_TITLE="README, Build, and Deployment"
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

create_or_update_issue "Document the required Node version" <<'BODY'
## Description

Document the Node.js version required to install, run, build, and maintain Audibility Quest.

The documented version should match the version used successfully during development and production-build testing.

## Acceptance Criteria

- [ ] The supported Node.js version or version range is identified
- [ ] The version is displayed prominently in the README
- [ ] The required package-manager version is documented where important
- [ ] The documented version successfully installs dependencies
- [ ] The documented version successfully starts the development server
- [ ] The documented version successfully creates a production build
- [ ] An `.nvmrc`, `.node-version`, or `package.json` engine entry is added where appropriate
- [ ] Instructions explain how to check the installed Node version
- [ ] Unsupported-version symptoms are included in troubleshooting guidance
BODY

create_or_update_issue "Document installation" <<'BODY'
## Description

Document how a developer or experimenter can obtain the project and install its dependencies.

## Acceptance Criteria

- [ ] Repository clone instructions are included
- [ ] Downloading the repository as an archive is addressed where useful
- [ ] Instructions explain how to enter the project directory
- [ ] The dependency-installation command is documented
- [ ] Required Node and package-manager versions are referenced
- [ ] Successful installation behavior is described
- [ ] Common dependency-installation errors are addressed
- [ ] Instructions work from a clean copy of the repository
- [ ] Platform-specific differences are identified where necessary
- [ ] Installation does not require undocumented global packages
BODY

create_or_update_issue "Document how to run the game" <<'BODY'
## Description

Document how to launch Audibility Quest locally for development or study use.

## Acceptance Criteria

- [ ] The development-server command is documented
- [ ] The expected local browser address is documented
- [ ] Instructions explain whether the browser opens automatically
- [ ] Instructions explain how to stop the server
- [ ] Instructions explain how to restart the server
- [ ] Successful startup behavior is described
- [ ] Browser requirements are identified where relevant
- [ ] Keyboard focus and numpad considerations are mentioned
- [ ] Common startup problems link to troubleshooting instructions
- [ ] The instructions work from a clean installation
BODY

create_or_update_issue "Document how to build the game" <<'BODY'
## Description

Document how to create a production-ready build of Audibility Quest.

## Acceptance Criteria

- [ ] The production-build command is documented
- [ ] The output directory is identified
- [ ] Instructions explain how to remove or replace an old build
- [ ] Successful build output is described
- [ ] Instructions explain how to preview or serve the production build
- [ ] Static assets are included in the build
- [ ] Editable study-content files are included correctly
- [ ] Base-path or public-path requirements are documented
- [ ] Common build failures are covered in troubleshooting
- [ ] The documented steps are verified from a clean installation
BODY

create_or_update_issue "Add a game overview" <<'BODY'
## Description

Add a concise overview of Audibility Quest to the repository README.

The overview should explain the project purpose, player objective, study interaction, and primary gameplay loop.

## Acceptance Criteria

- [ ] The project name is clearly displayed
- [ ] Towson University project context is included
- [ ] The game's purpose is explained
- [ ] The player's dungeon objective is explained
- [ ] Listening and word-selection behavior is explained
- [ ] Experimenter scoring is explained at a high level
- [ ] Monster fights and running are explained
- [ ] Map progression and campsites are summarized
- [ ] The overview distinguishes player and experimenter roles
- [ ] The overview avoids requiring readers to inspect the source code
BODY

create_or_update_issue "Add controls" <<'BODY'
## Description

Add a README section documenting player and experimenter controls.

## Acceptance Criteria

- [ ] Mouse or pointer word-selection controls are documented
- [ ] Start, Next, Back, Continue, Run, and Play Again controls are documented
- [ ] Numpad scores 0 through 5 are documented
- [ ] Regular number-row scores 0 through 5 are documented
- [ ] Enter and Space fight-ending controls are documented
- [ ] Controls disabled during animations are explained
- [ ] Scoring availability after word selection is explained
- [ ] Running with zero stamina is explained
- [ ] Optional clickable experimenter controls are documented if enabled
- [ ] Controls are organized by player and experimenter role
BODY

create_or_update_issue "Add project structure" <<'BODY'
## Description

Add a README section describing the important project directories and modules.

The section should help new developers locate scenes, UI components, systems, editable data, assets, and build configuration.

## Acceptance Criteria

- [ ] The main source directory is documented
- [ ] Phaser scene files are identified
- [ ] Shared UI components are identified
- [ ] RunState and other systems are identified
- [ ] Editable instruction data is identified
- [ ] Editable word-table data is identified
- [ ] Editable map data is identified
- [ ] Editable monster data is identified
- [ ] Image and other asset locations are identified
- [ ] Test locations are identified where applicable
- [ ] Build and configuration files are identified
- [ ] Generated build output is distinguished from source files
- [ ] The documented structure matches the repository
BODY

create_or_update_issue "Add content-editing instructions" <<'BODY'
## Description

Add or link instructions explaining how researchers and developers can edit study content without rewriting Phaser scene logic.

## Acceptance Criteria

- [ ] Instruction-page editing is documented
- [ ] Word-table editing is documented
- [ ] Word-table validation requirements are documented
- [ ] Map editing is documented
- [ ] Monster editing is documented
- [ ] Fight-node monster references are explained
- [ ] Fight-node word-table references are explained
- [ ] Required and optional fields are identified
- [ ] At least one example is included for each content type
- [ ] Common formatting errors are described
- [ ] The documentation links to more detailed content documentation where appropriate
- [ ] Readers are warned against changing shared scene logic for ordinary content edits
BODY

create_or_update_issue "Add screenshots" <<'BODY'
## Description

Add representative screenshots to the README or linked project documentation.

Screenshots should help readers understand the game's appearance and core flow before running it.

## Suggested Screenshots

- Title screen
- Instructions screen
- Tutorial fight
- Normal fight and word grid
- Map screen
- Campsite
- Death screen
- Victory screen

## Acceptance Criteria

- [ ] At least one current gameplay screenshot is included
- [ ] The title or instructions flow is represented
- [ ] The word-grid combat interface is represented
- [ ] A map screen is represented
- [ ] Screenshots match the current game version
- [ ] Images are stored in an organized repository location
- [ ] README image paths work on GitHub
- [ ] Images are reasonably sized and compressed
- [ ] Screenshots do not expose private or sensitive information
- [ ] Each screenshot has a useful caption or alt text
- [ ] Outdated screenshots are replaced before release
BODY

create_or_update_issue "Test the production build" <<'BODY'
## Description

Create and test the production build before deployment or packaging.

Testing should confirm that behavior which works in the development server also works from the generated production files.

## Test Areas

- Title and instructions
- Tutorial and Skip Tutorial
- Word-grid interaction
- Experimenter scoring
- Normal fights
- Campsites
- Death and restart
- Map progression
- Victory and Play Again
- Browser storage
- Images and editable content

## Acceptance Criteria

- [ ] Dependency installation succeeds from a clean checkout
- [ ] The production-build command succeeds
- [ ] The generated output contains the expected files
- [ ] The build can be served locally
- [ ] All scenes load in the production build
- [ ] Images and other static assets load
- [ ] Editable study content loads
- [ ] Keyboard and pointer controls work
- [ ] Browser storage works
- [ ] Refreshing the deployed route does not break the game
- [ ] No development-only file paths are required
- [ ] No uncaught console errors occur during a full playthrough
- [ ] Production-build defects are recorded as separate issues
BODY

create_or_update_issue "Deploy or package the game" <<'BODY'
## Description

Choose and complete the final delivery method for Audibility Quest.

The project may be deployed as a static website or packaged for controlled local study use, depending on project requirements.

## Decision Questions

- Will the game be hosted online?
- Will study computers run it locally?
- Is offline operation required?
- Who is responsible for updating the deployed version?
- Does browser storage need to remain on one specific machine?
- Are there institutional hosting or privacy requirements?

## Acceptance Criteria

- [ ] The delivery method is confirmed with project stakeholders
- [ ] The selected hosting or packaging target is documented
- [ ] The production build is used rather than the development server
- [ ] All required static assets are included
- [ ] Editable study content is included
- [ ] The deployed or packaged game starts successfully
- [ ] Keyboard and pointer controls work in the final environment
- [ ] Browser-storage behavior is tested in the final environment
- [ ] Refreshing or reopening the game behaves correctly
- [ ] Deployment or package-update instructions are documented
- [ ] The final access location or launch process is documented
- [ ] A full start-to-finish playthrough succeeds in the final environment
- [ ] Known environment limitations are documented
- [ ] A backup or rollback process is identified where appropriate
BODY

echo
echo "Finished creating or updating README, Build, and Deployment issues."
echo "Milestone: $MILESTONE_NAME"
echo
echo "Open the epic with:"
echo "gh issue view $PARENT_ISSUE --repo $REPO --web"
