# GolemT — Energy Markets Risk Dashboard

FIN 451 Final Project | University of Alberta | Winter 2026

A Shiny application built with the golem framework that tells the story of energy market dynamics, co-dynamics, seasonality, volatility, and hedge ratio dynamics for a Risk Management / Trading audience.

---

## Running the App

### Docker (recommended)

```bash
docker run -p 3838:3838 sefi320/golem-t:latest
```

Then open [http://localhost:3838](http://localhost:3838) in your browser.

### From Source

```r
# Install dependencies
remotes::install_github("risktoollib/RTL")

# Run
golem::run_dev()
```

---

## What the App Covers

| Tab | Content |
|---|---|
| CL | WTI Crude Oil — Cushing storage, negative prices (Apr 2020), forward curve, vol surface, GARCH |
| NG | Natural Gas — storage cycle, Winter Storm Uri, term structure |
| BRN | Brent Crude — global benchmark, Ukraine 2022, DXY overlay |
| RB | RBOB Gasoline — spec switch seasonality, COVID demand collapse |
| HO | Heating Oil — bimodal seasonality, Ukraine supply shock |
| CMT | US Treasury yields — rate cycle, yield curve inversion, Fed pivot |
| Co-Dynamics | Cushing storage vs WTI, BRN-CL spread decomposition, cross-market volatility |
| Hedge Ratios | 3-2-1 crack spread, RB-CL basis risk, NG term structure, CL curve betas |

---

## Data Sources

| Source | Data | Method |
|---|---|---|
| `RTL::dflong` | Continuous futures (CL, NG, BRN, HO, RB, HTT) | R package |
| FRED via `tidyquant` | CMT yields + DXY | Pre-fetched to `inst/extdata/fred_data.feather` |
| EIA API | PADD storage and supply data | Pre-fetched to `inst/extdata/eia_data.feather` |

---

## Deployment

GitHub Actions automatically builds and pushes a Docker image to Docker Hub on every push to `main`.

See `.github/workflows/docker-deploy.yml` for the workflow configuration.

---

## AI Context

`CLAUDE.md` contains the full project context file used during development.
