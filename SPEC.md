# SpeedMath

Learn math as fast as possible. Grade 1 through university. No login.

## Product
- Home screen: one giant Start button (stopwatch bezel styling) + small profile button top-right.
- Press Start -> question screen. Two modes:
  - TYPE: custom numeric keypad (digits, minus, point, slash).
  - SPEED: speak the answer; on-device speech recognition; answer time is measured.
- Every question shows step-by-step "how to solve" after answering. Unlimited rounds.
- Question engine: procedural templates, levels 1-130 (10 per grade, 121-130 university),
  every answer is an integer, simple fraction, or short decimal so it is typeable and speakable.
- Profile: current level, "performing at Grade X", stats (avg time, streaks, totals),
  settings, Pro purchase.

## Monetization
- Free tier: heavy AdMob ads (banners home + question screens, native cards, interstitial
  between rounds). This is the revenue engine.
- Pro: $4.99/month subscription (com.deitel.speedmath.pro.monthly) removes ALL ads and
  unlocks the "Explain it" AI tutor (Cloudflare Workers AI via apps-ai-proxy, no key).

## Design: Retro Stopwatch
- Cream paper #F7F1E1, ink navy #1B2A4A, tangerine #FF6B35, brass #D9A441,
  correct green #2E7D5B, wrong red #C0392B.
- Heavy condensed flip-clock numerals for display, SF Pro / SF Rounded body.
- Motion: flip-clock digit rolls, sweeping stopwatch hand while solving, streak meter.
- NO emojis anywhere. Vector icons only (SF Symbols + custom paths).

## Structure
- `iOS/` — xcodegen project (bundle com.deitel.speedmath, team W7Q885Q59C, iOS 26).
- `docs/` — animated marketing site + privacy.html + terms.html (GitHub Pages).
- `store/` — ASC listing text + screenshots.
- CI: public repo `speedmath-app`, .github/workflows/build-and-upload.yml (cloud archive).

## Owner TODOs (hard gates before App Store submission)
1. Create AdMob account; paste real App ID into iOS/project.yml (GADApplicationIdentifier)
   and the three ad unit IDs into iOS/SpeedMath/Ads/AdConfig.swift.
   Gate: `grep -r 3940256099942544 iOS/` must only hit the AdConfig comment.
2. Publish the GDPR (UMP) consent message in the AdMob console.
