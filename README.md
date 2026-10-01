# mobilizon-patched

[Mobilizon](https://framagit.org/kaihuri/mobilizon) with a few small patches, rebuilt from upstream releases.

This repository holds no copy of the Mobilizon sources. The [build workflow](.github/workflows/build.yaml) checks out an upstream release tag, applies [`patches/*.patch`](patches) in order, builds it with upstream's own `docker/production/Dockerfile` (amd64 and arm64), and publishes:

```
ghcr.io/rumblebump/mobilizon-patched:<version>             # e.g. 5.2.4, moves when the patches change
ghcr.io/rumblebump/mobilizon-patched:<version>-p<patchset> # e.g. 5.2.4-p1a2b3c4, fixed
ghcr.io/rumblebump/mobilizon-patched:latest
```

It runs every Monday and on every push to `main`. It only builds when no image exists yet for the newest upstream release and the current patch set, so a new upstream release or a patch change produces a new image. Run it by hand (Actions → build → Run workflow) to build a specific upstream tag or to force a rebuild. Pull requests build the image without pushing it, so a patch that no longer applies or compiles fails there.

## Patches

| Patch | What it does |
| --- | --- |
| `0001-restrict-profiles` | Adds `MOBILIZON_INSTANCE_RESTRICT_PROFILES` (default `false`, read at boot). When `true`, every account (local, LDAP or OAuth/OIDC login) can create one profile, chosen at first login. A second `createPerson` fails with "You can only have one profile", and the "New profile" settings entry is hidden once the account has one. Administrators can still create more. Without the variable the image behaves like upstream. Outside Docker, set `config :mobilizon, :instance, restrict_profiles: true`. |

## Working on a patch

```sh
scripts/prepare.sh 5.2.4 /tmp/mobilizon     # upstream tag with the current patches applied
cd /tmp/mobilizon && git add -A && git commit -qm base
# edit, then
git diff > /path/to/mobilizon-patched/patches/0002-my-change.patch
```

When upstream changes the same lines, the workflow fails at "Apply patches" instead of building. Refresh the patch against the new tag.

## License

Mobilizon is AGPL-3.0, and so are these patches. The image labels point back to this repository, which is the source of the modified version.
