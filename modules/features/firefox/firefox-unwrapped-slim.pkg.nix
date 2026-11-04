# nixpkgs' unwrapped Firefox without files it never uses. Firefox itself still
# comes from the binary cache: this copies it and edits the copy, compiling
# nothing. Wrap it with wrapFirefox, as nixpkgs does, so that Home Manager can
# still override the wrapper.
{
  binutils-unwrapped,
  firefox-unwrapped,
  removeReferencesTo,
  runCommand,
}:
let
  inherit (builtins) storeDir;
in
runCommand firefox-unwrapped.name
  {
    nativeBuildInputs = [
      binutils-unwrapped
      removeReferencesTo
    ];
    disallowedReferences = [ firefox-unwrapped ];
    inherit (firefox-unwrapped) passthru meta;
  }
  ''
    cp -a ${firefox-unwrapped} $out
    chmod -R u+w $out

    # The launcher names the original package. Point it at this copy; both
    # hashes have the same length, so binaries stay intact.
    original=$(basename ${firefox-unwrapped})
    original=''${original%%-*}
    copy=$(basename $out)
    copy=''${copy%%-*}
    grep -rlZ --binary-files=binary "$original" $out | xargs -0 -r sed -i "s|$original|$copy|g"

    # Firefox ships its own copy of ONNX Runtime, which embeds the original
    # library's path as a fallback for loading execution providers. That
    # path alone keeps ONNX Runtime and its 165 MiB OpenVINO provider in
    # the closure. Firefox only uses the built-in CPU provider.
    grep -rlE --binary-files=binary "${storeDir}/[a-z0-9]{32}-onnxruntime-" $out | while read -r file; do
      grep -aoE "${storeDir}/[a-z0-9]{32}-onnxruntime-[^/]+" "$file" | sort -u | while read -r path; do
        remove-references-to -t "$path" "$file"
      done
    done

    # nixpkgs strips only debug sections. Mozilla's own builds also drop the
    # symbol tables, about 60 MiB, which only the profiler uses locally.
    find $out -path '*/gmp-clearkey' -prune -o -type f -print | while read -r file; do
      if [ "$(head -c 4 "$file")" = "$(printf '\177ELF')" ]; then
        strip --strip-unneeded "$file"
      fi
    done
  ''
