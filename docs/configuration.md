# Configuration

## Strict mode

By default HyperHawk **never fails the workflow**. It reports problems as comments and annotations but always exits with a success code. This lets teams adopt it incrementally without blocking CI.

To fail the workflow on broken links, enable strict mode in one of two ways:

**Per-workflow input:**

```yaml
- uses: dvdstelt/hyperhawk@v1
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    strict: true
```

**Repository secret (recommended for gradual rollout):**

Go to **Settings > Secrets and variables > Actions** and create a secret named `LINK_CHECK_STRICT` with the value `true`. Then pass it in the workflow:

```yaml
- uses: dvdstelt/hyperhawk@v1
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    strict: ${{ secrets.LINK_CHECK_STRICT }}
```

This way you can enable strict mode for specific repositories without changing the workflow file. Repositories without the secret continue to run in non-strict mode.

## Ignore patterns

The `ignore-patterns` input accepts a comma-separated list of JavaScript regular expressions. Any link URL that matches at least one pattern is skipped.

```yaml
- uses: dvdstelt/hyperhawk@v1
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    ignore-patterns: 'localhost,example\.com,^https://internal\.'
```

Common use cases:

- Skip placeholder URLs: `example\.com`
- Skip links that require authentication: `^https://internal-wiki\.`
- Skip localhost references: `localhost`
- Skip a known flaky external site while keeping everything else: `flaky-site\.io`

## Scanning scope

| Trigger | Files scanned |
|---------|--------------|
| `pull_request` | Only `.md` and `.mdx` files changed by the PR |
| `push` | All `.md` and `.mdx` files in the repository |
| `schedule` | All `.md` and `.mdx` files in the repository |

On pull requests, only changed files are scanned. Broken links in files that are not part of the diff are reported as check annotations rather than inline comments.

The following directories are always excluded from scanning: `node_modules/`, `.git/`, `dist/`, `lib/`.

## Skip code blocks

By default, links inside fenced code blocks are checked like any other link. If your code blocks contain example URLs or configuration snippets that should not be validated, enable `skip-code-blocks`:

```yaml
- uses: dvdstelt/hyperhawk@v1
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    skip-code-blocks: true
```

When enabled, any content between `` ``` `` or `~~~` fences is skipped during link extraction.

## Report only changed lines

By default, broken links found on unchanged lines in a PR produce check warning annotations. To suppress these and only report issues on lines you actually changed, enable `report-only-changed`:

```yaml
- uses: dvdstelt/hyperhawk@v1
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    report-only-changed: true
```

This is useful for incremental adoption: you get feedback only on lines in the diff, without noise from pre-existing broken links elsewhere in the file.
