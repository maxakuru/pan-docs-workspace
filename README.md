# pan-docs-workspace

Mono-repo development environment for the Palo Alto Networks Prisma Cloud Docs project.

## Recommended environment

**Shell**: posix-compliant 
  - Needed for bootstrap scripts & NVM
  - Windows: [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) recommended, [GitBash](https://gitforwindows.org/) or [Cygwin](https://cygwin.com/) should also work

**Editor**: [VSCode](https://code.visualstudio.com/)
  - Others work fine, tasks & workspace settings are for VSCode
  - [VSCode CLI](https://code.visualstudio.com/docs/editor/command-line) can be convenient

**Node.js**: Currently `18.12.0`
  - Current version is defined in `.nvmrc`
  - [NVM](https://github.com/nvm-sh/nvm) is recommended for managing versions

**Permissions**: At least read access on all sub-projects

## Setup

### Bootstrap

1. Get workspace repo
```sh
git clone https://github.com/maxakuru/pan-docs-workspace.git
cd pan-docs-workspace
```

2. Setup workspace
```sh
./toolchain/bootstrap.sh
```
This will fetch project repos and install project dependencies, check whether nvm is installed, and compare your Node version to the expected version in `.nvmrc`. You can also do each command manually if you prefer or run into an error.

> Note: installing nvm and running associated commands are left up to the user, nvm is not required