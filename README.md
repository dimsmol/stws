# simple static web server

Serves static files from the current or given directory.

See `stws -h` for usage.

It's a Nix flake and can be ran or installed as such, see `nix shell --help` for running.

# dev commands

- `nix build` - build via nix (non-incremental)
- `nix run` - run via nix
- `nix develop` - open dev shell, inside:
  - `cabal build` - build (incremental)
  - `cabal run` - run
    - also `./run`
  - rebuild everything:
    - `cabal clean && cabal build all`
