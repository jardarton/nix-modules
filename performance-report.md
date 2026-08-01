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

An initial experiment packaging Hunk directly with the consumer's `pkgs.callPackage` appeared to save approximately **0.7 seconds**. A follow-up benchmark after adoption did not reproduce a reliable evaluation improvement: four alternating before/after `padden` pairs with the evaluation cache disabled averaged **34.80 seconds before** and **35.18 seconds after**, while individual paired differences ranged from **2.52 seconds faster** to **2.31 seconds slower**. The expected effect is therefore smaller than the observed run-to-run noise.

The version-control feature retains the approach for architectural reasons: it contributes `packages.hunk` using the importing flake's package set and supplies that package to the Git and Jujutsu modules through `moduleWithSystem`. The AI, DevOps, Fsel, Gondolin, Mango, and reverse-engineering features now use the same pattern for their package contributions and module defaults. This removes consumer-flake aliases back to `nix-modules` package outputs and consolidates Kli with its owning DevOps feature.

The pattern can be applied incrementally to packages that still come from eager upstream flake outputs, but package ownership alone should not be assumed to produce a measurable evaluation improvement without a workload-specific benchmark.

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

### Standalone checks no longer require import from derivation

The Firefox integration now supplies Textfox's source tree directly to the upstream Home Manager module instead of making it read the equivalent package output during evaluation. Textfox's package only copies `chrome` and `user.js`; the source files were verified to match the built package output.

Fixing Textfox exposed a second IFD in the Stylix check: Stylix parsed a theme from the `pkgs.base16-schemes` package output during evaluation. The shared Stylix module now reads the theme from Stylix's pinned `tinted-schemes` source input instead. The configured `kanagawa.yaml` at the two pinned revisions was verified to be identical.

The complete standalone check now succeeds even when IFD is explicitly prohibited:

```console
nix flake check --no-build --option eval-cache false \
  --option allow-import-from-derivation false
```

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
3. Keep standalone checks IFD-free as upstream module interfaces evolve.
