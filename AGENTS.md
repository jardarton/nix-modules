# Agent instructions

## Target architecture: dendritic Nix

This repository is migrating toward the [dendritic pattern](https://github.com/mightyiam/dendritic). Treat dendritic organization as the target for new architecture and substantial refactors, not as a claim that all existing code already follows it. Do not perform unrelated mass migrations.

### Architectural rules

- Except for entry points such as `flake.nix` and `default.nix`, ordinary Nix files should become modules of the top-level flake-parts configuration.
- Organize modules by feature rather than by configuration class. One feature module may contribute to NixOS, Home Manager, packages, checks, and exported flake modules.
- Store lower-level modules in declared top-level options. Use `lib.types.deferredModule` or an appropriate equivalent so definitions from multiple feature files can merge.
- Let multiple feature files merge into a small set of meaningful lower-level modules. Avoid creating a separately named lower-level module for every implementation detail.
- Share functions, packages, constants, and module values through declared top-level `config` options instead of adding new `importApply`, `specialArgs`, or `extraSpecialArgs` pass-through chains.
- Prefer automatic importing of top-level feature modules. Explicitly exclude entry points and non-module expressions from automatic imports.
- Importing a feature should normally enable the behavior it provides. Avoid adding new `enable` options merely because all modules are imported. Do not remove or change existing public options incidentally.
- Reasonable exceptions are allowed. Name standalone package expressions clearly, for example `*.pkg.nix`, and keep them outside automatic module imports.

### Repository role

- `nix-modules` is the public, reusable foundation consumed heavily by `~/repos/nixconfig`.
- Keep host names, LAN topology, credentials, personal data, and private policy out of this repository.
- Provide the shared top-level option schema and reusable feature implementations needed by consumer flakes.
- Preserve useful public outputs such as `nixosModules` and `homeModules` while migrating internals, unless an explicit breaking change is requested.
- Keep migrations incremental and validate both standalone checks and representative consumption from `nixconfig`.

## Override-friendly reusable modules

- Declare typed options with useful descriptions.
- Prefer defaults that consumers can override.
- Avoid `lib.mkForce` in reusable modules unless correctness requires it and the reason is documented.
- Preserve existing option names and semantics unless an intentional migration is requested.
