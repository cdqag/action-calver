# calver-action

Super simple GitHub Action to generate a [CalVer](https://calver.org/) version based on the current date.

CalVer is in defualt in format `vYYYY.MM.PATCH` and can be changed by setting the `date_format` input.

Checkout action have to fetch tags by (`fetch-tags: true`) to get the latest tag and work this action properly.

## Example usage

This release job will generate a CalVer version and use this next version to:

- Docker build
- Docker push
- Push a tag
- Create a GitHub release

If the workflow is triggered by a `workflow_dispatch` event, the version will be a pre-release.

```yaml
name: Release

on:
  pull_request:
    types:
      - closed
    branch:
      - master
      - main

  workflow_dispatch:

jobs:
    release:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 1
          fetch-tags: true

      - name: CalVer
        id: calver
        run: energostack/calver-action@v1
        with:
          prerelease=${{ github.event_name == 'workflow_dispatch' }}

      - name: Docker build
        run: docker build -t my-image:${{ steps.calver.outputs.next_version }} .

      - name: Docker push
        run: docker push my-image:${{ steps.calver.outputs.next_version }}

      - uses: thejeff77/action-push-tag@v1
        with:
          tag: ${{ steps.calver.outputs.next_version }}
          message: '"${{ steps.calver.outputs.next_version }}: PR #${{ github.event.pull_request.number }} - ${{ github.event.pull_request.title }}"'

      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          tag_name: ${{ steps.calver.outputs.next_version }}
          generate_release_notes: true
          prerelease: ${{ github.event_name == 'workflow_dispatch' }}
```
