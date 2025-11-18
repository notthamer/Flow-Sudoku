# Flow Sudoku - App Store Submission Checklist

## Pre-Submission Checklist

### ✅ Code & Build

- [ ] App builds without errors
- [ ] All linter warnings resolved
- [ ] App tested on multiple macOS versions (minimum: macOS 12.0+)
- [ ] No crashes or major bugs
- [ ] Memory leaks checked and fixed
- [ ] Performance optimized

### ✅ Features

- [x] Session tracking implemented
- [x] Daily usage limits working (1 session/day for free)
- [x] Previous Sessions view functional
- [x] How to Play guide complete
- [x] Settings page implemented
- [x] Account creation/sign-in working (local only for MVP)
- [x] Sudoku gameplay fully functional
- [x] Declutter writing working
- [x] All three difficulty levels available

### ✅ App Store Compliance

- [x] No in-app purchases
- [x] No "purchase" or "subscribe" buttons in app
- [x] External link (flowsudoku.com) clearly goes outside app
- [x] No price mentions in the app (removed from upgrade prompt)
- [x] Free tier is fully functional
- [x] No payment processing in app
- [x] No Apple Sign-In required (optional account creation)

### ✅ Privacy & Security

- [x] Privacy Policy created and accessible
- [x] Data collection documented
- [x] Local-first storage implemented
- [x] Optional cloud sync (requires sign-in)
- [x] No third-party analytics or tracking
- [x] No advertising frameworks

### ✅ Assets & Metadata

- [x] App icon (1024x1024) prepared
- [ ] Screenshots captured (5 recommended):
  - Main menu
  - Sudoku + Declutter view
  - Previous Sessions
  - How to Play
  - Settings
- [x] App description written
- [x] Keywords selected
- [x] Promotional text prepared
- [ ] What's New text ready

### ✅ Legal & Documentation

- [x] Privacy Policy URL: flowsudoku.com/privacy
- [ ] Terms of Service URL: flowsudoku.com/terms
- [x] Support URL: flowsudoku.com/support
- [x] Copyright information included
- [ ] Export compliance declaration ready

## App Store Connect Setup

### App Information

**Name**: Flow Sudoku
**Subtitle**: Focus ritual through puzzles
**Primary Language**: English (U.S.)

**Categories**:
- Primary: Productivity
- Secondary: Puzzle

**Age Rating**: 4+

### Pricing & Availability

**Price**: Free
**Availability**: All territories

### App Privacy

**Privacy Policy URL**: https://flowsudoku.com/privacy

**Data Collection**:

| Data Type | Usage | Linked to User | Tracking |
|-----------|-------|----------------|----------|
| Email Address | Account creation | Yes | No |
| Gameplay Content (sessions) | App functionality | No* | No |

*Only linked if user signs in and enables cloud sync

### App Review Information

**Sign-in Required**: No (optional for cloud sync)

**Demo Account** (for reviewers):
- Email: reviewer@flowsudoku.com
- Password: ReviewFlow2025!

**Contact Information**:
- First Name: [Your Name]
- Last Name: [Your Last Name]
- Phone: [Your Phone]
- Email: [Your Email]

**Notes for Reviewer**:
```
Flow Sudoku is a focus productivity app combining Sudoku puzzles with mindful writing.

FREE VERSION (this submission):
- 1 complete session per day
- All features included
- No in-app purchases
- Fully functional

UPGRADE PATH:
- App mentions flowsudoku.com for unlimited sessions
- This links to our website (external to App Store)
- Studio version is a separate download from our website
- All payments happen outside the App Store
- No IAP compliance required

HOW TO TEST:
1. Launch app → Select "Begin Flow"
2. Choose difficulty and duration
3. Play Sudoku puzzle + use declutter writing
4. Complete or exit session
5. View session in "Previous Sessions"
6. Try starting a second session → see daily limit message
7. Optional: Create account in Settings to test sync (local only in this version)

The daily limit resets at midnight local time.
```

## Build Upload Checklist

### Using Xcode

- [ ] Archive created (Product → Archive)
- [ ] App validated (Organizer → Validate App)
- [ ] All validation checks passed
- [ ] App uploaded to App Store Connect
- [ ] Build processing completed (~15 minutes)

### Version Information

**Version**: 1.0.0
**Build**: 1

### Release Options

- [ ] Automatically release after approval
- [ ] Or: Manually release after approval (recommended)

## Post-Submission

### Monitor Status

- [ ] Waiting for Review
- [ ] In Review
- [ ] Pending Developer Release (if manual release selected)
- [ ] Ready for Sale

### Rejection Handling

If rejected for IAP issues:
1. Confirm no "purchase" or "subscribe" language
2. Confirm free version is fully functional
3. Confirm external link is clearly marked
4. Provide detailed explanation in response

### Launch Preparation

- [ ] Marketing website updated (flowsudoku.com)
- [ ] Social media posts prepared
- [ ] Press release ready (if applicable)
- [ ] Product Hunt launch planned (if applicable)
- [ ] Support email setup and monitored

## Common Rejection Reasons & Solutions

### 1. "App requires in-app purchase"
**Solution**: Explain that free version is complete (1 session/day) and Studio is a separate product purchased externally.

### 2. "External link violates guidelines"
**Solution**: Confirm link clearly opens browser and doesn't trick users. Free version remains functional.

### 3. "Misleading users about pricing"
**Solution**: Ensure no prices mentioned in-app. Only say "unlimited at flowsudoku.com"

### 4. "Incomplete functionality"
**Solution**: Demonstrate that 1 session/day is the intended free experience, not a trial.

### 5. "Privacy policy incomplete"
**Solution**: Review privacy policy checklist and ensure all data collection is documented.

## Additional Considerations

### Export Compliance

Flow Sudoku uses standard encryption for:
- Password hashing
- HTTPS connections (if cloud sync enabled)

**Declaration**: Yes, uses encryption
**ERN**: Not required (uses only standard encryption)

### Accessibility

- [ ] VoiceOver tested
- [ ] Keyboard navigation tested
- [ ] High contrast mode checked
- [ ] Text scaling tested

### Localization

**Version 1.0.0**: English only
**Future versions**: Consider Spanish, French, German, Japanese

## Success Metrics to Track

After approval, monitor:
- Daily active users
- Session completion rate
- Daily limit hit rate
- Conversion to Studio (external)
- User retention (Day 1, Day 7, Day 30)
- Average session duration

## Post-Launch Updates

**Version 1.1.0** (suggested features):
- Widget support
- Pomodoro timer (1/day for free)
- Daily goals (3/day for free)
- Themes (Studio only)
- Cloud sync activation (for authenticated users)

## Contact for Questions

**Developer**: [Your Name]
**Email**: [Your Email]
**Emergency**: [Your Phone]

---

**Last Updated**: November 16, 2025
**Status**: Ready for submission pending screenshot capture

