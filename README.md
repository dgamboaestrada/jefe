# jefe-cli

## Getting Started
### Prerequisities
- Unix-like operating system (macOS or Linux)
- curl or wget should be installed
- git should be installed

### Basic Installation
Oh My Zsh is installed by running one of the following commands in your terminal. You can install this via the command-line with either `curl` or `wget`.

#### via curl

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/dgamboaestrada/jefe/development/install.sh)"
```

#### via wget

```shell
sh -c "$(wget https://raw.githubusercontent.com/dgamboaestrada/jefe/development/install.sh -O -)"
```

#### Run project
```bash
jefe init
```

## Uninstalling jefe-cli
If you want to uninstall jefe-cli, just run `~/.jefe/uninstall.sh` from the command-line. It will remove itself and revert your previous bash or zsh configuration.
