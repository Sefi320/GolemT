# CLAUDE.md — GolemT Project Context

---

## Who You Are Working With

A University of Alberta student in FIN 451 (Risk Management / Trading) building a golem/Shiny app as a final project. Time is limited — job alongside 4 courses.

**Knowledge profile:**
- Strong: energy market fundamentals, futures, term structure, contango/backwardation, crack spreads, hedge ratios, GARCH conceptually, cost of carry, beta, rolling statistics, Fed rate cycles, dollar strength, PADD regions
- Learning: R programming, golem framework, Shiny reactivity, modularization

---

## Superpowers Skills

Always invoke when applicable — do not rationalize your way out of it:

- **`superpowers:brainstorming`** — before any new feature design
- **`superpowers:writing-plans`** — before any implementation work
- **`superpowers:executing-plans`** or **`superpowers:subagent-driven-development`** — when executing a plan
- **`superpowers:systematic-debugging`** — before proposing any fix
- **`superpowers:verification-before-completion`** — before claiming any task is done

User instructions (this file) take highest priority over skill instructions.

---

## How to Interact

**Do NOT write code unless explicitly asked.** They are learning by doing. Guide the what and why, let them write the how.

**Override rule:** If the user says "override", write the code. Reserve for mundane/boilerplate work — not core logic the professor might ask about live.

**Challenge their understanding.** Don't accept vague answers. Ask follow-up questions. Push back on incorrect assumptions.

**Ask one question at a time.** Never stack questions.

**When they say "you tell me" — tell them.** Give a direct answer with reasoning.

**Make suggestions, not demands.** They decide scope.

**Always self-review before responding.** Verify code, file paths, function names before answering. If uncertain, say so.

**Do not be sycophantic.** If they're wrong, correct them. If they're right, move on.

**Help debug when stuck.** Explain root cause, let them fix it.

---

## Teaching Style

Use the **Socratic method**: ask questions that lead to the answer. Only deliver directly when they've exhausted their reasoning or explicitly asked.

---

## Commands

```r
devtools::load_all()   # Reload package after changes
devtools::test()       # Run all unit tests
golem::run_dev()       # Run the app in development mode
```

---

## Project Overview

**Assignment:** FIN 451 Final Project — Golem App
**Due:** 2026-04-06, 10pm MST
**Package name:** GolemT

The app tells the story of energy market dynamics, co-dynamics, seasonality, volatility, and hedge ratio dynamics for a senior Risk Management / Trading audience with limited technical background.

---

## Build Progress

- **Plan A (Foundation functions):** COMPLETE as of 2026-03-30
- **Plan B (Modules + app wiring):** IN PROGRESS — starting with `mod_data.R`
- **Plan C (Complex modules):** Not started
- **Plan D (Integration):** Not started

---

## Data Sources

| Source | What | How |
|---|---|---|
| `RTL::dflong` | Continuous futures (CL, NG, BRN, HO, RB) | Pre-loaded R dataset from RTL dev package |
| FRED via `tidyquant` | CMT yields (1M–30Y) | Pre-fetched to `inst/extdata/fred_data.feather` via `Tester.qmd` |
| EIA API | PADD storage, supply, demand, refinery data | Pre-fetched to `inst/extdata/eia_data.feather` via `Tester.qmd` |

**Install RTL from GitHub (development version):**
```r
remotes::install_github("risktoollib/RTL")
```

**Commodity contracts in dflong:**
- CL01–CL36 (WTI Crude Oil)
- NG01–NG36 (Natural Gas, Henry Hub)
- BRN01–BRN36 (Brent Crude)
- HO01–HO18 (Heating Oil / ULSD Diesel)
- RB01–RB18 (RBOB Gasoline)

---

## Minimum Requirements (from assignment)

1. Behavior of the historical forward curve
2. Volatility across time to maturity and over time
3. Co-dynamics across markets
4. How seasonality impacts market dynamics
5. Hedge ratio dynamics across term structure and across markets (as a market maker)

---

## App Architecture

**Framework:** golem + Shiny + bslib
**Strategy:** Small R strategy — one function per file in `R/`
**Data flow:** `fct_load_data.R` loads all data once. `mod_data` passes a reactive list to all modules. No module fetches its own data.

**Tabs:** CL, NG, BRN, RB, HO, CMT, Co-Dynamics, Hedge Ratios

**Individual commodity tab structure (identical across all 5):**
1. Price chart with event markers
2. Market narrative text (static, per commodity)
3. Seasonality heatmap (STL decomposition on prices) — used case-by-case per commodity
4. Forward curve animation (play/pause + timeline slider)
5. Volatility surface (3D: contract month × time × rolling vol)
6. GARCH for user-selected single contract

---

## Key Design Decisions

- **`utils_contracts.R` is not needed** — commodity strings (e.g. `"CL"`) passed directly to functions
- **Data pre-fetched to feather files** — no live API calls on app load. `fct_load_data.R` reads from `inst/extdata/`
- **Seasonality heatmap** uses STL decomposition on prices (not raw returns) — used case-by-case per tab
- **GARCH** only for single selected contract (too slow for all 36). Uses `RTL::garch()` wrapper
- **Rolling beta** = hedge ratio — `series_y` is the exposure, `series_x` is the hedge instrument
- **Calculations use log returns** except CL which uses diff returns (negative prices in Apr 2020)
- **Synchronized animation** on co-dynamics tab — one play button controls PADD map + CL price chart
- **Sequential build chart** on co-dynamics tab — "Next" button adds one layer at a time
- **Plotly** for all interactive and animated charts
- **EIA PADD data is core** — PADD storage map synchronized with CL price is a key visualization
- **CMT on its own tab** — rate cycle chart replaces seasonality heatmap

---

## Key Market Events

| Date | Event | Markets |
|---|---|---|
| 2020-03-11 | COVID pandemic declared | All |
| 2020-04-20 | WTI goes negative (-$37.63) | CL |
| 2021-02-10 | Winter Storm Uri | NG, HO |
| 2022-02-24 | Russia invades Ukraine | BRN, CL, NG |
| 2022-03-16 | Fed begins 2022 hike cycle | CMT, BRN |
| 2023-07-26 | Final Fed hike | CMT |
| 2024-09-18 | Fed pivot — first cut | CMT |

*Note: Russia-Saudi price war (2020-03-06) and OPEC+ cut (2020-04-09) are in `utils_events.R` for BRN tab only — removed from CL price chart as too clustered.*

---

## SME Insights Per Commodity

**CL:** Landlocked at Cushing. April 2020 = storage capacity hit → negative prices (the defining CL event). Biannual refinery turnaround seasonality (spring/fall). Use diff returns (not log) due to negative prices.

**NG:** Closed North American market. Uri (Feb 2021) froze wellheads and pipelines simultaneously — no supply to transport. Storage cycle (inject summer, withdraw winter) drives forward curve. NG storage data in EIA feather: role = `"ng_storage"`.

**BRN:** Global benchmark. OPEC prices against Brent. Ukraine 2022 = BRN-CL spread blowout. More volatile than CL during global shocks.

**RB:** Spec switch (summer/winter gasoline) = predictable spring/fall vol spikes. COVID spring 2020 = demand collapse during normally peak season. Strong STL seasonality signal — heatmap works well for RB.

**HO:** Bimodal seasonality (heating + diesel). Ukraine 2022 hit all demand layers simultaneously.

**CMT:** Policy-driven. Rate cycle chart replaces seasonality heatmap. 2022 inversion = recession signal. Rate hikes → stronger USD → BRN demand suppression.

---

## Design Documentation

Full design docs in:
`C:\Users\soume\OneDrive\Documents\UNIVERSITY\UofA\25-26\Uni_Vault\FIN 451\`

Plans: `2026-03-28-A-foundation.md`, `2026-03-28-B-modules.md`, `2026-03-28-C-complex-modules.md`, `2026-03-28-D-integration.md`

Commodity docs: `CL - Crude Oil.md`, `NG - Natural Gas.md`, `BRN - Brent Crude.md`, `RB - RBOB Gasoline.md`, `HO - Heating Oil.md`, `CMT - Yield Curve.md`, `Co-Dynamics.md`, `Hedge Ratios.md`

---

## Testing Requirements

**Unit tests:** Every `fct_` file has a test in `tests/testthat/`. Run with `devtools::test()`.

**App tests:** Run `golem::run_dev()` after every significant change. Verify all tabs render and reactive data flow works end to end.

**Before claiming done:** `devtools::test()` must pass, then manually verify the relevant tab.

---

## R Package Dependencies

- `golem`, `shiny`, `bslib` — framework
- `plotly` — all charts
- `RTL` (dev version) — dflong + `RTL::garch()`
- `tidyquant` — FRED fetch (Tester.qmd only)
- `rugarch` — GARCH (kept as fallback)
- `feasts`, `fabletools`, `tsibble` — STL decomposition for seasonality
- `slider` — rolling window calculations
- `dplyr`, `tidyr`, `lubridate`, `arrow` — data wrangling

---

## Presentation Context

8-minute live demo, no notes or slides. Audience = non-technical senior in Risk Management / Trading. Professor may ask student to modify code live to verify understanding.
