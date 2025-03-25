# ⚡⚙️ Zmux-Sessionizer ⚡⚙️

Zmux is a bash script designed to make, managing and creating Tmux sessions a breeze.

Whether you're juggling multiple projects or just need a quick way to organize your workflow, Zmux has got you covered!



![img](assets/preview.png)


## Instalation 📥

### Step 1: Download Zmux
Choose a directory where you want to install Zmux (e.g., `~/.local/bin`, `~/bin`, or any directory in your `$PATH`).
``` bash
# Example: Install to ~/.local/bin
mkdir -p ~/.local/bin
curl -o ~/.local/bin/zmux https://raw.githubusercontent.com/MrSloth-dev/eZmux/main/zmux
chmod +x ~/.local/bin/zmux
```

### Step 2: Add to $PATH
Ensure the installation directory is in your `$PATH`. Add the following line to your shell configuration file (`~/.bashrc`, `~/.zshrc`, etc.):

``` bash
export PATH=$PATH:~/.local/bin  # Replace with your chosen directory
```
Then reload your shell:
```bash
source ~/.zshrc  # or ~/.bashrc
```
### Step 3: Verify Instalation
Check if Zmux is installed correctly
```bash
zmux -v
```

## Dependencies ⚙️

- `tmux` version greater or equal to `v3.3`.
- `yq` version greater or equal to `v4.44.6`. This tool allows the configuration parsing.
- `fzf` This tool allows quick and interactive listing of all pre-configured and opened sessions.
- `yamllint` This tool check if configuration files are well formatted.

## Usage 🛠️

Zmux is designed to be simple and intuitive. You can use it in several ways:

### List and Select Sessions

Run zmux without any arguments to open an interactive fzf window. This lists all active and pre-configured sessions.

![img](assets/preview.png)

Press Ctrl-t to toggle the preview window, which shows detailed information about the selected session, including:

 - Session status (active/inactive).

 - Configured windows and panes.

 - Layouts and commands for each pane.

### Open or Create a Specific Session

Run `zmux <session-name>` to open or create a specific session. If the session does not exist, Zmux will prompt you to create it.
 - If the session is pre-configured in your YAML files, Zmux will create the session with the specified windows, panes, and commands.

 - If the session does not exist, Zmux will create a new session with the given name.

### Export Current Session Configuration

Use the -e or --export flag to export the current session configuration to a YAML file. This is useful for saving session setups for future use.

 - Zmux will prompt you to select a configuration file or create a new one.

 - The exported configuration will include:

  - Root directory.

  - Windows and their respective panes.

  - Commands for each pane.

- Note: The export of panes in split is currently not implemented.

### Kill Session or Server

Use the `-k <session-name>` or --kill flag to kill the selected session. To kill the Tmux server and close all sessions use `-k all`

### Check Configuration Files

Use the `-c` or `--check` flag to validate your YAML configuration files with `yamllint`.
 - This ensures your configuration files are well-formatted and free of errors.

### Print Help

Use the `-h` or `--help` flag to display the help message.

### Using Split (v0.4.0+)

You can now configure splits (panes) within windows in your session configuration. Each window can have multiple panes with customizable layouts and commands.

### Example Configuration

``` yaml
sessions:
  project_a:
    root: ~/Projects/ProjectA/
    windows:
      - name: Editor
        layout: tiled  # Supported layouts: tiled, even-horizontal, even-vertical
        panes:
          - command: nvim .
          - command: htop
      - name: Server
        command: npm run dev
```
### Supported Layouts
 - `tiled` : Panes are arranged in a grid.
 - `even-horizontal `: Panel are arranged horizontally with equal width.
 - `even-vertical `: Panel are arranged horizontally with equal height.
 - `main-horizontal` : Panel are arranged horizontally with equal height but the first index, this will occupy half of the screen.
 - `main-vertical` : Panel are arranged horizontally with equal width but the first index, this will occupy half of the screen.


## Configuration ⚙️

All configurations will be sourced in `YAML` format under `~/.config/zmux/` directory.

You can have multiple sessions pre-configured in each file:
```
~/.config/zmux/
  ├── work.yaml      # Work-related sessions
  ├── personal.yaml  # Personal project sessions
  ├── dev.yaml       # Development environment sessions
  └── server.yaml    # Server management sessions
```

Example session:

``` yaml
sessions:
  project_a:
    root: ~/Projects/ProjectA/
    windows:
      - name: Editor
        layout: tiled
        panes:
          - command: nvim .
          - command: htop
      - name: Server
        command: npm run dev
```
### Key Fields 🔑
- root: Root directory for the session.

- windows: List of windows.

  - name: Window name.

  - command: Command to run in the window (or pane).

  - layout: (Optional) Layout for splits. Supported: tiled, even-horizontal, even-vertical. (v0.4.0+)

  - panes: (Optional) List of panes for splits. Each pane can have a command. (v0.4.0+)

- Note: Due to how tmux commands works, I suggest to not put dots '.' in the name of windows and panes, because it leads to undefined behaviour that (currently) I cannot fix.

## Roadmap | TODO 🗺️
- [x] Create Session with `zmux <session_name>`
  - [x] Assign root directory
  - [x] Create Normal Windows and rename them
  - [x] Create Windows with different Panes
  - [x] Send Commands to each pane
- [x] `zmux` without args list all available sessions opened and in the configuration file
  - [x] fzf
- [x] Export the current session into a YAML file for future usage
  - [ ] Export working with splits!
- [x] Use multiple files instead of only `config.yaml`
- [x] Configuration Checker
- [x] Preview windows in fzf list
- [x] Splits!
  - [x] Different Layouts!
- [x] CI and testing to make sure it doesn't break anything
- [ ] Sugestions are welcome!

## Changelog 📜

### [0.4.1] - 2024-03-25

#### Added
- Error Handling: Created a default config because of configuration checks [#4](https://github.com/MrSloth-dev/Zmux/issues/4)

#### Changed
- Prevented some helper functions to be passed for subshells. [#5](https://github.com/MrSloth-dev/Zmux/issues/5)

#### Bugfix
- Fixed Typos.

### [0.4.0] - 2024-01-31

#### Added
- Splits Support: Now you can configure splits (panes) within windows in your session configuration.
- Improved Preview in `fzf`: The preview window now shows detailed information about splits.
- Session Kill: Now you can kill a specific session with `zmux -k <session-name>` or kill the server `zmux -k all`

#### Changed
- Configuration Format: The `windows` section now supports a `panes` field for defining splits.
- Error Handling: Improved error messages for invalid split configurations.

#### Bugfix
- Fixed an issue where the `root` directory was not being correctly set for panes.
- Fixed a bug where the `fzf` preview window would not display pane information correctly.
- Fixed an issue when export into a new file the `sessions:` header was missing


### [0.3.2] - 2025-01-17

### Added

- Now you can check your configuration files with `zmux --check` or `zmux -c`!
- `-v` flag for checking the version
- Testing with `bats` and CI.

### Bugfix

- Correct the file list when creating new file through export, now also follows symbolic links.


### [0.3.1] - 2025-01-16

### Added

- Added preconfigured sessions check for duplicates. Now duplicates are forbidden.
- `-v` flag for checking the version

### Changed

- Changed the way that export works, now creates (correctly) a .yaml file if there isn't one or appends if the user want to group configurations.

### Bugfix

- Sometimes the yaml generated text was badly formatted.


### [0.3] - 2025-01-03

### Added

- Added support for multiple configuration files, now you can do it like this:
- Added window Preview when seeing in `fzf list` , can press `ctrl-t` to toggle preview-window.


### [0.2] - 2024-12-29
 
### Added
   
- Now you can see help with `-h` or `--help`
- Easier kill server with `-k` or `--kill` flag.
- Now you can export configuration of current session using `-e` or `--export` flag.
 - Note: The command will be always empty. It still exist to easen the completion of the configuration. Still finding a way to implement this. 
- Added creating new sessions if the user inputs a non-existant name (still need to export if want to save)
- If Config file isn't found, create an empty one.

### Bugfix
- When there wasn't a tmux server, `zmux` didn't work.
- Now `session_name` can only have alphanumeric, underscore and hyphen.
- If there wasn't any sessions in config file `zmuz` didn't work.


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

## License 📄
MIT
