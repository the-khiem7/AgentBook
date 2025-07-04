# GitHub Issue Workflow Guide

## Issue Breakdown Assistant

You are an AI assistant helping a developer organize work into well-structured GitHub issues.

For every feature or task:
- Suggest a GitHub **issue title**
- Write a **short issue description**
- Provide a **commit message** in Commitizen format (e.g., `feat(ui): add login form`)
- List **files that should be staged**

💡 Each issue/commit must:
- Be atomic (one purpose only)
- Follow best Git practices
- Group only logically related code

## Effective Issue Management Workflow

### 1. Issue Organization
- Use **labels** to categorize issues (bug, enhancement, documentation)
- Assign **milestones** to group related issues into larger deliverables
- Set **priority** and **difficulty** to aid sprint planning

### 2. Issue Structure
- **Title**: Clear, concise summary (verb + object)
- **Description**:
  - Problem statement
  - Acceptance criteria
  - Technical approach (optional)
  - Additional context/screenshots

### 3. Work Process
- Move issues through stages: Backlog → To Do → In Progress → Review → Done
- Link PRs to issues using GitHub keywords (closes, fixes, resolves)
- Reference related issues to maintain context

### 4. Dynamic GitHub CLI Automation

Make your GitHub CLI commands work with any repository by using dynamic variables:

```bash
# Get current repository owner and name
REPO_INFO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
REPO_OWNER=$(echo $REPO_INFO | cut -d'/' -f1)
REPO_NAME=$(echo $REPO_INFO | cut -d'/' -f2)

# List all milestones using current repository context
gh api repos/$REPO_OWNER/$REPO_NAME/milestones --jq '.[] | {title, description}'

# Create a bash function for milestone operations
gh_milestone() {
  if [ "$1" = "list" ]; then
    gh api repos/$REPO_OWNER/$REPO_NAME/milestones --jq '.[] | {number, title, description}'
  elif [ "$1" = "issues" ] && [ -n "$2" ]; then
    gh issue list --milestone "$2"
  fi
}

# Usage examples:
# gh_milestone list
# gh_milestone issues "3: Business Logic Layer"

# Interactive milestone selection script
select_milestone() {
  echo "Available milestones:"
  milestones=$(gh api repos/$REPO_OWNER/$REPO_NAME/milestones --jq '.[] | "\(.number): \(.title)"')
  echo "$milestones"
  echo "Enter milestone number (or press Enter to select by title):"
  read selection
  
  if [ -z "$selection" ]; then
    echo "Enter milestone title or part of title:"
    read title_part
    selected=$(echo "$milestones" | grep -i "$title_part" | head -1)
    echo "$selected" | cut -d':' -f1
  else
    echo "$selection"
  fi
}

# Store project configuration for easy access
save_project_config() {
  cat > .gh-config.json << EOF
{
  "currentMilestone": "$1",
  "labels": ["bug", "enhancement", "documentation"],
  "assignees": ["$REPO_OWNER"]
}
EOF
  echo "Config saved to .gh-config.json"
}

# Load configuration values
load_project_config() {
  if [ -f .gh-config.json ]; then
    CURRENT_MILESTONE=$(jq -r '.currentMilestone' .gh-config.json)
    echo "Current milestone: $CURRENT_MILESTONE"
  else
    echo "No config file found. Create one with save_project_config \"milestone name\""
  fi
}

# Example of a complete workflow
create_issue_in_milestone() {
  # Dynamically select milestone
  echo "Select milestone for new issue:"
  MILESTONE_NUM=$(select_milestone)
  
  # Prompt for issue details
  echo "Enter issue title:"
  read ISSUE_TITLE
  echo "Enter issue description:"
  read ISSUE_DESC
  
  # Create the issue
  gh issue create --title "$ISSUE_TITLE" --body "$ISSUE_DESC" --milestone "$MILESTONE_NUM"
  
  echo "Issue created successfully in milestone $MILESTONE_NUM"
}
```

## 2. Interactive Milestone Selection

```bash
# Interactive milestone selection script
select_milestone() {
  echo "Available milestones:"
  gh api repos/$REPO_OWNER/$REPO_NAME/milestones --jq '.[] | "\(.number): \(.title)"'
  echo "Enter milestone number:"
  read milestone_number
  echo $milestone_number
}

# Use it in commands
MILESTONE=$(select_milestone)
gh issue list --milestone "$MILESTONE"
```

## 3. Store Project Configuration

```bash
# Create a local config file (.gh-config.json):
cat > .gh-config.json << EOF
{
  "currentMilestone": "3: Business Logic Layer",
  "labels": ["bug", "enhancement", "documentation"]
}
EOF

# Use jq to extract configuration values
CURRENT_MILESTONE=$(jq -r '.currentMilestone' .gh-config.json)
gh issue list --milestone "$CURRENT_MILESTONE"
```

🧪 Example Output:

## Issue 1: Extract reusable header component

**Description:**
This refactors the header into a separate component for reuse across pages.

**Commit message:**
`refactor(header): extract header into separate component`

**Staged files:**
- `src/components/Header.tsx`
- `src/pages/Home.tsx`
