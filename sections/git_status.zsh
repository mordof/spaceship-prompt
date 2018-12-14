#
# Git status
#

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_GIT_STATUS_SHOW="${SPACESHIP_GIT_STATUS_SHOW=true}"
SPACESHIP_GIT_STATUS_PREFIX="${SPACESHIP_GIT_STATUS_PREFIX=" ["}"
SPACESHIP_GIT_STATUS_SUFFIX="${SPACESHIP_GIT_STATUS_SUFFIX="]"}"
SPACESHIP_GIT_STATUS_COLOR="${SPACESHIP_GIT_STATUS_COLOR="red"}"
SPACESHIP_GIT_STATUS_UNTRACKED="${SPACESHIP_GIT_STATUS_UNTRACKED="?"}"
SPACESHIP_GIT_STATUS_ADDED="${SPACESHIP_GIT_STATUS_ADDED="+"}"
SPACESHIP_GIT_STATUS_MODIFIED="${SPACESHIP_GIT_STATUS_MODIFIED="!"}"
SPACESHIP_GIT_STATUS_RENAMED="${SPACESHIP_GIT_STATUS_RENAMED="»"}"
SPACESHIP_GIT_STATUS_DELETED="${SPACESHIP_GIT_STATUS_DELETED="x"}"
SPACESHIP_GIT_STATUS_STASHED="${SPACESHIP_GIT_STATUS_STASHED="$"}"
SPACESHIP_GIT_STATUS_UNMERGED="${SPACESHIP_GIT_STATUS_UNMERGED="="}"
SPACESHIP_GIT_STATUS_AHEAD="${SPACESHIP_GIT_STATUS_AHEAD="⇡"}"
SPACESHIP_GIT_STATUS_BEHIND="${SPACESHIP_GIT_STATUS_BEHIND="⇣"}"
SPACESHIP_GIT_STATUS_DIVERGED="${SPACESHIP_GIT_STATUS_DIVERGED="⇕"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# We used to depend on OMZ git library,
# But it doesn't handle many of the status indicator combinations.
# Also, It's hard to maintain external dependency.
# See PR #147 at https://git.io/vQkkB
# See git help status to know more about status formats
spaceship_git_status() {
  [[ $SPACESHIP_GIT_STATUS_SHOW == false ]] && return

  spaceship::is_git || return

  local INDEX git_status=""

  INDEX=$(command git status --porcelain -b 2> /dev/null)

  spaceship::section \
    "gray" \
    "$SPACESHIP_GIT_STATUS_PREFIX";

  # Check for unmerged files
  unmerged_file_count=$(echo "$INDEX" | command grep '^U[UDA] ' | wc -l);
  unmerged_file_count=$(($unmerged_file_count + $(echo "$INDEX" | command grep '^AA ' | wc -l)));
  unmerged_file_count=$(($unmerged_file_count + $(echo "$INDEX" | command grep '^DD ' | wc -l)));
  unmerged_file_count=$(($unmerged_file_count + $(echo "$INDEX" | command grep '^[DA]U ' | wc -l)));
  if [ $unmerged_file_count -gt 0 ]; then
    spaceship::section "117" "$unmerged_file_count$SPACESHIP_GIT_STATUS_UNMERGED";
  fi

  # Check for untracked files
  untracked_file_count=$(echo "$INDEX" | command grep -E '^\?\? ' | wc -l);
  if [ $untracked_file_count -gt 0 ]; then
    spaceship::section "white" "$untracked_file_count$SPACESHIP_GIT_STATUS_UNTRACKED";
  fi

  # Check for modified files
  modified_file_count=$(echo "$INDEX" | command grep '^[ MARC]M ' | wc -l);
  if [ $modified_file_count -gt 0 ]; then
    spaceship::section "yellow" "$modified_file_count$SPACESHIP_GIT_STATUS_MODIFIED";
  fi

  # Check for renamed files
  rename_file_count=$(echo "$INDEX" | command grep '^R[ MD] ' | wc -l);
  if [ $rename_file_count -gt 0 ]; then
    spaceship::section "cyan" "$rename_file_count$SPACESHIP_GIT_STATUS_RENAMED";
  fi

  # Check for staged files
  staged_file_count=$(echo "$INDEX" | command grep '^A[ MDAU] ' | wc -l);
  staged_file_count=$(($staged_file_count + $(echo "$INDEX" | command grep '^M[ MD] ' | wc -l)));
  staged_file_count=$(($staged_file_count + $(echo "$INDEX" | command grep '^UA' | wc -l)));
  if [ $staged_file_count -gt 0 ]; then
    spaceship::section "green" "$staged_file_count$SPACESHIP_GIT_STATUS_ADDED";
  fi

  # Check for deleted files
  deleted_file_count=$(echo "$INDEX" | command grep '^[MARCDU ]D ' | wc -l);
  deleted_file_count=$(($deleted_file_count + $(echo "$INDEX" | command grep '^D[ UM] ' | wc -l)));
  if [ $deleted_file_count -gt 0 ]; then
    spaceship::section "red" "$deleted_file_count$SPACESHIP_GIT_STATUS_DELETED";
  fi

  # Check for stashes
  if $(command git rev-parse --verify refs/stash >/dev/null 2>&1); then
    spaceship::section "blue" "$SPACESHIP_GIT_STATUS_STASHED";
  fi

  # Check whether branch is ahead
  local is_ahead=false
  if $(echo "$INDEX" | command grep '^## [^ ]\+ .*ahead' &> /dev/null); then
    is_ahead=true
  fi

  # Check whether branch is behind
  local is_behind=false
  if $(echo "$INDEX" | command grep '^## [^ ]\+ .*behind' &> /dev/null); then
    is_behind=true
  fi

  # Check wheather branch has diverged
  if [[ "$is_ahead" == true && "$is_behind" == true ]]; then
    spaceship::section "magenta" "$SPACESHIP_GIT_STATUS_DIVERGED";
  else
    [[ "$is_ahead" == true ]] && spaceship::section "magenta" "$SPACESHIP_GIT_STATUS_AHEAD";
    [[ "$is_behind" == true ]] && spaceship::section "magenta" "$SPACESHIP_GIT_STATUS_BEHIND";
  fi

  spaceship::section "gray" "$SPACESHIP_GIT_STATUS_SUFFIX";
}
