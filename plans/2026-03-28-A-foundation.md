# Plan A — Foundation: Scaffold + Utilities + Calculation Functions

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.
> **Note:** Do NOT write code for the user unless explicitly asked. Describe what to build, guide debugging, challenge understanding.

**Goal:** Establish the full golem package scaffold and all pure calculation functions with unit tests — the foundation every module depends on.

**Architecture:** golem R package using the small R strategy. One function per file in `R/`. All `fct_` files are pure functions (no Shiny dependency) and are fully unit-tested with testthat before any module work begins.

**Tech Stack:** R, golem, testthat, tidyquant, RTL, rugarch, dplyr, tidyr, scales

---

## File Map

| File | Responsibility |
|---|---|
| `R/utils_contracts.R` | Contract lists per commodity, label helpers |
| `R/utils_events.R` | Key market event dates and labels |
| `R/fct_filter_futures.R` | Filter dflong by commodity and contract range |
| `R/fct_fetch_cmt.R` | Fetch CMT yields from FRED via tidyquant |
| `R/fct_fetch_eia.R` | Fetch EIA PADD data via RTL |
| `R/fct_calc_returns.R` | Daily returns, cumulative returns, period returns |
| `R/fct_calc_rolling_vol.R` | Rolling standard deviation across contracts |
| `R/fct_calc_garch.R` | Fit GARCH(1,1) to a single return series |
| `R/fct_calc_seasonality.R` | Monthly average returns matrix for heatmap |
| `R/fct_calc_correlation.R` | Rolling correlation between two return series |
| `R/fct_calc_beta.R` | Rolling beta (hedge ratio) between two series |
| `R/fct_build_curve.R` | Extract forward curve snapshot for a given date |

---

## Task 1: Scaffold the Golem App

**Files:**
- Creates: full golem package structure in project root

- [ ] **Step 1: Open GolemT.Rproj in RStudio**

- [ ] **Step 2: Run golem scaffold in the RStudio Console**

Run `golem::create_golem()` with `path = "."` and `package_name = "GolemT"` and `open = FALSE`. Say yes if prompted to overwrite.

- [ ] **Step 3: Install all required packages**

Install: `golem`, `shiny`, `bslib`, `plotly`, `ggplot2`, `DT`, `tidyquant`, `rugarch`, `dplyr`, `tidyr`, `scales`, `testthat`

Install RTL from GitHub development version using `remotes::install_github("risktoollib/RTL")`

- [ ] **Step 4: Register dependencies in DESCRIPTION**

Use `usethis::use_package()` for each: tidyquant, RTL, plotly, ggplot2, DT, bslib, rugarch, dplyr, tidyr, scales

- [ ] **Step 5: Set up testthat**

Run `usethis::use_testthat()`

- [ ] **Step 6: Verify scaffold runs**

Run `golem::run_dev()`. Expected: blank Shiny app opens. Close it.

- [ ] **Step 7: Commit**

Stage all files. Commit message: `"feat: scaffold golem app with dependencies"`

---

## Task 2: Utility Functions

**Files:**
- Create: `R/utils_contracts.R`
- Create: `R/utils_events.R`

No unit tests needed — these are lookup tables and label helpers with no logic to break.

- [ ] **Step 1: Create `R/utils_contracts.R`**

This file should export:
- A named list or function returning the contract codes per commodity: CL (CL01–CL36), NG (NG01–NG36), BRN (BRN01–BRN36), HO (HO01–HO18), RB (RB01–RB18)
- A helper that returns the max contract number for a given commodity
- A helper that builds a display label from a contract code (e.g. "CL01" → "Crude Oil — Month 1")

- [ ] **Step 2: Create `R/utils_events.R`**

This file should export a data frame of key market events with columns: `date` (Date), `event` (character), `commodities` (character). Include all events from the design doc:
- 2020-03-06: Russia-Saudi price war
- 2020-03-11: COVID pandemic declared
- 2020-04-09: OPEC+ historic cut
- 2020-04-20: WTI goes negative
- 2021-02-10: Winter Storm Uri
- 2022-02-24: Russia invades Ukraine
- 2022-03-16: Fed begins 2022 hike cycle
- 2023-07-26: Final Fed hike
- 2024-09-18: Fed pivot — first cut

- [ ] **Step 3: Load and verify**

Run `devtools::load_all()`. Call each function/object in the console and verify the output looks correct.

- [ ] **Step 4: Commit**

Commit message: `"feat: add contract and event utility functions"`

---

## Task 3: Futures Filter Function (TDD)

**Files:**
- Create: `R/fct_filter_futures.R`
- Create: `tests/testthat/test-fct_filter_futures.R`

**What this function does:** Takes the full `RTL::dflong` dataset, a commodity code (e.g. "CL"), and optionally a contract range (e.g. 1:12), and returns a filtered long-format data frame with columns: `date`, `series` (contract code), `value` (price), `month` (contract number as integer).

- [ ] **Step 1: Write failing tests**

Create `tests/testthat/test-fct_filter_futures.R`. Tests should verify:
- Filtering for "CL" returns only CL contracts
- Output has required columns: `date`, `series`, `value`, `month`
- Contract range filter works (requesting 1:6 returns only CL01–CL06)
- No NA values in `date` or `value` columns for a known commodity

- [ ] **Step 2: Run tests to confirm they fail**

Run `devtools::test()`. Expected: FAIL — function not found.

- [ ] **Step 3: Implement `R/fct_filter_futures.R`**

Function signature: `filter_futures(data, commodity, contracts = NULL)`

Where `data` is `RTL::dflong`, `commodity` is a string like "CL", and `contracts` is an optional integer vector like `1:12`.

The function should:
1. Filter rows where `series` starts with the commodity code
2. Extract the contract number from the series name as an integer column `month`
3. Apply contract range filter if provided
4. Return the filtered data frame

- [ ] **Step 4: Run tests to confirm they pass**

Run `devtools::test()`. Expected: all PASS.

- [ ] **Step 5: Commit**

Commit message: `"feat: add filter_futures function with tests"`

---

## Task 4: CMT Fetch Function (TDD)

**Files:**
- Create: `R/fct_fetch_cmt.R`
- Create: `tests/testthat/test-fct_fetch_cmt.R`

**What this function does:** Fetches Constant Maturity Treasury yields from FRED via `tidyquant::tq_get()` for all 11 maturities (1M, 3M, 6M, 1Y, 2Y, 3Y, 5Y, 7Y, 10Y, 20Y, 30Y). Returns a long-format data frame with columns: `date`, `maturity` (character label like "10Y"), `yield` (numeric, in percent).

FRED series IDs: DGS1MO, DGS3MO, DGS6MO, DGS1, DGS2, DGS3, DGS5, DGS7, DGS10, DGS20, DGS30

- [ ] **Step 1: Write failing tests**

Tests should verify:
- Output has required columns: `date`, `maturity`, `yield`
- All 11 maturities are present in the output
- Date range filtering works (from/to arguments)
- No negative yields returned (yields can be near-zero but shouldn't be negative in this dataset)

Note: These tests make real FRED API calls. Internet required.

- [ ] **Step 2: Run tests to confirm they fail**

- [ ] **Step 3: Implement `R/fct_fetch_cmt.R`**

Function signature: `fetch_cmt(from_date, to_date = Sys.Date())`

The function should fetch all 11 FRED series, combine into long format, add human-readable maturity labels, and return the result.

- [ ] **Step 4: Run tests to confirm they pass**

- [ ] **Step 5: Commit**

Commit message: `"feat: add fetch_cmt function with FRED integration"`

---

## Task 5: EIA Fetch Function (TDD)

**Files:**
- Create: `R/fct_fetch_eia.R`
- Create: `tests/testthat/test-fct_fetch_eia.R`

**What this function does:** Fetches EIA PADD-level petroleum storage, supply, and demand data via RTL's EIA API wrapper. Returns a data frame with columns: `date`, `padd` (PADD region 1–5), `series_name` (e.g. "crude_storage"), `value` (numeric).

Requires an EIA API key — the function should accept it as a parameter with a fallback to `Sys.getenv("EIA_KEY")`.

- [ ] **Step 1: Set your EIA API key**

Get a free key at eia.gov/developer. Store it: run `usethis::edit_r_environ()` and add `EIA_KEY=your_key_here`. Restart R.

- [ ] **Step 2: Write failing tests**

Tests should verify:
- Output has required columns: `date`, `padd`, `series_name`, `value`
- All 5 PADD regions are present
- Date range filtering works
- Function errors gracefully if API key is missing (not a crash)

- [ ] **Step 3: Run tests to confirm they fail**

- [ ] **Step 4: Implement `R/fct_fetch_eia.R`**

Function signature: `fetch_eia(from_date, to_date = Sys.Date(), key = Sys.getenv("EIA_KEY"))`

Explore `RTL` documentation for the correct EIA API wrapper functions. The function should fetch PADD-level crude storage and petroleum product data.

- [ ] **Step 5: Run tests to confirm they pass**

- [ ] **Step 6: Commit**

Commit message: `"feat: add fetch_eia function with PADD data"`

---

## Task 6: Returns Calculation (TDD)

**Files:**
- Create: `R/fct_calc_returns.R`
- Create: `tests/testthat/test-fct_calc_returns.R`

**What this function does:** Takes a long-format price data frame (with `date`, `series`, `value` columns) and returns daily log returns, cumulative returns, and period total returns — grouped by series.

**Important:** For contracts where prices may approach zero or go negative (CL01 near expiry), use price differences (dollar changes) rather than log returns. The function should accept a `method` argument: `"log"` (default) or `"diff"`.

- [ ] **Step 1: Write failing tests**

Tests should verify:
- `calc_daily_returns()` adds a `daily_return` column
- Log returns are correct for known inputs (e.g. price doubles → log return ≈ 0.693)
- Diff returns are correct for known inputs
- `calc_cumulative_returns()` compounds correctly across dates
- `calc_period_returns()` returns one row per series with correct total return
- Results are grouped correctly when multiple series are present

- [ ] **Step 2: Run tests to confirm they fail**

- [ ] **Step 3: Implement `R/fct_calc_returns.R`**

Export three functions:
- `calc_daily_returns(df, method = "log")` — adds `daily_return` column
- `calc_cumulative_returns(df)` — expects `daily_return` column, adds `cumulative_return`
- `calc_period_returns(df)` — expects `daily_return` column, returns one row per series

- [ ] **Step 4: Run tests to confirm they pass**

- [ ] **Step 5: Commit**

Commit message: `"feat: add return calculation functions with tests"`

---

## Task 7: Rolling Volatility (TDD)

**Files:**
- Create: `R/fct_calc_rolling_vol.R`
- Create: `tests/testthat/test-fct_calc_rolling_vol.R`

**What this function does:** Takes a returns data frame and computes rolling standard deviation (annualized) for each series across a user-specified window. Used for the volatility surface across all 36 contracts.

- [ ] **Step 1: Write failing tests**

Tests should verify:
- Output has `rolling_vol` column
- Rolling vol is NA for the first `window - 1` observations (not enough data yet)
- Annualization is correct (multiply daily SD by sqrt(252))
- Works correctly when multiple series are present
- Larger window produces smoother output than smaller window (compare SD of rolling_vol values)

- [ ] **Step 2: Run tests to confirm they fail**

- [ ] **Step 3: Implement `R/fct_calc_rolling_vol.R`**

Function signature: `calc_rolling_vol(returns_df, window = 30)`

Uses `slider` or `zoo::rollapply` for rolling window computation.

- [ ] **Step 4: Run tests to confirm they pass**

- [ ] **Step 5: Commit**

Commit message: `"feat: add rolling volatility function with tests"`

---

## Task 8: GARCH Function (TDD)

**Files:**
- Create: `R/fct_calc_garch.R`
- Create: `tests/testthat/test-fct_calc_garch.R`

**What this function does:** Fits a GARCH(1,1) model to a single return series using `rugarch`. Returns a data frame with `date` and `conditional_vol` (the fitted conditional standard deviation, annualized).

- [ ] **Step 1: Write failing tests**

Tests should verify:
- Output has columns: `date`, `conditional_vol`
- `conditional_vol` is always positive
- Output has same number of rows as input
- Function handles series with low variance without crashing (use `tryCatch` internally)

- [ ] **Step 2: Run tests to confirm they fail**

- [ ] **Step 3: Implement `R/fct_calc_garch.R`**

Function signature: `calc_garch(returns_df, series_name)`

Where `returns_df` has `date`, `series`, `daily_return` columns and `series_name` selects which series to fit. Use `rugarch::ugarchspec()` with GARCH(1,1) and normal distribution. Fit with `rugarch::ugarchfit()`. Extract conditional sigma with `rugarch::sigma()` and annualize.

- [ ] **Step 4: Run tests to confirm they pass**

- [ ] **Step 5: Commit**

Commit message: `"feat: add GARCH conditional volatility function with tests"`

---

## Task 9: Seasonality Function (TDD)

**Files:**
- Create: `R/fct_calc_seasonality.R`
- Create: `tests/testthat/test-fct_calc_seasonality.R`

**What this function does:** Takes a returns data frame for a single series and returns a matrix of average monthly returns — rows are years, columns are months (1–12). This is the input to the seasonality heatmap.

- [ ] **Step 1: Write failing tests**

Tests should verify:
- Output is a matrix with 12 columns (months)
- Row names are years as characters
- Values are average returns (numeric), not counts
- A known input produces a known output (e.g. all returns = 0.01 in January → January column average = 0.01)

- [ ] **Step 2: Run tests to confirm they fail**

- [ ] **Step 3: Implement `R/fct_calc_seasonality.R`**

Function signature: `calc_seasonality(returns_df, series_name)`

Groups by year and month, computes mean return, pivots to wide format (years × months matrix).

- [ ] **Step 4: Run tests to confirm they pass**

- [ ] **Step 5: Commit**

Commit message: `"feat: add seasonality matrix function with tests"`

---

## Task 10: Rolling Correlation (TDD)

**Files:**
- Create: `R/fct_calc_correlation.R`
- Create: `tests/testthat/test-fct_calc_correlation.R`

**What this function does:** Takes a returns data frame with multiple series and computes the rolling pairwise correlation between two specified series over a given window. Returns a data frame with `date` and `rolling_correlation`.

- [ ] **Step 1: Write failing tests**

Tests should verify:
- Output has columns: `date`, `rolling_correlation`
- Values are bounded between -1 and 1
- Perfectly correlated series produces correlation = 1.0
- Perfectly anti-correlated series produces correlation = -1.0
- NA values appear for first `window - 1` rows

- [ ] **Step 2: Run tests to confirm they fail**

- [ ] **Step 3: Implement `R/fct_calc_correlation.R`**

Function signature: `calc_rolling_correlation(returns_df, series_a, series_b, window = 60)`

Pivots to wide format, applies rolling correlation using `slider` or `zoo::rollapply`.

- [ ] **Step 4: Run tests to confirm they pass**

- [ ] **Step 5: Commit**

Commit message: `"feat: add rolling correlation function with tests"`

---

## Task 11: Rolling Beta (TDD)

**Files:**
- Create: `R/fct_calc_beta.R`
- Create: `tests/testthat/test-fct_calc_beta.R`

**What this function does:** Computes rolling beta from a regression of `series_y` (exposure) on `series_x` (hedge instrument). Beta is the slope coefficient. Returns a data frame with `date` and `rolling_beta`.

- [ ] **Step 1: Write failing tests**

Tests should verify:
- Output has columns: `date`, `rolling_beta`
- When series_x and series_y are identical, beta = 1.0
- When series_y = 2 × series_x, beta = 2.0
- NA values for first `window - 1` rows
- Beta changes over time when the relationship between series changes

- [ ] **Step 2: Run tests to confirm they fail**

- [ ] **Step 3: Implement `R/fct_calc_beta.R`**

Function signature: `calc_rolling_beta(returns_df, series_x, series_y, window = 60)`

For each rolling window, fit `lm(series_y ~ series_x)` and extract the slope coefficient.

- [ ] **Step 4: Run tests to confirm they pass**

- [ ] **Step 5: Commit**

Commit message: `"feat: add rolling beta (hedge ratio) function with tests"`

---

## Task 12: Forward Curve Builder (TDD)

**Files:**
- Create: `R/fct_build_curve.R`
- Create: `tests/testthat/test-fct_build_curve.R`

**What this function does:** Takes the filtered futures data frame and a specific date, returns the forward curve for that date — a data frame with `month` (1 to max contract number) and `price` for each contract available on that date.

- [ ] **Step 1: Write failing tests**

Tests should verify:
- Output has columns: `month`, `price`
- Output is ordered by `month` ascending
- Requesting a date with no data returns an empty data frame (not an error)
- Output contains only the requested date

- [ ] **Step 2: Run tests to confirm they fail**

- [ ] **Step 3: Implement `R/fct_build_curve.R`**

Function signature: `build_curve(futures_df, target_date)`

Filters the futures data frame to `date == target_date`, selects `month` and `value` (renamed to `price`), orders by `month`.

- [ ] **Step 4: Run tests to confirm they pass**

- [ ] **Step 5: Run full test suite**

Run `devtools::test()`. Expected: all tests across all files pass.

- [ ] **Step 6: Commit**

Commit message: `"feat: add forward curve builder with tests — Plan A complete"`

---

## Plan A Complete

All foundation functions are built and tested. Before moving to Plan B, verify:
- `devtools::test()` passes with zero failures
- `devtools::load_all()` loads without errors or warnings
- All functions can be called manually in the console with `RTL::dflong` as input without crashing
