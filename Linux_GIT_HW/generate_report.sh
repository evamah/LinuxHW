#!/usr/bin/env bash

exitError() {
  echo "Error: $*" >&2
  exit 1
}

if [ $# -ne 1 ]; then
  echo "Usage: $0 <path_to_tasks_csv>"
  exit 1
fi

CSV_PATH="$1"

if [ ! -f "$CSV_PATH" ]; then
    exitError "CSV not found: $CSV_PATH"
fi

OUT_FILE="TASK_REPORT.md"


tail -n +2 "$CSV_PATH" | while IFS=',' read -r REPO_PATH GITHUB_URL DEV_NAME BRANCH_NAME TASK_DESC TASK_ID; do
  echo "## Task $TASK_ID – $TASK_DESC" >> "$OUT_FILE"
  echo "" >> "$OUT_FILE"
  echo "TaskID: $TASK_ID" >> "$OUT_FILE"
  echo "Developer: $DEV_NAME" >> "$OUT_FILE"
  echo "Branch: $BRANCH_NAME" >> "$OUT_FILE"

  STATUS="NOT_STARTED"
  COMMITS_COUNT=0
  LAST_COMMIT_DT="-"
  LAST_COMMIT_HASH=""
  CHANGED_FILES=""

  if [[ -d "$REPO_PATH/.git" ]]; then
    # Search commits containing "TASK_ID - " in message (format requirement)
    pushd "$REPO_PATH" >/dev/null

    # Make sure we have latest info (optional)
    git fetch origin >/dev/null 2>&1 || true

    COMMITS_COUNT="$(git log --all --grep="^${TASK_ID} - " --pretty=oneline | wc -l | tr -d ' ')"

    if [[ "$COMMITS_COUNT" -gt 0 ]]; then
      STATUS="PUSHED"
      LAST_COMMIT_HASH="$(git log --all --grep="^${TASK_ID} - " -n 1 --pretty=format:%H)"
      LAST_COMMIT_DT="$(git show -s --format=%ci "$LAST_COMMIT_HASH" | cut -d' ' -f1-2)"

      # List changed files in that last commit
      CHANGED_FILES="$(git show --name-only --pretty="" "$LAST_COMMIT_HASH" | sed '/^\s*$/d')"
    fi

    popd >/dev/null
  fi

  echo "Status: $STATUS" >> "$OUT_FILE"
  echo "Commits: $COMMITS_COUNT" >> "$OUT_FILE"
  echo "Last Commit: $LAST_COMMIT_DT" >> "$OUT_FILE"
  echo "" >> "$OUT_FILE"

  echo "Changed files:" >> "$OUT_FILE"
  if [[ -n "$CHANGED_FILES" ]]; then
    echo "$CHANGED_FILES" | sed 's/^/- /' >> "$OUT_FILE"
  else
    echo "- (none)" >> "$OUT_FILE"
  fi

  echo "" >> "$OUT_FILE"
done

echo "Report created: $OUT_FILE"

