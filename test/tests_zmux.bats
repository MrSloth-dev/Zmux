#!/usr/bin/env bats

setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'
  export HOME=$(mktemp -d)
  mkdir -p "${HOME}/.config/zmux"
  DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
  PATH="$DIR/../:$PATH"
}

# Build a throw-away bin dir holding symlinks to only the named tools, so we can
# test the "dependency missing" paths without copying binaries into the repo.
fake_bin() {
  local bindir
  bindir="$(mktemp -d)"
  local tool
  for tool in "$@"; do
    ln -sf "$(command -v "${tool}")" "${bindir}/${tool}"
  done
  echo "${bindir}"
}

@test "Check zmux version" {
  run zmux --version
  assert_success
  assert_output --regexp '^v[0-9]+\.[0-9]+\.[0-9]+$'
}

@test "Invalid flag" {
  run zmux --er
  assert_failure
  assert_output "zmux: Error: Name must not start with '-'"

  run zmux -invalid
  assert_failure
  assert_output "zmux: Error: Name must not start with '-'"
}

@test "Invalid name" {
  run zmux hell@#o
  assert_failure
  assert_output --partial "Error:"
}

@test "Check zmux help" {
  run zmux --help
  assert_success
  assert_output --partial "Usage:"
}

@test "Error when tmux is missing" {
    bindir="$(fake_bin bash env awk)"
    PATH="$bindir" run "$DIR/../zmux"
    assert_failure
    assert_output --partial "tmux is required but not installed"
    rm -rf "$bindir"
}

@test "Error when fzf is missing" {
    bindir="$(fake_bin bash env awk tmux)"
    PATH="$bindir" run "$DIR/../zmux"
    assert_failure
    assert_output --partial "fzf is required but not installed"
    rm -rf "$bindir"
}

@test "Error when yq is missing" {
    bindir="$(fake_bin bash env awk tmux fzf)"
    PATH="$bindir" run "$DIR/../zmux"
    assert_failure
    assert_output --partial "yq (mikefarah) is required but not installed"
    rm -rf "$bindir"
}

@test "Error on missing TOML config" {
    rm -f "${HOME}/.config/zmux/config.toml"
    run zmux
    assert_failure
    assert_output --partial "No TOML configuration found"
}

@test "Attach to an existing session" {
    cat > "${HOME}/.config/zmux/config.toml" <<'EOF'
[sessions.yaml_session]
root = "/tmp"

[[sessions.yaml_session.windows]]
name = "compile"
command = "pwd"

[[sessions.yaml_session.windows]]
name = "main"
command = ""
EOF
  run tmux new-session -d -s existing_session
  run zmux existing_session
  run tmux list-sessions
  assert_success
  assert_output --partial "existing_session"
}

@test "Handling invalid session names" {
    invalid_session="session@#"
    run zmux "$invalid_session"
    assert_failure
}

@test "Kill the tmux server using --kill flag" {
    tmux new-session -d -s "kill_server_test"
    run zmux --kill all
    assert_success
    run tmux ls
    assert_failure
    assert_output --partial "no server running"
}

@test "Kill the tmux session using --kill flag" {
    tmux new-session -d -s "kill_test"
    run zmux --kill kill_test
    assert_success
    run tmux has-session -t kill_test
    assert_output --partial "no server running"
}

@test "Create session from a TOML configuration file" {
    cat > "${HOME}/.config/zmux/test.toml" <<'EOF'
[sessions.toml_session]
root = "/tmp"
start_index = 1

[[sessions.toml_session.windows]]
name = "main"
command = ""
EOF

    run zmux toml_session

    run tmux has-session -t toml_session
    assert_success
    run tmux list-windows -t toml_session
    assert_success
    assert_output --partial "main"
    run zmux -k all
}

@test "Create session with splits from a TOML configuration file" {
    cat > "${HOME}/.config/zmux/test.toml" <<'EOF'
[sessions.split_session]
root = "/tmp"

[[sessions.split_session.windows]]
name = "main"
layout = "tiled"
panes = [
  { command = "echo PANE_ONE" },
  { command = "echo PANE_TWO" },
]
EOF

    run zmux split_session

    run tmux has-session -t split_session
    assert_success
    run tmux list-panes -t split_session:main
    assert_success
    [[ "$(tmux list-panes -t split_session:main | wc -l)" -eq 2 ]]
    run zmux -k all
}

@test "Error on invalid TOML configuration" {
    printf '[sessions.broken\ncommand = ""\n' > "${HOME}/.config/zmux/test.toml"
  run zmux
  assert_failure
  assert_output --partial "Invalid TOML in"
}

@test "Error on duplicate session names" {
  printf '[sessions.duplicate_session]\nroot = "/tmp"\n' > "${HOME}/.config/zmux/config.toml"
  printf '[sessions.duplicate_session]\nroot = "/tmp"\n' > "${HOME}/.config/zmux/other.toml"
  run zmux
  assert_failure
  assert_output --partial "duplicate session(s) found"
}
