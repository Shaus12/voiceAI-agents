# Collaboration Workflow Guide

## 🎯 Purpose
This document outlines how we work together on this project to ensure smooth collaboration and organized development.

---

## 📋 Development Workflow

### Branch Strategy

```
main (production-ready)
  ├── develop (integration branch)
  │   ├── feature/knowledge-base
  │   ├── feature/call-summarization
  │   ├── feature/ui-redesign
  │   └── cleanup/remove-unused-features
  └── hotfix/urgent-fixes
```

**Rules:**
- `main`: Only production-ready, tested code
- `develop`: Integration branch for features
- `feature/*`: Individual feature branches
- `cleanup/*`: Code cleanup/removal branches
- Always create feature branches from `develop`

### Git Workflow

1. **Before starting work:**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/your-feature-name
   ```

2. **During development:**
   - Commit frequently with clear messages
   - Push to your feature branch regularly
   - Keep commits focused (one logical change per commit)

3. **Before merging:**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout feature/your-feature-name
   git rebase develop  # or merge develop into your branch
   ```

4. **Commit Message Format:**
   ```
   type(scope): brief description

   Detailed explanation if needed

   Examples:
   - feat(ui): add knowledge base upload interface
   - fix(api): resolve call summarization timeout
   - refactor(workflow): remove unused campaign functions
   - docs(readme): update setup instructions
   ```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring
- `docs`: Documentation
- `style`: Formatting
- `test`: Tests
- `chore`: Maintenance

---

## 📝 Task Management

### Using GitHub Issues

**Issue Labels:**
- `enhancement`: New feature
- `bug`: Bug fix
- `refactor`: Code improvement
- `ui/ux`: Interface changes
- `documentation`: Docs updates
- `priority-high`: Urgent
- `priority-medium`: Normal
- `priority-low`: Nice to have

**Issue Template:**
```markdown
## Description
Brief description of what needs to be done

## Acceptance Criteria
- [ ] Criteria 1
- [ ] Criteria 2
- [ ] Criteria 3

## Technical Notes
Any technical considerations

## Related Issues
#123, #456
```

### Task Assignment

1. Create issue for each task
2. Assign to yourself or partner
3. Link to feature branch
4. Update progress in issue comments
5. Close when merged to `develop`

---

## 🔄 Code Review Process

### Before Requesting Review

1. ✅ Code follows project style guide
2. ✅ All tests pass
3. ✅ No console.logs or debug code
4. ✅ Documentation updated if needed
5. ✅ Self-reviewed your own code

### Review Checklist

**Reviewer should check:**
- [ ] Code quality and style
- [ ] Logic correctness
- [ ] Error handling
- [ ] Performance considerations
- [ ] Security implications
- [ ] Test coverage
- [ ] Documentation

### Review Comments

- Be constructive and specific
- Suggest solutions, not just problems
- Approve when ready: "LGTM" (Looks Good To Me)
- Request changes with clear explanation

---

## 📁 Project Organization

### File Structure Standards

```
api/
  ├── services/
  │   ├── feature_name/     # Group related services
  │   │   ├── __init__.py
  │   │   ├── service.py
  │   │   └── models.py
  │   └── ...
  ├── routes/
  │   └── feature_name.py   # One file per feature route
  └── db/
      └── feature_name_client.py

ui/
  ├── src/
  │   ├── app/
  │   │   └── feature-name/  # Feature-specific pages
  │   ├── components/
  │   │   └── feature-name/  # Feature-specific components
  │   └── lib/
  │       └── feature-name.ts  # Feature utilities
```

### Naming Conventions

- **Files**: `snake_case.py` (Python), `PascalCase.tsx` (React components)
- **Functions**: `snake_case()` (Python), `camelCase()` (TypeScript)
- **Classes**: `PascalCase`
- **Constants**: `UPPER_SNAKE_CASE`
- **Components**: `PascalCase.tsx`

---

## 🧪 Testing Standards

### Before Merging

1. **Backend:**
   ```bash
   cd api
   pytest tests/
   ```

2. **Frontend:**
   ```bash
   cd ui
   npm run lint
   npm run build  # Should succeed
   ```

3. **Manual Testing:**
   - Test the feature end-to-end
   - Test edge cases
   - Test error scenarios

### Test Coverage

- Aim for >70% coverage on new code
- Write tests for critical paths
- Test error handling

---

## 📚 Documentation Standards

### Code Documentation

**Python:**
```python
def process_call_summary(workflow_run_id: int) -> dict:
    """
    Generate summary for a completed call.
    
    Args:
        workflow_run_id: ID of the workflow run to summarize
        
    Returns:
        Dictionary containing summary data:
        - summary: Text summary
        - key_points: List of key points
        - sentiment: Overall sentiment
        
    Raises:
        ValueError: If workflow run not found
        RuntimeError: If summarization fails
    """
    pass
```

**TypeScript:**
```typescript
/**
 * Uploads knowledge base file and processes it for agent use
 * @param file - The file to upload
 * @param organizationId - Organization ID
 * @returns Promise resolving to knowledge base ID
 * @throws {Error} If upload fails
 */
async function uploadKnowledgeBase(
  file: File,
  organizationId: number
): Promise<string> {
  // ...
}
```

### README Updates

- Update README when adding major features
- Document new environment variables
- Update setup instructions if needed

---

## 🔍 Code Quality

### Linting & Formatting

**Backend:**
```bash
# Format code
black api/
ruff check api/
ruff format api/

# Before committing
pre-commit run --all-files
```

**Frontend:**
```bash
# Format and lint
npm run fix-lint
npm run lint
```

### Code Review Focus Areas

1. **Performance**: No N+1 queries, efficient algorithms
2. **Security**: Input validation, SQL injection prevention
3. **Maintainability**: Clear code, good naming
4. **Scalability**: Won't break with more users/data

---

## 🚀 Deployment Process

### Staging Deployment

1. Merge feature to `develop`
2. Deploy `develop` to staging
3. Test on staging
4. Fix any issues
5. Merge `develop` to `main`

### Production Deployment

1. Create release PR: `develop` → `main`
2. Review and approve
3. Merge to `main`
4. Tag release: `git tag v1.x.x`
5. Deploy to production
6. Monitor for issues

---

## 💬 Communication

### Daily Standup (Async)

**Format:**
```
Yesterday: What I completed
Today: What I'm working on
Blockers: Any issues or questions
```

**Where:** GitHub Discussions or Slack

### Important Decisions

- Document in `DECISIONS.md`
- Discuss before implementing
- Get approval for major changes

### Questions

- Use GitHub Discussions for questions
- Tag partner for urgent issues
- Document answers for future reference

---

## 📊 Progress Tracking

### Weekly Review

Every week, review:
- Completed tasks
- In-progress tasks
- Blockers
- Next week's priorities

### Project Board

Use GitHub Projects to track:
- To Do
- In Progress
- Review
- Done

---

## 🛠️ Development Environment

### Setup Checklist

- [ ] Python 3.12 installed
- [ ] Node.js 20+ installed
- [ ] Docker & Docker Compose installed
- [ ] PostgreSQL running (or Supabase)
- [ ] Redis running
- [ ] Environment variables configured
- [ ] Database migrations run
- [ ] Dependencies installed

### Environment Variables

Keep `.env.example` updated with all required variables.

**Never commit:**
- `.env` files
- API keys
- Secrets
- Database passwords

---

## 🐛 Bug Reporting

### Bug Report Template

```markdown
## Description
What happened?

## Steps to Reproduce
1. Go to...
2. Click on...
3. See error

## Expected Behavior
What should happen?

## Actual Behavior
What actually happens?

## Environment
- OS: 
- Browser: 
- Version: 

## Screenshots
If applicable

## Logs
Relevant error logs
```

---

## ✅ Definition of Done

A task is "done" when:

- [ ] Code written and tested
- [ ] Tests pass
- [ ] Code reviewed and approved
- [ ] Documentation updated
- [ ] No linting errors
- [ ] Merged to `develop`
- [ ] Issue closed

---

## 📞 Emergency Contacts

- **Critical Bug**: Create urgent issue, tag partner
- **Production Down**: Immediate communication
- **Security Issue**: Report immediately, don't commit fix publicly

---

*Last Updated: [Date]*
*Version: 1.0*

