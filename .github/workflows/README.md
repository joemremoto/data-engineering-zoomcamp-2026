# GitHub Workflows

This directory contains GitHub Actions workflows for automating repository tasks.

## Workflows

### 1. Auto Approve PRs (`auto-approve.yml`)

**Purpose:** Automatically approves pull requests from trusted authors.

**Triggers:** When a PR is opened, synchronized, or reopened

**Trusted Authors:**
- `joemremoto` (personal account)
- `JosephRemotoGit` (work account)

**What it does:**
1. ✅ Automatically approves the PR
2. 💬 Adds a comment indicating auto-approval

**Permissions required:**
- `pull-requests: write` - To approve PRs
- `contents: read` - To read repository content

---

### 2. Auto Merge PRs (`auto-merge.yml`)

**Purpose:** Automatically merges approved pull requests from trusted authors.

**Triggers:** 
- When a PR is opened, synchronized, or reopened
- When a PR review is submitted

**Trusted Authors:**
- `joemremoto` (personal account)
- `JosephRemotoGit` (work account)

**What it does:**
1. 🔀 Enables auto-merge for the PR (squash merge)
2. Merges automatically once all checks pass

**Permissions required:**
- `pull-requests: write` - To enable auto-merge
- `contents: write` - To merge PRs

---

## Setup Instructions

### Prerequisites

These workflows use the default `GITHUB_TOKEN`, so no additional setup is required!

### Enable Branch Protection (Optional but Recommended)

To make auto-merge work properly:

1. Go to **Settings** → **Branches**
2. Click **Add rule** for your main branch (e.g., `master` or `main`)
3. Configure:
   - ☑️ Require a pull request before merging
   - ☑️ Require approvals: 1
   - ☑️ Allow specified actors to bypass required pull requests (add yourself)

### Testing the Workflows

1. **Create a test branch:**
   ```bash
   git checkout -b test-auto-approve
   echo "test" > test.txt
   git add test.txt
   git commit -m "Test auto-approve workflow"
   git push origin test-auto-approve
   ```

2. **Create a PR:**
   - Go to GitHub and create a pull request from `test-auto-approve` to `master`

3. **Watch the magic:**
   - The workflow will automatically approve your PR
   - (Optional) If auto-merge is enabled, it will merge automatically

---

## Workflow Behavior

### Scenario 1: You Create a PR from `joemremoto` account
```
PR Created → Auto-Approve Workflow Runs → PR Approved ✅ → Comment Added
         → Auto-Merge Workflow Runs → Auto-merge Enabled 🔀
         → (When checks pass) → PR Merged Automatically
```

### Scenario 2: You Create a PR from `JosephRemotoGit` account
```
Same as Scenario 1 - trusted author
```

### Scenario 3: Someone Else Creates a PR
```
PR Created → Workflows Don't Run (not a trusted author)
          → Manual review required
```

---

## Customization

### Add More Trusted Authors

Edit the workflow files and add more usernames:

```yaml
if: |
  github.event.pull_request.user.login == 'joemremoto' ||
  github.event.pull_request.user.login == 'JosephRemotoGit' ||
  github.event.pull_request.user.login == 'another-username'
```

### Change Merge Strategy

In `auto-merge.yml`, you can change the merge strategy:

```bash
# Squash merge (default - recommended)
gh pr merge --auto --squash "$PR_URL"

# Merge commit
gh pr merge --auto --merge "$PR_URL"

# Rebase
gh pr merge --auto --rebase "$PR_URL"
```

### Disable Auto-Merge

If you only want auto-approval without auto-merge:
- Delete or disable `auto-merge.yml`
- Keep only `auto-approve.yml`

---

## Troubleshooting

### Workflow doesn't run

**Check:**
1. Are you logged in as `joemremoto` or `JosephRemotoGit`?
2. Is the workflow file committed to the `master`/`main` branch?
3. Check the Actions tab for errors

### Auto-merge doesn't work

**Possible causes:**
1. Branch protection requires checks to pass
2. Repository doesn't have "Allow auto-merge" enabled
   - Go to **Settings** → **General** → **Pull Requests**
   - ☑️ Enable "Allow auto-merge"

### Workflow runs but fails

**Check the logs:**
1. Go to **Actions** tab
2. Click on the failed workflow
3. Review the error message

**Common issues:**
- Insufficient permissions (check workflow `permissions` section)
- Branch protection rules blocking the action
- API rate limits (rare)

---

## Security Considerations

### Why `pull_request_target`?

We use `pull_request_target` instead of `pull_request` because:
- ✅ Has write permissions to approve/merge
- ✅ Runs in the context of the base repository
- ⚠️ **Important:** Only runs for trusted authors (security)

### Safety Features

1. **Explicit author check:** Only whitelisted usernames can trigger auto-actions
2. **Read-only by default:** Most permissions are minimal
3. **Uses `GITHUB_TOKEN`:** No need to create personal access tokens

---

## Workflow Files

### File Locations

```
.github/
└── workflows/
    ├── auto-approve.yml    # Auto-approves PRs
    ├── auto-merge.yml      # Auto-merges PRs
    └── README.md           # This file
```

### Required Files

Both workflows are independent:
- Want **only auto-approval**? Keep `auto-approve.yml`, delete `auto-merge.yml`
- Want **both**? Keep both files
- Want **neither**? Delete both or disable in repository settings

---

## Example Workflow Run

```
🔔 PR #5 opened by joemremoto
├── ⚙️ Running: Auto Approve PRs from Trusted Authors
│   ├── ✅ Checking author: joemremoto (trusted)
│   ├── ✅ Approving PR
│   └── 💬 Adding comment: "✅ Auto-approved by workflow (trusted author)"
│
├── ⚙️ Running: Auto Merge PRs from Trusted Authors  
│   ├── ✅ Checking author: joemremoto (trusted)
│   └── 🔀 Enabling auto-merge (squash)
│
└── ✅ PR #5 will auto-merge when checks pass
```

---

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [auto-approve-action](https://github.com/hmarr/auto-approve-action)
- [GitHub Script Action](https://github.com/actions/github-script)
- [Branch Protection Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)

---

## Questions?

If you need to modify these workflows, refer to:
- [GitHub Actions Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Workflow Events](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows)
