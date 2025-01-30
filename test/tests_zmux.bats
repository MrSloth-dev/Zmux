#!/usr/bin/env bats

setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'
  export HOME=$(mktemp -d)
  mkdir -p "${HOME}/.config/zmux"
  touch "${HOME}/.config/zmux/config.yaml"
  DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
  PATH="$DIR/../:$PATH"
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
    cp /usr/bin/awk .
    cp /usr/bin/bash .
    cp /usr/bin/env .
    export PATH=$PWD
    run $DIR/../zmux
    assert_failure
    assert_output --partial "tmux is required but not installed"
    export PATH=$PATH:/usr/bin
}

@test "Error when fzf is missing" {
    cp /usr/bin/awk .
    cp /usr/bin/bash .
    cp /usr/bin/env .
    cp /usr/bin/tmux .
    cp /usr/bin/yq .
    export PATH=$PWD
    run $DIR/../zmux
    assert_failure
    assert_output --partial "fzf is required but not installed"
    export PATH=$PATH:/usr/bin
}

# @test "Error when yq is missing" {
#     cp /usr/bin/awk .
#     cp /usr/bin/bash .
#     cp /usr/bin/env .
#     cp /usr/bin/tmux .
#     cp /usr/bin/fzf .
#     export PATH=$PWD
#     run $DIR/../zmux
#     assert_failure
#     assert_output --partial "yq is required but not installed"
#     export PATH=$PATH:/usr/bin
# }

@test "Error on missing YAML config" {
    rm -f "${HOME}/.config/zmux/config.yaml"
    run zmux
    assert_failure
    assert_output --partial "No yaml configuration found"
}

@test "Attach to an existing session" {
    echo "
    sessions:
      yaml_session:
        root: /tmp
        windows:
          - name: compile
            command : pwd
          - name: main
            command: ''" > "${HOME}/.config/zmux/config.yaml"
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
    run pgrep tmux
    assert_failure
}

@test "Kill the tmux session using --kill flag" {
    tmux new-session -d -s "kill_test"
    run zmux --kill kill_test
    assert_success
    run tmux has-session -t kill_test
    assert_output --partial "no server running"
}

@test "Create session from a YAML configuration file" {
    # Create a mock YAML configuration
    echo "
    sessions:
      yaml_session:
        root: /tmp
        start_index: 1
        windows:
          - name: main
            command: ''" > "${HOME}/.config/zmux/test.yaml"

    run zmux yaml_session

    [[ $(tmux has-session -t yaml_session) -eq 0 ]]
    [[ $(tmux list-windows -t yaml_session) -eq 0 ]]
    run zmux -k all
}

@test "Error on invalid YAML configuration" {
    echo "
    sessions:
yaml_session:
            command: ''" > "${HOME}/.config/zmux/test.yaml"
  run zmux
  assert_failure
  assert_output --partial "Bad format in"
}

@test "Error on duplicate session names" {
  echo "
  sessions:
    duplicate_session:
      root: /tmp
    duplicate_session:
      root: /tmp" > "${HOME}/.config/zmux/config.yaml"
  run zmux
  assert_failure
  assert_output --partial "duplicate session(s) found"
}

# @test "Create session with splits from YAML configuration" {
#   echo "
#   sessions:
#     split_session:
#       root: /tmp
#       windows:
#         - name: main
#           layout: tiled
#           panes:
#             - command: echo pane1
#             - command: echo pane2" > "${HOME}/.config/zmux/config.yaml"
#   run zmux split_session
#   assert_success
#   run tmux list-windows -t split_session
#   assert_output --partial "main"
#   run tmux list-panes -t split_session:main
#   assert_output --partial "pane1"
#   assert_output --partial "pane2"
# }

# Remove temp files
DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
rm -fr $DIR/./awk $DIR/./bash $DIR/./env $DIR/./tmux $DIR/./fzf $DIR/./yq
# Add more tests for each functionality.
