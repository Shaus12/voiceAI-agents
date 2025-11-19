# Testing Checklist - Phase 2

## 🎯 Goal
Test all current features, document what works, what's broken, and what needs improvement.

---

## 📋 How to Use This Checklist

1. **Test each feature** systematically
2. **Check the boxes** as you test
3. **Document bugs** in `BUGS_FOUND.md`
4. **Document decisions** in `DECISIONS.md`
5. **Create GitHub issues** for bugs/improvements

---

## 1. User Management & Authentication

### User Registration/Login
- [ ] Can register new user
- [ ] Can login with credentials
- [ ] Login persists after page refresh
- [ ] Can logout
- [ ] Error messages are clear
- [ ] Password validation works

**Notes:**
```
[Write any issues or observations here]
```

### User Profile
- [ ] Can view profile
- [ ] Can update profile information
- [ ] Changes save correctly

**Notes:**
```
```

---

## 2. Organization Management

### Organizations
- [ ] Can view organizations
- [ ] Can create organization
- [ ] Can switch between organizations
- [ ] Organization data is isolated correctly

**Notes:**
```
```

---

## 3. Workflow Builder

### Workflow Creation
- [ ] Can create new workflow
- [ ] Can name workflow
- [ ] Can add nodes (Start, Agent, End, Global)
- [ ] Can connect nodes with edges
- [ ] Can delete nodes
- [ ] Can delete edges
- [ ] Can save workflow
- [ ] Validation works (shows errors for invalid workflows)

**Notes:**
```
```

### Workflow Editing
- [ ] Can edit existing workflow
- [ ] Can update node properties
- [ ] Can update edge conditions
- [ ] Changes save correctly
- [ ] Can duplicate workflow

**Notes:**
```
```

### Workflow Templates
- [ ] Can view templates
- [ ] Can create workflow from template
- [ ] Templates work correctly

**Notes:**
```
```

### Workflow Validation
- [ ] Validation catches missing start node
- [ ] Validation catches missing end node
- [ ] Validation catches invalid connections
- [ ] Error messages are helpful

**Notes:**
```
```

---

## 4. Workflow Execution

### WebRTC Calls
- [ ] Can initiate WebRTC call
- [ ] Audio works (can hear agent)
- [ ] Microphone works (agent hears you)
- [ ] Call connects successfully
- [ ] Call completes normally
- [ ] Recording is saved
- [ ] Transcript is generated

**Notes:**
```
```

### Workflow Run Details
- [ ] Can view workflow run list
- [ ] Can view individual run details
- [ ] Transcript is displayed
- [ ] Recording can be played
- [ ] Cost information is shown
- [ ] Context variables are shown

**Notes:**
```
```

---

## 5. Telephony Integration

### Telephony Configuration
- [ ] Can configure Twilio (if applicable)
- [ ] Can configure Vonage (if applicable)
- [ ] Configuration saves correctly
- [ ] Can test connection

**Notes:**
```
```

### Phone Calls
- [ ] Can initiate phone call
- [ ] Call connects
- [ ] Audio works both ways
- [ ] Call completes
- [ ] Status callbacks work
- [ ] Recording is saved

**Notes:**
```
```

---

## 6. Campaign Management

### Campaign Creation
- [ ] Can create campaign
- [ ] Can upload source data (CSV/Google Sheets)
- [ ] Can link workflow to campaign
- [ ] Campaign settings save

**Notes:**
```
```

### Campaign Execution
- [ ] Can start campaign
- [ ] Calls are made
- [ ] Progress is tracked
- [ ] Can pause campaign
- [ ] Can resume campaign
- [ ] Can view campaign runs

**Notes:**
```
```

---

## 7. LoopTalk Testing

### Test Sessions
- [ ] Can create test session
- [ ] Can configure test parameters
- [ ] Can start test
- [ ] Test runs successfully
- [ ] Results are displayed
- [ ] Recordings are available

**Notes:**
```
```

---

## 8. Integrations

### Integration Setup
- [ ] Can view integrations
- [ ] Can connect integration (if applicable)
- [ ] Integration works

**Notes:**
```
```

---

## 9. Reports & Analytics

### Reports
- [ ] Can view reports
- [ ] Data is accurate
- [ ] Can filter reports
- [ ] Can export reports

**Notes:**
```
```

---

## 10. UI/UX Testing

### Navigation
- [ ] Navigation is clear
- [ ] Can find features easily
- [ ] Breadcrumbs work (if present)
- [ ] Mobile responsive

**Notes:**
```
```

### Forms
- [ ] Forms are clear
- [ ] Validation messages are helpful
- [ ] Error handling is good
- [ ] Success messages appear

**Notes:**
```
```

### Dashboard
- [ ] Dashboard loads
- [ ] Shows relevant information
- [ ] Metrics are accurate
- [ ] Quick actions work

**Notes:**
```
```

### Workflow Builder UI
- [ ] Drag and drop works
- [ ] Nodes are easy to add
- [ ] Properties panel is clear
- [ ] Zoom/pan works
- [ ] Undo/redo works (if present)

**Notes:**
```
```

---

## 11. API Testing

### API Endpoints
- [ ] Health check works: `GET /api/v1/health`
- [ ] Workflow endpoints work
- [ ] User endpoints work
- [ ] Authentication works
- [ ] Error responses are correct

**Notes:**
```
```

---

## 12. Performance

### Load Times
- [ ] Pages load quickly
- [ ] Workflow builder loads smoothly
- [ ] Large workflows don't lag
- [ ] API responses are fast

**Notes:**
```
```

---

## 13. Error Handling

### Error Scenarios
- [ ] Network errors handled gracefully
- [ ] Invalid input shows clear errors
- [ ] 404 pages work
- [ ] Server errors don't crash UI

**Notes:**
```
```

---

## 📝 Summary

### Features That Work Well
```
[List features that work perfectly]
```

### Features That Need Improvement
```
[List features that work but need fixes]
```

### Features That Are Broken
```
[List features that don't work]
```

### Features to Remove
```
[List features we should remove]
```

---

## 🐛 Next Steps

1. Document all bugs in `BUGS_FOUND.md`
2. Create GitHub issues for each bug
3. Document feature decisions in `DECISIONS.md`
4. Prioritize fixes

---

*Testing completed by: [Your Name]*
*Date: [Date]*

