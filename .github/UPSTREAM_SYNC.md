# Upstream Sync Workflow

This repository includes an automated GitHub Actions workflow that keeps it synchronized with the upstream repository: [The-Pocket/PocketFlow-Tutorial-Codebase-Knowledge](https://github.com/The-Pocket/PocketFlow-Tutorial-Codebase-Knowledge).

## How It Works

The workflow automatically:

1. **Runs daily** at 2 AM UTC to check for upstream changes
2. **Fetches** the latest commits from upstream
3. **Merges** changes into the fork (default strategy)
4. **Pushes** the synced changes back to this repository
5. **Creates an issue** if conflicts are detected that require manual resolution

## Manual Triggering

You can manually trigger the sync workflow:

1. Go to the **Actions** tab in this repository
2. Select **"Sync with Upstream"** workflow
3. Click **"Run workflow"**
4. Choose a sync strategy:
   - **merge** (default): Creates a merge commit
   - **rebase**: Rebases your commits onto upstream changes

## Sync Strategies

### Merge Strategy (Default)
- Creates a merge commit when syncing
- Preserves the complete history
- Safer for repositories with custom changes
- Recommended for most use cases

```bash
git merge upstream/main --no-edit
```

### Rebase Strategy
- Replays your commits on top of upstream
- Creates a linear history
- May require force-push
- Use with caution if you have custom branches

```bash
git rebase upstream/main
```

## Handling Conflicts

If the automated sync encounters conflicts:

1. **An issue will be created** automatically with the label `upstream-sync`
2. The issue contains instructions for manual resolution
3. Follow the steps in the issue to resolve conflicts locally
4. Close the issue after resolving

### Manual Conflict Resolution

```bash
# Clone the repository
git clone https://github.com/lessuselesss/PocketFlow-KB-flake.git
cd PocketFlow-KB-flake

# Add upstream remote
git remote add upstream https://github.com/The-Pocket/PocketFlow-Tutorial-Codebase-Knowledge.git

# Fetch latest changes
git fetch upstream
git fetch origin

# Attempt to merge (or rebase)
git merge upstream/main
# OR
# git rebase upstream/main

# If conflicts occur, resolve them manually
# Edit conflicting files, then:
git add .
git commit -m "Resolve merge conflicts with upstream"
git push origin main
```

## Customizing the Workflow

### Change Sync Frequency

Edit `.github/workflows/sync-upstream.yml`:

```yaml
on:
  schedule:
    # Run every 6 hours
    - cron: '0 */6 * * *'

    # Run every Monday at 9 AM
    - cron: '0 9 * * 1'

    # Run on the 1st of every month
    - cron: '0 0 1 * *'
```

### Change Default Strategy

Edit the workflow file to use rebase by default:

```yaml
workflow_dispatch:
  inputs:
    sync_strategy:
      description: 'Sync strategy (merge or rebase)'
      required: false
      default: 'rebase'  # Changed from 'merge'
```

### Disable Automatic Syncing

To disable automatic syncing but keep manual triggering:

1. Edit `.github/workflows/sync-upstream.yml`
2. Remove or comment out the `schedule:` section:
   ```yaml
   on:
     # schedule:
     #   - cron: '0 2 * * *'
     workflow_dispatch:
       # ... rest of config
   ```

## Monitoring Sync Status

### View Workflow Runs

1. Go to the **Actions** tab
2. Select **"Sync with Upstream"**
3. View the run history and logs

### Check Sync Summary

Each workflow run creates a summary showing:
- ✅ Number of commits synced
- ⚠️ Conflict status
- 📝 Strategy used

### Get Notifications

To receive notifications about sync issues:

1. Go to **Settings** → **Notifications**
2. Enable **Actions** notifications
3. You'll be notified when conflicts occur

## FAQ

### Q: Will this overwrite my custom changes?

**A:** No. The workflow uses merge/rebase strategies that preserve your custom changes. If there are conflicts with your changes, the workflow will stop and create an issue for manual resolution.

### Q: What about the flake.nix and custom files?

**A:** Your custom files (like `flake.nix`, `FLAKE_USAGE.md`) are safe. If upstream adds changes that conflict with these files, you'll get a conflict notification to resolve manually.

### Q: Can I pause syncing temporarily?

**A:** Yes. You can disable the workflow by:
1. Going to **Actions** → **Sync with Upstream**
2. Click the **"..."** menu → **Disable workflow**

### Q: How do I know if sync succeeded?

**A:** Check:
1. The **Actions** tab for recent successful runs
2. Your commit history for automated merge commits
3. No open issues with the `upstream-sync` label

### Q: What if I want to sync a specific branch?

**A:** The workflow syncs the default branch. For custom branches, you'll need to modify the workflow or sync manually using the commands in the conflict resolution section.

## Troubleshooting

### Workflow Not Running

- Ensure **Actions** are enabled in repository settings
- Check that you have proper permissions (write access)
- Verify the workflow file syntax is correct

### Persistent Conflicts

If you keep getting conflicts:

1. Consider diverging from upstream intentionally
2. Disable automatic syncing
3. Sync manually when ready to integrate upstream changes
4. Use `git cherry-pick` to selectively apply upstream commits

### Failed Pushes

If pushes fail after sync:

- Ensure the GitHub token has write permissions
- Check if branch protection rules are blocking the push
- Verify network connectivity and GitHub status

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Working with Forks](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks)
- [Syncing a Fork](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/syncing-a-fork)
