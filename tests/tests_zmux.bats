#!/usr/bin/env bats

setup() {
  export HOME=$(mktemp -d)
  mkdir -p "${HOME}/.config/zmux"
  touch "${HOME}/.config/zmux/config.yaml"
}

@test "Check zmux version" {
  run ./zmux --version
  [ "$status" -eq 0 ]
  [[ "$output" == "v0.3.1" ]]
}

@test "Missing tmux" {
  run command -v fake_tmux_command || true
  [ "$status" -ne 0 ]
}

@test ""

# Add more tests for each functionality.
