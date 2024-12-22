# Zmux-Sessionizer
Trying to develop a Tmux Plugin for creating and opening custom sessions.
You can check [here](https://github.com/MrSloth-dev/.dotfiles/blob/main/scripts/zmux.sh) the shell script that was the origin of the idea for this plugin.

# Instalation

```
mkdir -p ~/.local/bin/
wget https://raw.githubusercontent.com/MrSloth-dev/eZmux/refs/heads/main/zmux -O ~/.local/bin/zmux
chmod u+x ~/.local/bin/zmux
# Add to .bashrc or .zshrc or add /.local/bin to $PATH
echo 'alias zmux="~/.local/bin/zmux"' >> ~/.zshrc
source ~/.zshrc
```

## Dependencies

- `yq` version greater or equal to `v4.44.6` This tool allows the configuration parsing.
- `tmux` (doh).
- `fzf` This tool allows quick and interactive listing of all pre-configured and opened sessions.

# Usage

As simple as a person wants. Just type `zmux` (after correct install) and it pop ups a `fzf` window and then select the pretended session.

# Configuration

Create a file in `~/.config/ezmux/config.yaml`. This is where the script will fectch the pre-configured sessions.

For a basic session:
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

### [0.1.1] - 2024-12-22

### Bugfix

- Fixed yq parse because I was using an older version. Now it requires v4.44.6.
- Fixed error when user inserted an non existent and not configured session name.
- Root folder wasn't being set correctly.

### [0.1] - 2024-12-14
 
### Added
   
- This is the first Version.
- List all avaiable sessions trough `fzf`
- It fetch the preconfigured sessions in '~/.config/zmux/config.yaml'
- When Selected, it create/opens the session.

## License
MIT
