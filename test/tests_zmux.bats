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
  [ "$status" -eq 0 ]
  [[ "$output" == "v0.3.1" ]]
}

@test "Invalid flag" {
  run zmux --er
  assert_output "zmux: Error: Name must not start with '-'"
}

@test "Invalid name" {
  run zmux -hello 2>&1
  [ $status -eq 0 ]
  [[ "${output}" =~ "Error:" ]]
}

@test "Check zmux help" {
  run zmux --help
  [ $status -eq 0 ]
  [[ "${output}" =~ "Usage:" ]]
}

@test "Error when tmux is missing" {
    cp /usr/bin/awk .
    cp /usr/bin/bash .
    cp /usr/bin/env .
    export PATH=$PWD
    [ ! $($DIR/../zmux &>/dev/null) ]
    export PATH=$PATH:/usr/bin
}

@test "Error when fzf is missing" {
    cp /usr/bin/awk .
    cp /usr/bin/bash .
    cp /usr/bin/env .
    cp /usr/bin/tmux .
    cp /usr/bin/yq .
    export PATH=$PWD
    [ ! $($DIR/../zmux &>/dev/null) ]
    export PATH=$PATH:/usr/bin
}

@test "Error when yq is missing" {
    cp /usr/bin/awk .
    cp /usr/bin/bash .
    cp /usr/bin/env .
    cp /usr/bin/tmux .
    cp /usr/bin/fzf .
    export PATH=$PWD
    export PATH=/dev/null
    [ ! $($DIR/../zmux &>/dev/null) ]
    export PATH=$PATH:/usr/bin
}

@test "Error on missing YAML config" {
    rm -f "${HOME}/.config/zmux/config.yaml"
    run zmux
    [ "$status" -ne 0 ]
    [[ "${output}" =~ "No yaml configuration found" ]]
}

# @test "Create a new session" {
#     run zmux test-session
#     tmux has-session -t test-session
#     [ "$status" -eq 0 ]
# }

@test "Attach to an existing session" {
    tmux new-session -d -s existing-session
    run zmux existing-session
    [[ ! "${output}" =~ "Error" ]]
}

@test "Handling invalid session names" {
    invalid_session="session!@#"
    run zmux "$invalid_session"
    [ "$status" -ne 0 ]
    [[ "$output" =~ "zmux: Error: Invalid session name" ]]
}

@test "Kill the tmux server using --kill flag" {
    tmux new-session -d -s "kill_test"
    run zmux --kill
    [ "$status" -eq 0 ]
    ! tmux has-session -t kill_test
    [[ ! "$output" =~ "no server running" ]]

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
    [[ $(tmux list-windows -t yaml_session &>/dev/null) -eq 0 ]]
    tmux kill-server
}

# Remove temp files
DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
rm -fr $DIR/../awk $DIR/../bash $DIR/../env $DIR/../tmux $DIR/../fzf $DIR/../yq
# Add more tests for each functionality.
