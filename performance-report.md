# Flake performance report

The flake's own source is already small. The meaningful opportunities are reducing its transitive input graph and simplifying evaluation structure.

## Baseline observations

- Repository source in the Nix store: approximately **504 KiB**.
- Standalone lock graph: **55 nodes**, with a 28,122-byte `flake.lock`.
- The consumer `nixconfig` lock graph contains **99 nodes**.
- A representative uncached evaluation of `nixconfig`'s `padden` system took approximately **30.11 seconds**.
- `nix flake check --no-build` took approximately **82.23 seconds**.

The repository archive itself is therefore not a significant concern. Transitive flake inputs, repeated package-set evaluation, and the check structure are more important.

## Recommended changes

### 1. Avoid consuming packages through eager upstream flake outputs

Several modules obtain packages through expressions such as:

```nix
localFlake.inputs.hunk.packages.${system}.default
```

Following the same nixpkgs revision does not guarantee reuse of the same evaluated package set. Each upstream flake may independently import nixpkgs, and some flakes construct outputs eagerly.

Hunk is a concrete example: its flake builds a per-system attrset in a way that can force nixpkgs evaluation for systems other than the one being consumed.

An experiment packaging Hunk directly with the consumer's `pkgs.callPackage` saved approximately another **0.7 seconds** in a paired `padden` benchmark. The version-control feature now applies this approach: it contributes `packages.hunk` using the importing flake's package set and supplies that package to the Git and Jujutsu modules through `moduleWithSystem`.

The same dendritic approach can be applied incrementally to other features that still consume eager upstream package outputs. Imported feature modules should contribute package definitions using the consuming flake's package set, then reference those packages from lower-level module defaults instead of forcing a second evaluation of `nix-modules` or an upstream package flake.

### 2. Reduce the cost of exhaustive Home Manager checks

The current `checks` output creates a separate `homeManagerConfiguration` for every exported Home Manager module. There are roughly 45 such evaluations, and:

```console
nix flake check --option eval-cache false --no-build
```

took approximately **82.23 seconds**.

This primarily affects maintainers running `nix flake check` or inspecting the entire flake. It does not have the same impact on targeted consumer configuration evaluation.

Possible approaches:

- Keep representative profile or feature-combination checks under `checks`.
- Move exhaustive standalone-module evaluation to a CI-specific output or `hydraJobs`.
- Test meaningful combinations instead of evaluating every module through a separate complete Home Manager configuration.

Any change should retain coverage for module option errors and package evaluation rather than replacing the current checks with syntax-only tests.

## Secondary observations

### Textfox uses import from derivation

The Firefox/Textfox integration reads generated files from a package output during module evaluation. This causes import-from-derivation behavior and leads Nix to omit related checks when IFD is unavailable.

Removing Textfox did not measurably improve an already-warm `padden` evaluation, but avoiding IFD would still improve cold-evaluation behavior, reliability, and compatibility with evaluators that prohibit IFD. A proper fix likely requires generating the configuration without reading a derivation output during evaluation or changing the upstream Textfox interface.

### Share the pre-commit input in `nixconfig`

Both repositories currently lock the same `pre-commit-hooks` revision under separate nodes. The consumer can add:

```nix
nix-modules.inputs.pre-commit-hooks.follows = "pre-commit-hooks";
```

This is a small lock-graph cleanup because `nixconfig` already has its own direct pre-commit input.

### Source-file size is not worth optimizing

The complete `nix-modules` source is only approximately 504 KiB in the Nix store. Large-looking repository files such as Firefox configuration and `package-lock.json` are insignificant compared with transitive inputs and nixpkgs sources. Splitting or filtering the repository source is unlikely to produce a noticeable benefit.

## Suggested order of work

1. Continue refactoring package contributions toward consumer-owned package sets as part of the dendritic migration.
2. Redesign exhaustive Home Manager checks if maintainer evaluation time remains a concern.
3. Address Textfox IFD separately as an evaluation-reliability improvement.
