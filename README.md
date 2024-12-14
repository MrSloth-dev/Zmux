# Zmux-Sessionizer
Trying to develop a Tmux Plugin for creating and opening custom sessions.
You can check [here](https://github.com/MrSloth-dev/.dotfiles/blob/main/scripts/zmux.sh) the shell script that was the origin of the idea for this plugin.

# Instalation

Right now you can copy the script and add to PATH. (`~/.local/bin/` for example) simple as that

## Dependencies

This script needs `yq`, `tmux`(doh) and `fzf` to run. Although I'm working on making a fallback for fzf.

# Usage

As simple as a person wants. Just type `zmux` (after correct install) and it pop ups a `fzf` window and then select the pretended session.

# Configuration

Create a file in `~/.config/zmux/config.yaml`. This is where the script will fectch the pre-configured sessions.

For a basic session
```
sessions:
  project_a:
    root: ~/Projects/ProjectA/
    windows:
      - name: Editor
        command: nvim .
      - name: Terminal
        command: ls
  project_b:
    root: ~/Projects/ProjectB/
    windows:
      - name: Code
        command: nvim main.cpp
      - name: compiling
        command: echo hello
      - name: README.md
        command: nvim README.md
```
For now there is not layout but will be implemented.

# Roadmap | TODO
- [x] Create Session with `zmux <session_name>`
  - [x] Assign root directory
  - [x] Create Normal Windows and rename them
  - [x] Create Windows with different Panes
  - [x] Send Commands to each pane
- [ ] `zmux` without args list all available sessions opened and in the configuration file
  - [x] fzf
  - [x] without fzf
  - [ ] Need to have a fallback.
- [ ] Different layouts for splits
- [ ] Save the current session into a YAML file for future usage.
- [ ] Command to create a new configuration file with a template.
- [ ] Sugestions are welcome!

### [0.1] - 2024-12-14
 
### Added
   
- This is the first Version.
- List all avaiable sessions trough `fzf`
- It fetch the preconfigured sessions in '~/.config/zmux/config.yaml'
- When Selected, it create/opens the session.

## License
MIT
