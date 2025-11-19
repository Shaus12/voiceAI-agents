# Cursor Collaboration Guide

## 🎯 Working Together with Cursor

This guide explains how to collaborate effectively when both partners are using Cursor IDE.

---

## 🔄 How Cursor Works with Git

Cursor is built on VS Code and works seamlessly with Git. Here's how to collaborate:

### Basic Workflow

1. **Both of you work on the same repository**
2. **Use Git branches** to avoid conflicts
3. **Cursor will show you changes** from your partner
4. **Cursor's AI can help** with code reviews and suggestions

---

## 📋 Step-by-Step Collaboration Process

### Initial Setup (Do This Once)

#### 1. Clone the Repository

```bash
# Partner 1: If you already have it, skip this
git clone <repository-url>
cd voiceAI-agents

# Partner 2: Clone the repository
git clone <repository-url>
cd voiceAI-agents
```

#### 2. Set Up Remote Tracking

```bash
# Both partners: Make sure you're tracking the same remote
git remote -v  # Should show your GitHub/GitLab URL

# If not set up:
git remote add origin <repository-url>
```

#### 3. Create Develop Branch

```bash
# Partner 1: Create and push develop branch
git checkout -b develop
git push -u origin develop

# Partner 2: Fetch and checkout develop
git fetch origin
git checkout develop
```

---

## 🔀 Daily Workflow

### Before Starting Work (Every Day)

```bash
# 1. Check what branch you're on
git branch

# 2. Switch to develop
git checkout develop

# 3. Pull latest changes from your partner
git pull origin develop

# 4. Check what your partner changed
git log --oneline -5  # See last 5 commits
```

### Starting a New Feature

```bash
# 1. Make sure you're on develop and up to date
git checkout develop
git pull origin develop

# 2. Create a new feature branch
git checkout -b feature/your-feature-name

# Example:
git checkout -b feature/supabase-setup
git checkout -b feature/test-workflows
```

**Naming Convention:**
- `feature/` - New features
- `fix/` - Bug fixes
- `refactor/` - Code improvements
- `test/` - Testing features

### While Working

1. **Make small, frequent commits**
   ```bash
   git add .
   git commit -m "feat: add Supabase connection setup"
   ```

2. **Push your branch regularly** (so partner can see progress)
   ```bash
   git push -u origin feature/your-feature-name
   ```

3. **Use Cursor's Git panel** (left sidebar) to:
   - See what files changed
   - Stage/unstage files
   - Write commit messages
   - View diff

### When You're Done with Your Feature

```bash
# 1. Make sure everything is committed
git status  # Should show "nothing to commit"

# 2. Push your final changes
git push origin feature/your-feature-name

# 3. Create Pull Request on GitHub (or ask partner to review)
```

### Reviewing Partner's Work

#### Option 1: Review in Cursor

```bash
# 1. Fetch partner's branch
git fetch origin

# 2. Checkout their branch
git checkout feature/partner-feature-name

# 3. Review the code in Cursor
# 4. Test it locally
# 5. Switch back to your branch
git checkout develop
```

#### Option 2: Review on GitHub

1. Go to GitHub repository
2. Click "Pull Requests"
3. Review the changes
4. Leave comments
5. Approve or request changes

### Merging Work

```bash
# After partner approves your PR:

# 1. Switch to develop
git checkout develop

# 2. Pull latest (includes your merged changes)
git pull origin develop

# 3. Delete your feature branch (cleanup)
git branch -d feature/your-feature-name
git push origin --delete feature/your-feature-name
```

---

## 🛠️ Cursor-Specific Features for Collaboration

### 1. Git Integration Panel

**Location:** Left sidebar → Source Control icon (or `Ctrl+Shift+G`)

**What you can do:**
- See all changed files
- Stage/unstage changes
- Write commit messages
- View diffs
- Push/pull changes

### 2. Source Control View

**Features:**
- **Changes**: Files you've modified
- **Staged Changes**: Files ready to commit
- **Merge Changes**: Conflicts to resolve
- **Timeline**: Commit history

### 3. Diff Viewer

**How to use:**
1. Click on a changed file in Source Control
2. Cursor shows side-by-side diff
3. See exactly what changed
4. Can edit directly in diff view

### 4. Branch Switcher

**Quick way to switch branches:**
- Bottom left corner shows current branch
- Click it to see all branches
- Select branch to switch

### 5. Conflict Resolution

**If you have merge conflicts:**

1. Cursor will highlight conflicted files
2. Click on file to see conflicts
3. Options:
   - **Accept Current Change** (yours)
   - **Accept Incoming Change** (partner's)
   - **Accept Both Changes**
   - **Compare Changes** (side-by-side)
4. After resolving, stage the file
5. Commit the merge

---

## 💬 Communication While Coding

### Using Cursor's AI for Collaboration

**You can ask Cursor:**
- "Show me what changed in the last commit"
- "Explain this code my partner wrote"
- "Help me review this pull request"
- "What conflicts do I have with develop?"

### Best Practices

1. **Commit Messages**: Write clear messages so partner understands what you did
   ```
   ✅ Good: "feat: add Supabase database connection with connection pooling"
   ❌ Bad: "fix stuff"
   ```

2. **Small Commits**: Commit often, push regularly
   - Partner can see your progress
   - Easier to review
   - Less chance of conflicts

3. **Communicate Before Big Changes**
   - "I'm about to refactor the database client"
   - "Working on Supabase migration, don't merge develop yet"
   - "Finished feature X, ready for review"

4. **Use GitHub Issues**
   - Create issue before starting work
   - Link commits to issues: `git commit -m "fix: resolve #123"`
   - Close issues when done

---

## 🚨 Avoiding Conflicts

### Prevention

1. **Work on Different Files When Possible**
   - Partner works on backend, you work on frontend
   - Or work on different features

2. **Pull Before Starting Work**
   ```bash
   git checkout develop
   git pull origin develop
   ```

3. **Communicate What You're Working On**
   - "I'm editing api/db/database.py"
   - "Don't touch routes/workflow.py, I'm working on it"

4. **Keep Branches Short-Lived**
   - Don't work on a branch for weeks
   - Merge frequently

### If Conflicts Happen

**Don't panic!** Conflicts are normal.

1. **See what conflicted:**
   ```bash
   git status
   ```

2. **Open conflicted file in Cursor**
   - Cursor highlights conflicts
   - Shows both versions

3. **Resolve conflicts:**
   - Choose which version to keep
   - Or combine both
   - Remove conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)

4. **Test your resolution:**
   ```bash
   # Make sure code still works
   # Run tests if you have them
   ```

5. **Commit the resolution:**
   ```bash
   git add .
   git commit -m "resolve: merge conflicts with develop"
   ```

---

## 📊 Tracking Progress

### See What Partner is Working On

```bash
# See all branches (including partner's)
git branch -a

# See partner's commits
git log origin/develop --oneline -10

# See what files partner changed
git log origin/develop --name-only -1
```

### Using GitHub

1. **Go to repository on GitHub**
2. **Click "Insights" → "Network"**
   - See branch structure
   - See who's working on what

3. **Click "Pull Requests"**
   - See open PRs
   - Review partner's work

---

## ✅ Daily Checklist

**Before starting work:**
- [ ] Pull latest from develop
- [ ] Check what partner changed
- [ ] Create feature branch if starting new work

**While working:**
- [ ] Commit frequently
- [ ] Push your branch
- [ ] Communicate if blocking partner

**Before ending work:**
- [ ] Commit all changes
- [ ] Push your branch
- [ ] Update GitHub issue if you have one

**When partner finishes feature:**
- [ ] Review their code
- [ ] Test it locally
- [ ] Approve or request changes
- [ ] Merge to develop

---

## 🎓 Quick Reference

### Essential Commands

```bash
# See current status
git status

# See what branch you're on
git branch

# Switch branches
git checkout branch-name

# Pull latest changes
git pull origin develop

# Create and switch to new branch
git checkout -b feature/new-feature

# Commit changes
git add .
git commit -m "your message"

# Push your branch
git push origin feature/your-branch

# See commit history
git log --oneline -10
```

### Cursor Shortcuts

- `Ctrl+Shift+G` - Open Source Control
- `Ctrl+` ` (backtick) - Open terminal
- Click branch name (bottom left) - Switch branches
- Click file in Source Control - View diff

---

## 🆘 Troubleshooting

### "Your branch is behind"

```bash
git pull origin develop
# If conflicts, resolve them, then:
git add .
git commit -m "merge: resolve conflicts"
```

### "Can't push, branch is protected"

- Create Pull Request instead
- Partner will review and merge

### "Lost my changes"

```bash
# See recent commits
git reflog

# Recover lost commit
git checkout <commit-hash>
```

### "Accidentally committed to wrong branch"

```bash
# Move last commit to new branch
git branch feature/correct-branch
git reset --hard HEAD~1
git checkout feature/correct-branch
```

---

## 💡 Pro Tips

1. **Use Cursor's AI**: Ask it to explain partner's code
2. **Use GitHub Desktop**: If you prefer GUI over command line
3. **Set up Git aliases**: For faster commands
4. **Use `.gitignore`**: So you don't commit unnecessary files
5. **Regular sync**: Pull/push at least once a day

---

*Last Updated: [Date]*
*Version: 1.0*

