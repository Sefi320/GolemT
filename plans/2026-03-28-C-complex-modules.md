# Plan C — Complex Modules: Co-Dynamics + Hedge Ratios

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.
> **Prerequisite:** Plans A and B must be complete before starting Plan C.
> **Note:** Do NOT write code for the user unless explicitly asked.

**Goal:** Build the co-dynamics tab (5 panels, synchronized animation, sequential build) and the hedge ratios tab (rolling beta, portfolio hedge, GARCH rebalancing signal, CMT financing cost overlay).

**Architecture:** Both modules are the most complex in the app. Build one panel at a time within each module. The synchronized animation (Panel 1) and sequential build chart (Panel 4) are the hardest pieces — tackle them last within their respective tasks.

**Tech Stack:** plotly (frame-based animation, synchronized), shiny reactiveVal, all fct_ functions from Plan A

---

## File Map

| File | Responsibility |
|---|---|
| `R/mod_codynamics.R` | Co-dynamics tab: 5 panels, synchronized PADD map + CL animation, sequential build |
| `R/mod_hedge.R` | Hedge ratios tab: rolling beta animation, portfolio hedge, NG case, GARCH signal, CMT overlay |
| `R/app_ui.R` | Add co-dynamics and hedge tabs |
| `R/app_server.R` | Wire both modules |

---

## Task 1: Co-Dynamics Module — Panels 2, 3, 5 (Static Panels First)

**Files:**
- Create: `R/mod_codynamics.R` (partial — panels 2, 3, 5 only)
- Modify: `R/app_ui.R`, `R/app_server.R`

Build the three simpler panels first. Add the tab to the app now so you can verify as you go. Leave Panel 1 (synchronized animation) and Panel 4 (sequential build) for subsequent tasks.

**Panel 2 — BRN-CL Spread (Ukraine 2022):**
- `renderPlotly`: BRN01 minus CL01 price over 2021–2023
- Horizontal reference lines showing "normal range" (approximately ±$5)
- Vertical event marker at 2022-02-24 with label "Russia invades Ukraine"
- Tooltip showing exact spread value and date on hover
- Narrative text below explaining geographic supply disruption story

**Panel 3 — BRN vs NG Volatility (Ukraine 2022):**
- `renderPlotly`: rolling volatility of BRN01 and NG01 on same chart (two lines)
- Date range 2021–2023
- Vertical event marker at 2022-02-24
- Rolling window slider (30/60/90 days) updates both lines
- Narrative: same shock, different volatility persistence — market structure explains the difference

**Panel 5 — NG-HO Substitution (Uri 2021):**
- `renderPlotly` for rolling correlation: NG01 vs HO01 rolling correlation over 2020–2022
- Vertical event marker at 2021-02-10 (Uri)
- Companion `renderPlotly`: NG01 and HO01 prices normalized to 100 at 2021-01-01, same chart
- Narrative: correlation emerging from crisis, not fundamental market structure

- [ ] **Step 1: Create `R/mod_codynamics.R` with panels 2, 3, 5**

Write `mod_codynamics_ui(id)` with layout for all 5 panels (use placeholder `div` for panels 1 and 4 for now).
Write `mod_codynamics_server(id, app_data)` with render functions for panels 2, 3, 5.

- [ ] **Step 2: Wire into app_ui.R and app_server.R**

- [ ] **Step 3: Run and verify panels 2, 3, 5**

- Panel 2: Spread chart should clearly show the blowout in Feb-March 2022
- Panel 3: BRN vol should spike and recover quickly; NG vol should spike and stay elevated longer
- Panel 5: Correlation near zero most of the time, spikes during Uri

- [ ] **Step 4: Commit**

Commit message: `"feat: add mod_codynamics panels 2, 3, 5"`

---

## Task 2: Co-Dynamics — Panel 4 (Sequential Build)

**Files:**
- Modify: `R/mod_codynamics.R` (add Panel 4)

**Panel 4 — Sequential Build: RB/HO/CL Demand + Prices (COVID 2020):**

This panel has two side-by-side charts and a "Next" button. A `reactiveVal` counter (starts at 0, max 3) controls which layers are visible. Each click of "Next" increments the counter and animates in the new layer.

**Left chart (demand — from EIA data):**
- Counter = 1: CL refinery runs (crude demand proxy) — drops in March 2020
- Counter = 2: add RB demand (gasoline consumption) — collapses faster than CL
- Counter = 3: add HO demand (diesel consumption) — drops later as supply chains slow

**Right chart (price / spread):**
- Counter = 1: CL01 price — collapses, goes negative April 2020
- Counter = 2: add RB01 price — collapses faster; RB-CL crack spread implodes
- Counter = 3: add HO01 price — drops; HO-CL crack spread also collapses

**Animation of each new layer:** Each new line draws itself from left to right using plotly's `add_trace` approach with frame-based animation, or by using CSS transition if simpler.

**Implementation approach for the counter:**
- `next_btn` — `actionButton` in the UI
- `layer_count <- reactiveVal(0)` in the server
- `observeEvent(input$next_btn, { layer_count(min(layer_count() + 1, 3)) })`
- Each render function reads `layer_count()` and shows the appropriate traces

- [ ] **Step 1: Add Panel 4 to mod_codynamics.R**

Add "Next" button to the UI. Add `layer_count` reactiveVal and observeEvent to the server. Build the left chart render function with conditional layer logic. Build the right chart render function with conditional layer logic.

- [ ] **Step 2: Run and verify Panel 4**

Click "Next" three times. Verify:
- First click: CL demand and CL price appear
- Second click: RB demand and RB-CL spread added to respective charts
- Third click: HO demand and HO-CL spread added
- All layers remain visible after being added (they accumulate, not replace)
- Each new layer animates in rather than appearing instantly

- [ ] **Step 3: Commit**

Commit message: `"feat: add co-dynamics panel 4 — sequential build animation"`

---

## Task 3: Co-Dynamics — Panel 1 (Synchronized Animation)

**Files:**
- Modify: `R/mod_codynamics.R` (add Panel 1)

**Panel 1 — PADD Storage Map + CL Price (COVID 2020):**

This is the most technically complex piece in the entire app. Two charts share a single play/pause button and timeline slider. Both advance through time together.

**Left chart — PADD storage map:**
- A plotly map (using `plot_geo` or `plot_ly` with US state/region shapes) showing the 5 PADD regions
- Bubble size or color fill represents storage utilization (storage level / capacity) for each PADD region
- One frame per week (EIA storage is weekly data)
- Date range: 2019-01-01 to 2021-06-01 (to show pre-COVID normal, the COVID crash, and recovery)
- Focus: PADD 2 (Cushing area) filling to capacity in April 2020

**Right chart — CL01 price:**
- Line chart of CL01 price over the same date range
- The current frame date shown as a vertical line that advances with the animation
- Event markers: March 2020 price war, April 2020 negative price

**Synchronization mechanism:**
- `current_frame <- reactiveVal(1)` — shared state
- Play button: starts an `observe` loop (or uses `shinyjs`/JavaScript timer) that increments `current_frame` on an interval
- Pause button: stops the loop
- Timeline slider: `sliderInput` that both reads from and writes to `current_frame`
- Both charts are `renderPlotly` outputs that read `current_frame()` and render the appropriate frame

Note: True synchronized plotly animation without JavaScript is difficult. An alternative approach: use plotly's built-in frame animation on both charts, with a shared `sliderInput` that acts as a frame scrubber. Research `plotlyProxy` for updating charts without full re-render.

- [ ] **Step 1: Build Panel 1 as two separate non-synchronized charts first**

Get the PADD map animating on its own. Get the CL price chart with a vertical date line. Verify both work independently before attempting synchronization.

- [ ] **Step 2: Add synchronization**

Connect both charts to a shared `reactiveVal` for the current date/frame. Add play/pause button and timeline slider.

- [ ] **Step 3: Run and verify**

Click play. Verify:
- Both charts advance together through time
- PADD 2 storage fills visibly in March-April 2020
- CL01 price drops simultaneously on the right chart
- Pause stops both charts at the same frame
- Slider allows manual scrubbing of both charts together

- [ ] **Step 4: Run full test suite**

Run `devtools::test()`. All Plan A tests should still pass.

- [ ] **Step 5: Commit**

Commit message: `"feat: add co-dynamics panel 1 — synchronized PADD map + CL animation"`

---

## Task 4: Hedge Ratios Module — Sections 1 and 2

**Files:**
- Create: `R/mod_hedge.R` (partial — sections 1 and 2)
- Modify: `R/app_ui.R`, `R/app_server.R`

**Section 1 — Single Instrument Hedge Failure (RB-CL):**

Sequential animation (not dynamic) showing the rolling beta story:

- `renderPlotly`: RB01-CL01 rolling beta over 2019–2021
- Animation plays through time automatically (frame-based plotly animation)
- Event markers: March 2020 (price war), April 2020 (WTI negative)
- Watch beta collapse during COVID
- Narrative text: why this hedge looked good in calm markets but failed exactly when needed

Interactive: rolling window slider (30/60/90/252 days) shows how window choice affects beta stability.

**Section 2 — Portfolio Hedge Solution:**

- `renderPlotly`: two lines on same chart
  - Line 1: RB-CL rolling beta (single instrument — already built above)
  - Line 2: RB-(CL+HO) portfolio rolling beta (more stable)
- Show that Line 2 stays closer to its historical average during COVID
- Narrative: portfolio hedge construction, why HO helps, trade-off with complexity

Portfolio beta calculation: use `calc_rolling_beta()` for RB~CL and for RB~HO separately, then combine weights (e.g. 70% CL + 30% HO) and compute weighted portfolio beta.

- [ ] **Step 1: Create `R/mod_hedge.R` with sections 1 and 2**

- [ ] **Step 2: Wire into app_ui.R and app_server.R**

- [ ] **Step 3: Run and verify**

- Section 1: animate the rolling beta and verify the COVID collapse is visible
- Section 2: verify the portfolio beta line is visibly more stable than the single-instrument line during COVID

- [ ] **Step 4: Commit**

Commit message: `"feat: add mod_hedge sections 1-2 — single vs portfolio hedge"`

---

## Task 5: Hedge Ratios — Sections 3, 4, 5, 6

**Files:**
- Modify: `R/mod_hedge.R` (add sections 3–6)

**Section 3 — Rebalancing Problem:**
- `renderPlotly`: rolling beta for RB-CL using two windows simultaneously (30-day and 252-day) as two lines
- Shows 30-day is more responsive but noisier
- Rolling window selector updates which windows are shown
- GARCH conditional vol from `calc_garch()` for CL01 overlaid on secondary axis — shows when GARCH signals elevated vol (trigger for shorter window)
- Narrative: when to use which window, transaction cost trade-off

**Section 4 — NG: The Unhedgeable Market:**
- `renderPlotly`: NG01-NG06 rolling beta animated over 2020-2022 (same animation approach as Section 1)
- Event marker: 2021-02-10 (Uri)
- Show beta collapse during Uri
- Below chart: narrative text listing why cross-commodity hedges fail for NG, and mentioning weather derivatives and power futures as theoretically better alternatives

**Section 5 — CMT Financing Cost:**
- `renderPlotly`: 3-month CMT yield vs a "hedge financing cost index" (can be proxied as the 3M CMT yield itself — higher yield = higher cost to finance margin)
- Overlay on RB-CL rolling beta chart from Section 1 as a secondary axis
- Annotate: 2020 near-zero rates vs 2022-2023 5%+ rates
- Narrative: hedging programs that were cheap to run in 2020 became significantly more expensive in 2022-2023

**Section 6 — Term Structure Hedge Ratios:**
- `renderPlotly`: heatmap where x = hedging contract (CL01), y = exposure contract (CL02, CL03, CL06, CL12, CL24), fill = rolling beta value at each date
- Use plotly frame animation to show how the heatmap evolves over time
- Event marker: April 2020 shows term structure beta breakdown (CL01 goes negative, deferred contracts don't follow)

- [ ] **Step 1: Add sections 3–6 to mod_hedge.R**

Build one section at a time. Run the app after each section to verify before building the next.

- [ ] **Step 2: Run and verify all hedge ratio sections**

- Section 3: GARCH overlay aligns with periods of beta instability
- Section 4: Uri beta collapse is clearly visible
- Section 5: 2022 rate period shows elevated financing cost during a period of already-stressed energy markets
- Section 6: April 2020 shows a clear anomaly in the term structure beta heatmap

- [ ] **Step 3: Run full test suite**

Run `devtools::test()`. All Plan A tests should still pass.

- [ ] **Step 4: Commit**

Commit message: `"feat: complete mod_hedge — all hedge ratio sections — Plan C complete"`

---

## Plan C Complete

Before moving to Plan D, verify:
- Co-dynamics tab: all 5 panels render without error
- Synchronized animation: PADD map and CL price advance together
- Sequential build: all 3 layers build correctly with "Next" button
- Hedge ratios tab: all 6 sections render without error
- Rolling window slider updates affect the correct charts
- `devtools::test()` still passes with zero failures
