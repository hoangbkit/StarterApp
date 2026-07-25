# Developing StarterApp without breaking `mycli`

StarterApp has two layers that should evolve independently:

1. **App implementation:** SwiftUI views, AppFoundation integration, onboarding, settings, paywall, assets, tests, and CI.
2. **Bootstrap contract:** `template.yml` plus the validation and transformation assumptions used by `mycli new ios`.

Most feature development changes only the app implementation and is safe. Contract changes require coordinated work in both repositories.

## Branch and tag policy

Use `master` as the actively developed template. The stable `mycli` command uses an immutable StarterApp tag, currently `0.1.0`, so ordinary changes on `master` do not affect users of the pinned tag.

Never force-update or delete a published template tag.

Recommended flow:

1. Develop and validate on a StarterApp feature branch.
2. Merge compatible work into `master`.
3. Create a new immutable tag after compatibility testing.
4. Update `mycli`'s default template ref only after that tag passes bootstrap testing.

## Changes that are normally safe

These changes can usually be developed freely:

- adding or updating Swift files inside the app, unit-test, or UI-test directories;
- changing onboarding, settings, paywall, theme, sample content, and navigation;
- updating AppFoundation and other package versions;
- adding assets, strings, privacy declarations, StoreKit products, tests, scripts, or workflows;
- adding new feature names to `features.included` or `features.optional`;
- adding project settings while keeping `project.yml` and `template.yml` synchronized.

`mycli` copies the full template. A feature is not removed merely because it is not specially understood by the CLI.

## Bootstrap contract

Treat these parts as the public compatibility API between StarterApp and `mycli`:

- `schemaVersion`;
- `identity`;
- `configurationSurfaces`;
- `rename.directories`;
- `rename.files`;
- `rename.generatedPaths`;
- `validation.requiredFiles`;
- `validation.identitySurfaces`;
- `scripts/validate-bootstrap.sh`.

Do not rename, remove, or change the meaning of these fields casually.

When adding a file that contains `StarterApp`, `com.hoangbkit.starterapp`, the development team, product identifiers, or placeholder legal URLs, ensure the file is covered by `configurationSurfaces` or `validation.identitySurfaces` so bootstrap rewrites it.

When a resource filename itself contains `StarterApp`, keep the filename and all references aligned. App-icon and asset-catalog filenames are a common example.

## Local compatibility test

Test a StarterApp branch directly against the currently installed `mycli`; no tag is required.

From the StarterApp checkout:

```bash
make validate-template
make generate
make build
make test
```

Then bootstrap a separate app from the local checkout:

```bash
rm -rf ~/Developer/tmp/StarterCompat

mycli new ios StarterCompat \
  --bundle-id com.hoangbkit.startercompat \
  --template-path "$PWD" \
  --destination ~/Developer/tmp/StarterCompat \
  --no-git \
  --yes
```

Validate the generated app on macOS:

```bash
cd ~/Developer/tmp/StarterCompat
make generate
make build
```

A device deployment provides the strongest final check:

```bash
mycli deploy se2
```

The compatibility test should confirm that the generated project still includes all intended features: onboarding, settings, paywall, themes, StoreKit configuration, privacy manifest, strings, assets, tests, GitHub Actions, and Xcode Cloud scripts.

## Adding a new feature

For a normal additive feature:

1. Add all source and resource files.
2. Update `project.yml` when new targets, resources, packages, entitlements, or build settings are required.
3. Add the feature to `features.included` or `features.optional` in `template.yml`.
4. Add any new required files to `validation.requiredFiles`.
5. Add identity-bearing paths to `configurationSurfaces` or `validation.identitySurfaces`.
6. Run the local compatibility test.

Prefer additive manifest changes. Older CLI versions can safely ignore fields they do not need.

## Making a breaking contract change

Examples of breaking changes include:

- renaming `identity` to a different section;
- changing the meaning or shape of an existing manifest field;
- removing `template.yml` or `scripts/validate-bootstrap.sh`;
- moving required files without updating the manifest and validator;
- increasing `schemaVersion` when the current CLI only supports the previous version.

For a breaking change:

1. Update `mycli` first so it supports both the current and proposed contract when practical.
2. Test `mycli` against the current stable StarterApp tag.
3. Test the same CLI against the new StarterApp branch.
4. Increment `schemaVersion` only when backward compatibility is not practical.
5. Tag StarterApp after both paths pass.
6. Update the default template ref in `mycli` last.

## Versioning guideline

- `0.1.x`: fixes and small additive changes;
- `0.2.0`, `0.3.0`, and similar: meaningful compatible template feature additions;
- `1.0.0`: stable bootstrap contract;
- next major version: intentionally incompatible manifest or bootstrap contract.

## Release checklist

Before publishing a new StarterApp tag:

- [ ] `make validate-template` passes.
- [ ] StarterApp generates and builds directly.
- [ ] Unit tests pass.
- [ ] `mycli new ios --template-path ...` succeeds.
- [ ] The generated app generates and builds.
- [ ] No intended feature or resource is missing.
- [ ] App-icon and asset references have no unassigned-child warnings.
- [ ] The current stable tag still works with the updated CLI.
- [ ] The new tag has not previously been published or rewritten.
