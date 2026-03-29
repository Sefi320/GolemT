# Plan D — Integration: Wire Everything + Full App Verification

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.
> **Prerequisite:** Plans A, B, and C must be complete before starting Plan D.
> **Note:** Do NOT write code for the user unless explicitly asked.

**Goal:** Final wiring, polish, performance checks, full end-to-end verification, and GitHub preparation.

**Architecture:** All modules are built. This plan ensures they work together correctly, the app is performant enough for an 8-minute live presentation, and the GitHub repo is ready for submission.

**Tech Stack:** golem, devtools, GitHub

---

## File Map

| File | Responsibility |
|---|---|
| `R/app_ui.R` | Final tab order and layout polish |
| `R/app_server.R` | Verify all modules wired correctly |
| `R/mod_data.R` | Add loading indicators, error messaging |
| `DESCRIPTION` | Verify all dependencies listed |
| `.github/workflows/` | GitHub Actions (if required by assignment) |

---

## Task 1: Final app_ui.R and app_server.R

**Files:**
- Modify: `R/app_ui.R`
- Modify: `R/app_server.R`

- [ ] **Step 1: Verify tab order in app_ui.R**

Final tab order should be:
1. Crude Oil (WTI) — CL
2. Natural Gas — NG
3. Brent Crude — BRN
4. RBOB Gasoline — RB
5. Heating Oil — HO
6. Yield Curve (CMT)
7. Co-Dynamics
8. Hedge Ratios

- [ ] **Step 2: Verify all modules are wired in app_server.R**

Confirm every module server is called with the correct ID and `app_data` argument.

- [ ] **Step 3: Run the full app**

Run `golem::run_dev()`. Navigate through every tab. Verify nothing crashes on load.

- [ ] **Step 4: Commit**

Commit message: `"fix: finalize app_ui and app_server wiring"`

---

## Task 2: Loading State and Error Handling

**Files:**
- Modify: `R/mod_data.R`

The app fetches CMT data from FRED and EIA data on startup. This can take several seconds. The user should see a clear loading state, not a blank screen.

- [ ] **Step 1: Add loading indicator to mod_data_ui**

Use `shinybusy::add_busy_spinner()` or `bslib` progress indicators. Show while FRED and EIA fetches are in progress.

- [ ] **Step 2: Verify error messages display correctly**

Temporarily break the FRED fetch (wrong series ID) and verify the app shows a useful inline error message on the CMT tab rather than crashing. Restore the correct series ID after verifying.

- [ ] **Step 3: Verify the app still works if EIA fetch is slow**

EIA data is used on co-dynamics Panel 1 and Panel 4. If EIA fetch takes >10 seconds, the panels should show a "loading" placeholder rather than a blank output.

- [ ] **Step 4: Commit**

Commit message: `"fix: add loading states and error handling to mod_data"`

---

## Task 3: Full Unit Test Suite

**Files:**
- Review all test files in `tests/testthat/`

- [ ] **Step 1: Run complete test suite**

Run `devtools::test()`. Expected: all tests pass, zero failures, zero errors.

- [ ] **Step 2: Check test coverage**

Every `fct_` file should have a corresponding test file. Confirm:
- `test-fct_filter_futures.R` ✓
- `test-fct_fetch_cmt.R` ✓
- `test-fct_fetch_eia.R` ✓
- `test-fct_calc_returns.R` ✓
- `test-fct_calc_rolling_vol.R` ✓
- `test-fct_calc_garch.R` ✓
- `test-fct_calc_seasonality.R` ✓
- `test-fct_calc_correlation.R` ✓
- `test-fct_calc_beta.R` ✓
- `test-fct_build_curve.R` ✓

If any are missing, write them now.

- [ ] **Step 3: Commit**

Commit message: `"test: complete unit test suite — all fct_ files covered"`

---

## Task 4: Full App Verification (Presentation Rehearsal)

This task simulates your 8-minute presentation. Go through the entire app as if presenting to a senior risk manager. Every output must render, every animation must play, every interaction must work.

- [ ] **Step 1: CL tab**

- Price chart loads with event markers ✓
- Narrative text is readable and correct ✓
- Seasonality heatmap loads; April 2020 is visually distinct ✓
- Forward curve animation plays; curve morphs visibly from contango to backwardation and back ✓
- 3D volatility surface renders ✓
- GARCH renders for selected contract ✓
- Changing rolling window slider updates vol surface ✓

- [ ] **Step 2: NG tab**

- EIA storage chart renders with 5-year average band ✓
- Uri February 2021 visible as anomalous drawdown on storage chart ✓
- Uri February 2021 visible as anomalous dark cell on seasonality heatmap ✓
- Forward curve animation shows extreme backwardation during Uri ✓

- [ ] **Step 3: BRN tab**

- DXY overlay visible on price chart ✓
- BRN-CL spread chart shows Ukraine 2022 blowout ✓
- Seasonality heatmap shows early 2022 as anomalous ✓

- [ ] **Step 4: RB tab**

- Sequential demand animation: click "Next" 2 times, verify layers build correctly ✓
- Spring 2020 anomaly visible on seasonality heatmap ✓

- [ ] **Step 5: HO tab**

- Seasonality heatmap clearly shows bimodal pattern (two peaks per year) ✓
- Winter 2022 anomaly visible ✓

- [ ] **Step 6: CMT tab**

- Yield curve animation plays ✓
- 2022 inversion clearly visible — short end above long end ✓
- Rate cycle chart shows Fed hiking/cutting periods ✓

- [ ] **Step 7: Co-dynamics tab**

- Panel 1: click play, PADD 2 storage fills and CL price drops simultaneously ✓
- Panel 1: pause stops both charts at same frame ✓
- Panel 1: slider scrubs both charts together ✓
- Panel 2: BRN-CL spread shows Ukraine 2022 blowout ✓
- Panel 3: BRN vol recovers faster than NG vol after Ukraine ✓
- Panel 4: click "Next" 3 times, all layers build correctly ✓
- Panel 5: NG-HO correlation spikes during Uri ✓

- [ ] **Step 8: Hedge ratios tab**

- Section 1: rolling beta animation shows COVID collapse ✓
- Section 2: portfolio beta more stable than single-instrument ✓
- Section 3: 30-day vs 252-day window comparison visible ✓
- Section 4: NG-NG06 beta collapses during Uri ✓
- Section 5: CMT financing cost overlay shows 2022 rate spike ✓
- Section 6: term structure beta heatmap shows April 2020 anomaly ✓

- [ ] **Step 9: Commit**

Commit message: `"chore: full app verification complete"`

---

## Task 5: GitHub Repository Setup

- [ ] **Step 1: Initialize git if not already done**

In RStudio Terminal: `git init` then `git remote add origin <your-github-repo-url>`

- [ ] **Step 2: Create .gitignore**

Run `usethis::use_git_ignore()`. Ensure `.Renviron` (which contains your EIA API key) is in `.gitignore`. Never commit API keys.

- [ ] **Step 3: Verify CLAUDE.md is committed**

The assignment requires the AI context file to be in the repo. Confirm `CLAUDE.md` is staged and committed.

- [ ] **Step 4: Verify docs are committed**

Confirm the Obsidian design docs are NOT in the GolemT repo (they're in Uni_Vault, not GolemT). Confirm the superpowers plans in `docs/superpowers/plans/` ARE committed.

- [ ] **Step 5: Push to GitHub**

Push all commits: `git push -u origin main`

- [ ] **Step 6: Add professor as collaborator**

If repo is private: go to GitHub → Settings → Collaborators → add professor's GitHub username.

- [ ] **Step 7: Verify repo is accessible**

Open the repo URL in a private browser window. Confirm it's accessible (public) or that the professor invite was sent (private).

- [ ] **Step 8: Final commit**

Commit message: `"chore: repo ready for submission — Plan D complete"`

---

## Plan D Complete — App is Submission-Ready

Final checklist:
- [ ] `devtools::test()` passes with zero failures
- [ ] Full app runs without errors from `golem::run_dev()`
- [ ] All 8 tabs render correctly
- [ ] All animations play
- [ ] All interactive controls respond
- [ ] CLAUDE.md committed to repo
- [ ] Professor added as collaborator (if private repo)
- [ ] EIA API key NOT committed to repo
- [ ] Repo URL ready to submit by 2026-04-06 10pm MST
