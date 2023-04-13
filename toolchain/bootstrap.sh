YW=$(echo "\033[33m")
RD=$(echo "\033[01;31m")
BL=$(echo "\033[36m")
GN=$(echo "\033[1;92m")
GNT=$(echo "\033[0;92m")
TIP=$(echo "\033[0;36;100m")
CL=$(echo "\033[m")
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"
BFR=$(echo "\033[1A\033[2K")
WORKSPACE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOLD=$(tput bold)
REG=$(tput sgr0)

set -eo pipefail
set -o errexit
set -o errtrace
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
trap die ERR
set -e

function error_exit() {
  trap - ERR
  local reason="Unknown failure occurred."
  local msg="${1:-$reason}"
  local flag="${RD}‼ ERROR ${CL}$EXIT@$LINE"
  echo "$flag $msg" 1>&2
  exit $EXIT
}

function print_header() {
  echo "\n${BOLD}${BL}==== BOOTSTRAP ====${CL}${REG}"
  for detail in "$@"
  do
    echo " ${BL}- ${detail}${CL}"
  done
  echo ""
}

function msg_task() {
  local msg="$1"
  echo "${BOLD}${YW}${msg}${CL}${REG}"
}

function msg_info() {
  local msg="$1"
  echo "   - ${YW}${msg}..."
}

function msg_ok() {
  local msg="$1"
  echo -e "${BFR}${BOLD}${CM} ${GN}${msg}${CL}${REG}"
}

function msg_subtask_ok() {
  local msg="$1"
  echo -e "${BFR}${CM} ${GNT}${msg}${CL}"
}

function msg_error() {
  local msg="$1"
  echo -e "${BFR}${BOLD}${CROSS} ${RD}${msg}${CL}${REG}"
}

function msg_subtask_warn() {
  local msg="$1"
  echo -e "${BFR}${CROSS} ${RD}${msg}${CL}"
}

check_basics() {
  msg_task "checking basics\n"
  if ! [ -x "$(command -v git)" ]; then
    msg_error 'FATAL: git not found'
    exit 1
  fi
  msg_ok "basics ok"
}

check_nvm() {
  msg_info "checking nvm"
  if ! [ -d "$NVM_DIR" ]; then
    msg_subtask_warn "nvm not installed! ${TIP}see readme${REG}"
  else
    msg_subtask_ok "nvm already installed"
  fi
}

check_environment() {
  msg_task "checking environment"
  check_nvm

  msg_info "checking node"
  local tip="    -> run ${CL}${TIP}nvm install $WORKSPACE/.nvmrc && nvm use $WORKSPACE/.nvmrc${CL}${RD}"
  if ! [ -x "$(command -v node)" ]; then
    msg_subtask_warn "node not installed, install nvm then run\n${tip}"
    exit 0
  fi

  local node_want="$(cat $WORKSPACE/.nvmrc)"
  local node_have="$(node -v)"
  if [ "$node_have" = "$node_want" ]; then
    msg_subtask_ok "using correct node version ($node_want)"
    exit 0
  else
    msg_subtask_warn "mismatched node version ($node_have => $node_want)\n${tip}"
    exit 0
  fi
  msg_ok "environment ok"
}

get_project_repo() {
  local href="$1"
  local name=$(basename -s .git "$href")
  local install_flags="$2"

  msg_task "setup repo $href"
  msg_info "cloning"
  if [ -d "./$name" ]; then
    msg_subtask_ok "$name already cloned"
  else
    msg_info "${BFR} cloning $name into $WORKSPACE/repos"
    git clone "$href" "repos/$name" &>/dev/null
    msg_subtask_ok "cloned"
  fi

  msg_info "installing dependencies"
  if [ -d "./repos/$name" ]; then
    msg_subtask_ok "dependencies already installed"
  else
    cd "repos/$name" && eval "npm i $install_flags" &>/dev/null && cd ".."
    msg_subtask_ok "dependencies installed"
  fi

  msg_info ""
  msg_ok "repo ok"
}

print_header "workspace: $WORKSPACE" "user: $(whoami)" "shell: $SHELL"
check_basics

while IFS=',' read -r repo flags
do
  get_project_repo "$repo" "$flags"
done < "$WORKSPACE/repos.list"

check_environment