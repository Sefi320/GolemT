# GolemT App Styling — Design Spec

**Date:** 2026-03-30
**Status:** Approved — tab theme TBD (iterate during Plan B)

---

## Goal

Style the GolemT app to look professional and visually striking for an 8-minute live demo to a senior Risk Management / Trading audience. The visual design should signal "this is a real product" — not a student Shiny project.

---

## Cover Page

A full-screen hero panel as the first `nav_panel` in the navbar (label: "Home" or hidden label).

**Background:** `app_cover.jpg` (aerial refinery at dusk, stored in `inst/app/www/`) with a `rgba(0,0,0,0.55)` dark overlay so text is readable against any part of the image.

**Content (centered, white text):**
- Eyebrow label: `FIN 451 — Final Project` (small caps, muted white, wide letter-spacing)
- Title: `Energy Market Dynamics` (large, bold, white)
- Tagline: *"From Cushing storage limits to OPEC shocks — how energy markets price risk across the curve."* (muted white, readable weight)
- CTA button: `Explore Markets →` (navy `#1e40af` background, white text)

**No** requirement badges or table-of-contents elements on the cover.

**Implementation:** Use inline CSS on a `div` with `background-image: url('www/app_cover.jpg')`, `background-size: cover`, `background-position: center`. Overlay via a nested `div` with `position: absolute` and `background: rgba(0,0,0,0.55)`.

---

## Overall Theme

**Framework:** `bslib::bs_theme()` with a dark base.

**Direction:** Mid-dark slate — not pitch black, not white. Feels continuous with the dark cover.

**Color palette (to be refined during implementation):**

| Role | Value | Notes |
|---|---|---|
| Page background | `#1e293b` | Tailwind slate-800 |
| Card background | `#273548` | Slightly lighter than page |
| Navbar background | `#0f172a` | Slate-900, darkest element |
| Primary text | `#cbd5e1` | Slate-300, readable on dark |
| Label / secondary text | `#94a3b8` | Slate-400 |
| Active tab / accent | `#3b82f6` | Blue-500 |
| Chart primary series | `#3b82f6` | Blue |
| Chart secondary series | `#60a5fa` | Blue-400 |
| Volatility / alert | `#f59e0b` | Amber |
| Positive moves | `#10b981` | Emerald |
| Negative moves | `#f43f5e` | Rose |

> **Note:** Exact values to be iterated live during Plan B. The direction is slate mid-dark — adjust lightness up or down based on how charts render against the background.

---

## Layout

**Structure:** Full-width cards stacked vertically within each tab. No dashboard grid. No sub-tabs. No sticky header.

**Rationale:** The app tells a sequential story per commodity — price history → narrative → seasonality → forward curve → volatility → GARCH. Top-to-bottom scroll IS the presentation flow. When demoing GARCH, the price chart is scrolled away — full audience attention on the active chart.

**Page padding:** 24px horizontal, 20px vertical gap between cards.

---

## Cards

Each chart/section lives in a `bslib::card()`.

**Style:**
- Background: `#273548`
- No border
- `box-shadow: 0 2px 12px rgba(0,0,0,0.25)`
- Border radius: `8px`
- Padding: `14px`

**Card header:**
- Font: small, bold, uppercase, wide letter-spacing
- Color: `#94a3b8` (slate-400)
- Bottom border: `1px solid #334155`
- Bottom margin before chart: `8px`

---

## Navbar

- Background: `#0f172a` (slate-900)
- Active tab: blue underline `#3b82f6`, text `#60a5fa`
- Inactive tabs: `#64748b`
- App title: `GolemT — Energy Market Dynamics`, white, bold

---

## No Photos Inside Tabs

Photos are cover-only. Inside tabs, charts are the content. No commodity banner images.

---

## Implementation Notes

- Apply theme via `bslib::bs_theme()` in `app_ui.R`
- Cover page is a `bslib::nav_panel()` with custom HTML/CSS — not a standard content tab
- All commodity tabs use `bslib::card()` wrappers around each `plotlyOutput`
- Plotly chart background should be set to `transparent` or match card color so charts feel embedded, not pasted in
- Font defaults from bslib are acceptable — no custom font needed
