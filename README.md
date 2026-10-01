# mobilizon-patched

[Mobilizon](https://framagit.org/kaihuri/mobilizon) with a few small patches, rebuilt from upstream releases.

This repository holds no copy of the Mobilizon sources. The [build workflow](.github/workflows/build.yaml) checks out an upstream release tag, applies [`patches/*.patch`](patches) in order, builds it with upstream's own `docker/production/Dockerfile` (amd64 and arm64), and publishes:

```
ghcr.io/rumblebump/mobilizon-patched:<version>             # e.g. 5.2.4, moves when the patches change
ghcr.io/rumblebump/mobilizon-patched:<version>-p<patchset> # e.g. 5.2.4-p1a2b3c4, fixed
ghcr.io/rumblebump/mobilizon-patched:latest
```

It runs every Monday and on every push to `main`. It only builds when no image exists yet for the newest upstream release and the current patch set, so a new upstream release or a patch change produces a new image. Run it by hand (Actions → build → Run workflow) to build a specific upstream tag or to force a rebuild. Pull requests build the image without pushing it, so a patch that no longer applies or compiles fails there.

To try a branch before merging, run the workflow by hand on that branch. It publishes only `ghcr.io/rumblebump/mobilizon-patched:dev`, overwriting the previous dev build, and leaves the release tags alone.

## Patches

`patches/0001-profiles.patch` adds two opt-in settings. Both are read from the environment at boot, default to `false`, and don't apply to administrators. Without them the image behaves like upstream.

| Variable | Effect |
| --- | --- |
| `MOBILIZON_INSTANCE_RESTRICT_PROFILES=true` | Every account (local, LDAP or OAuth/OIDC login) can create one profile, chosen at first login. A second `createPerson` fails with "You can only have one profile", and the "New profile" settings entry is hidden. |
| `MOBILIZON_INSTANCE_LOCK_PROFILES=true` | The profile is created automatically on the first login. Its username **and** display name are the part of the account email before the `@`: lowercased, with every character other than `a-z`, `0-9` and `_` replaced by `_` (`John.Doe@example.org` becomes `john_doe`). The display name can't be edited and is reset to the username on every login, so nobody can pose as someone else. A local signup whose username is already taken is refused; an LDAP or OAuth login whose username is taken fails. This also limits accounts to one profile. |

Outside Docker, set `config :mobilizon, :instance, restrict_profiles: true` or `lock_profiles: true`.

The patch also fixes generic OpenID Connect login (`ueberauth_oidcc`): the auth controller now fetches cookies, so the OIDC state cookie can be read on the callback instead of crashing with "cannot fetch key … from conn.cookies because they were not fetched".

The patch also makes the Docker build use `npm ci` with upstream's `package-lock.json` (which `.dockerignore` excluded), because `npm install` re-resolves the dependency tree and currently fails.

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
