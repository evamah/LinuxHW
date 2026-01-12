#!/usr/bin/env bash

CSV_FILE="tasks.csv"
LOG_FILE="logs/git_actions.log"
mkdir -p "$(dirname "$LOG_FILE")"

# Helper 
exitError() {
  echo "Error: $*" >&2
  echo "$(date '+%F %T') | ERROR | $*" >> "$LOG_FILE"
  exit 1
}

# Validate args 
if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <TASK_ID> \"<Optional_Message>\""
  exit 1
fi

TASK_ID_INPUT="$1"
OPTIONAL_MSG="${2-}"  

if [ ! -f "$CSV_FILE" ]; then
  exitError "CSV file not found: $CSV_FILE"
fi


FOUND_LINE=""

lastTwoLines="$(tail -n 2 "$CSV_FILE")"


while IFS= read -r line; do
  [[ -n "$line" ]] || continue

  IFS=',' read -r REPO_PATH GITHUB_URL DEV_NAME BRANCH_NAME TASK_DESC TASK_ID EXTRA <<< "$line"

  # exactly 6 fields
  if [[ -n "${EXTRA-}" || -z "${TASK_ID-}" ]]; then
    continue
  fi

  # find the requested id
  if [[ "$TASK_ID" == "$TASK_ID_INPUT" ]]; then
    FOUND_LINE="$line"
    break
  fi
done <<< "$lastTwoLines"

if [[ ! -n "$FOUND_LINE" ]]; then
  exitError "TASK_ID '$TASK_ID_INPUT' not found in $CSV_FILE"
fi

IFS=',' read -r REPO_PATH GITHUB_URL DEV_NAME BRANCH_NAME TASK_DESC TASK_ID <<< "$FOUND_LINE"

#  Ensure repo exists, if not clone 
if [[ ! -d "$REPO_PATH/.git" ]]; then
  echo "Repo not found locally. Cloning..."
  mkdir -p "$(dirname "$REPO_PATH")"
  git clone "$GITHUB_URL" "$REPO_PATH"
fi

cd "$REPO_PATH"

# Ensure branch exists + checkout 
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
  git switch "$BRANCH_NAME"
else
  # Try to track remote branch if exists
  if git show-ref --verify --quiet "refs/remotes/origin/$BRANCH_NAME"; then
    git switch -c "$BRANCH_NAME" --track "origin/$BRANCH_NAME"
  else
    # Create new local branch
    git switch -c "$BRANCH_NAME"
  fi
fi

# Validate current branch matches CSV 
CUR_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [ "$CUR_BRANCH" != "$BRANCH_NAME" ]; then
    exitError "Branch mismatch. CSV expects '$BRANCH_NAME' but current is '$CUR_BRANCH'."
fi

# Check changes 
if [[ -z "$(git status --porcelain)" ]]; then
  echo "Nothing to commit. Working tree clean."
  exit 0
fi

# Build commit message (required format) 
NOW="$(date '+%F %H:%M')"
# TASKID - CurrentDateTime - BranchName - DevName - TaskDesc - AppendedDevMessage
COMMIT_MSG="${TASK_ID} - ${NOW} - ${BRANCH_NAME} - ${DEV_NAME} - ${TASK_DESC}"
if [[ -n "$OPTIONAL_MSG" ]]; then
  COMMIT_MSG="${COMMIT_MSG} - ${OPTIONAL_MSG}"
fi

# Commit + push 
git add .
git commit -m "$COMMIT_MSG"

COMMIT_HASH="$(git rev-parse HEAD)"
echo "Committed: $COMMIT_HASH"
echo "Message:   $COMMIT_MSG"
echo


# Push (create remote branch if needed)
git push -u origin "$BRANCH_NAME"

cd ..
cd ..
echo "Push to GitHub succeeded."
echo "$(date '+%F %T') | OK | TASK=$TASK_ID | BR=$BRANCH_NAME | HASH=$COMMIT_HASH" >> "$LOG_FILE"