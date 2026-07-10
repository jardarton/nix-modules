# Maintenance

Recurring maintenance tasks for this repository.

## Update Home Assistant stack container images

**Frequency:** Monthly, and promptly for relevant security releases.

The default images in `modules/nixos/home-assistant/default.nix` are pinned to multi-platform manifest digests. Resolve the current upstream tags and replace the corresponding digests:

```sh
docker buildx imagetools inspect ghcr.io/home-assistant/home-assistant:stable
docker buildx imagetools inspect ghcr.io/koenkk/zigbee2mqtt:latest
docker buildx imagetools inspect eclipse-mosquitto:latest
```

Use the top-level `Digest:` value from each command. Keep the image references in the form:

```text
registry/repository@sha256:<multi-platform-manifest-digest>
```

After updating:

1. Review upstream release notes for breaking changes.
2. Run the repository checks:

   ```sh
   nix flake check --no-build --show-trace
   ```

3. Evaluate a representative downstream NixOS configuration against the local checkout by overriding its `nix-modules` input.
4. Deploy to a test host and verify Home Assistant, Zigbee2MQTT, and Mosquitto before publishing the update.
