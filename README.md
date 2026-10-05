# bash-it template

Provisioned from [`Qode-Fleet-Control/fleet-template-v1`](https://github.com/Qode-Fleet-Control/fleet-template-v1) — the fleet
lifecycle contract (`bin/`, `fleet.conf`, `compose.yaml`, deploy workflows) with a
bash-it starter laid on top. **A job, not a service**: the image's default command runs the
check and exits 0 on success; nothing listens on `$PORT`.

## What it is

A versioned bash setup (`VERSION`, currently 1.0.0) on [bash-it](https://github.com/Bash-it/bash-it):

| path | what |
|---|---|
| `bash/.bashrc` | the rc file — loads bash-it with this repo's theme and custom dir |
| `bash/custom/qode.plugin.bash` | the setup's own plugin (`qode_hello`, `mkcd`, `ll`) — bash-it sources every `$BASH_IT_CUSTOM/*.bash` |
| `bash/custom/themes/qode/qode.theme.bash` | the setup's own theme: `qode <cwd> (<branch>*) $` |
| `scripts/install.sh` | clones bash-it at a pinned tag, runs its `install.sh`, enables extra components |
| `scripts/check.sh` | **the job**: interactive bash with this rc file, checks the setup loaded |

Components: bash-it's `default` profile (enabled by its installer) plus the `git` plugin
and `git` aliases (enabled by `scripts/install.sh` with `bash-it enable`). Enable more
there. In the image `~/.bashrc` is a symlink to `bash/.bashrc`.

## Run it

**With docker** (what the fleet does):

    docker compose build
    docker compose run --rm app          # the check; exit 0 = setup loaded
    docker compose run --rm app bash     # try the shell itself

**Without docker** (needs bash 4+ and git; your `~/.bashrc` is left alone):

    BASH_IT="$PWD/.bash_it" bash scripts/install.sh   # = fleet.conf INSTALL_CMD
    BASH_IT="$PWD/.bash_it" bash scripts/check.sh
    BASH_IT="$PWD/.bash_it" bash --rcfile bash/.bashrc   # use it

## Origin

bash-it's documented install (its README), pinned to tag v3.2.0:

    git clone --depth=1 --branch v3.2.0 https://github.com/Bash-it/bash-it.git ~/.bash_it
    ~/.bash_it/install.sh --silent --no-modify-config
    bash-it enable plugin git && bash-it enable alias git

## Deviations from stock output, and why

- **`--no-modify-config`.** The default install backs up `~/.bashrc` and writes bash-it's
  template there; here the versioned `bash/.bashrc` is the rc file instead, and a local
  install never touches your dotfiles.
- `BASH_IT_CUSTOM` points at the repo's `bash/custom`, so the plugin and theme are
  versioned here rather than inside the bash-it checkout.
## Verified

**The docker image has NOT been built or run yet**: on 2026-10-05 the shared build host's docker disk was full (0-2 GB free for over 8 hours), so `docker compose build` was never attempted. Run `docker compose build && docker compose run --rm app` once before trusting it.

Without docker (2026-10-05, bash 5.2, throwaway `$HOME`): `scripts/install.sh` installed
bash-it v3.2.0 into `./.bash_it` and enabled the git plugin and aliases, and
`BASH_IT=$PWD/.bash_it bash scripts/check.sh` passed — bash-it, git plugin + aliases,
qode plugin and theme, prompt renders. `~/.bashrc` was not touched.


## Fleet lifecycle

`fleet.conf` drives every script in `bin/` (see `docs/fleet-lifecycle.md`). On the fleet
the docker runtime runs `DOCKER_BUILD_CMD` (`docker compose build`) and, because this is
a job and not a service, stops there: `DOCKER_START_CMD` is empty, the same as
`START_CMD`. Run the job itself with `docker compose run --rm app`.

    ./bin/run                    # docker runtime: builds the image, then stops (no server)
    docker compose run --rm app  # runs the job; exit code 0 = pass
    FLEET_RUNTIME=process ./bin/run   # no docker: runs INSTALL_CMD, then stops at start

`bin/run` ends with the template's own "no START_CMD" message — that is intentional.

## Serving over HTTP

Fleet apps are served at the root of their own hostname
(`https://<hash>.<FLEET_APP_DOMAIN>/`). **This repo has no HTTP surface**: `PORT`,
`HEALTH_PATH` and `START_CMD` are empty and `compose.yaml` publishes nothing. If you add
an HTTP endpoint, listen on `0.0.0.0:$PORT` (read at runtime), serve at `/`, set `PORT`,
`HEALTH_PATH`, `START_CMD` and `DOCKER_START_CMD='docker compose up --remove-orphans'`
in `fleet.conf`, and publish `"${PORT:-N}:${PORT:-N}"` in `compose.yaml`.

`compose.yaml` passes the fleet's variables (`DATABASE_URL`, `REDIS_URL`, `S3_*`,
`SMTP_*` …) through to the container without values; this template reads none of them.
