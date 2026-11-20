# CalVer Action

A GitHub Action that calculates the next [CalVer](https://calver.org/) version (`YYYY.MM.PATCH`) of your repository based on its latest GitHub release, and exposes the new version and tag for use in later steps.

## Usage

```yaml
name: Release
on:
  push:
    branches:
      - main

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v6

      - name: Calculate next version
        id: calver
        uses: cdqag/action-calver@v2
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          prerelease: 'false'

      - name: Create release
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          gh release create "${{ steps.calver.outputs.new-tag }}" --generate-notes
```

## Inputs

| Input | Description | Required |
|-------|-------------|----------|
| `github-token` | GitHub token used to list the repository releases | ✅ |
| `prerelease` | If set to `true`, the `-pre-release` suffix is appended to the new version | ❌ (default: `false`) |

## Outputs

| Output | Description |
|--------|-------------|
| `latest-release-tag` | Latest release tag found in the repository (`v0.0.0` if there is none) |
| `current-version` | Current version, i.e. the latest release tag without the `v` prefix |
| `new-version` | Newly calculated version (e.g. `2026.11.0`) |
| `new-tag` | Newly calculated tag (e.g. `v2026.11.0`) |

## How It Works

1. **Find latest release**: Uses `gh release list` to get the most recent release tag. If the repository has no releases, `v0.0.0` is used.
2. **Strip prefix**: Removes the leading `v` from the tag to get the current version.
3. **Compare date part**: Takes the current year and month (`YYYY.MM`) and compares it with the beginning of the current version.
4. **Calculate version**:
   - Same year and month → the patch number is incremented (`2026.11.0` → `2026.11.1`).
   - Different year or month → a new version starts with patch `0` (`2026.10.5` → `2026.11.0`).
5. **Pre-release**: If `prerelease` is `true`, the suffix `-pre-release` is appended to the version.
6. **Expose results**: Sets the new version and the new tag (`v` + version) as step outputs.

> [!NOTE]
> The action only calculates the version. It does not create a tag or a release.

## Permissions

The token passed in `github-token` needs read access to releases:

```yaml
permissions:
  contents: read
```

Creating the release afterwards (as in the example above) requires `contents: write`.

The runner must have the `gh` CLI and `jq` available (both are preinstalled on GitHub-hosted runners).

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Use [Conventional Commits](https://www.conventionalcommits.org/) for commit messages
5. Submit a pull request

## About Creator

![CDQ Logo](https://www.cdq.com/themes/custom/gavias_nonid/logo.svg)

This action has been created and is maintained by [CDQ - Data Quality Solutions &amp; Services for Master Data](https://www.cdq.com/).

It is based on [energostack/calver-action](https://github.com/energostack/calver-action).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
