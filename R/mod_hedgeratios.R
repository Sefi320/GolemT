#' Hedge Ratios Module UI
#' @param id Module namespace id

mod_hedgeratios_ui <- function(id) {
  ns <- NS(id)
  div(
    style = "display: flex; flex-direction: column; gap: 20px; padding: 24px;",

    bslib::card(
      bslib::card_header("Controls"),
      shiny::sliderInput(
        ns("window"),
        label = "Rolling Window (days)",
        min   = 30, max = 252, value = 60, step = 30,
        width = "300px"
      )
    ),
    bslib::card(
      bslib::card_header("RB-CL Rolling Beta — Single Instrument Hedge Failure"),
      plotly::plotlyOutput(ns("rb_cl_beta")),
      tags$ul(style = "margin-top: 12px;",
        tags$li("RBOB gasoline is a refined product of crude oil — under normal conditions, RB and CL move together and the hedge ratio (beta) is stable near 1."),
        tags$li("COVID broke this relationship: demand for refined products (driving) collapsed faster than crude demand, while CL was simultaneously hit by a storage crisis. RB did not go negative; CL did. The two markets temporarily decoupled."),
        tags$li("This is basis risk in practice — the hedge instrument and the exposure stopped moving together precisely when the hedge was most needed.")
      )
    ),
    bslib::card(
      bslib::card_header("NG01-NG06 Rolling Beta — Uri 2021"),
      plotly::plotlyOutput(ns("ng_beta")),
      tags$ul(style = "margin-top: 12px;",
        tags$li("The rolling beta between NG01 and NG06 is highly unstable — it spends extended periods near zero, meaning the front contract provides little to no hedging value for a deferred position. A fixed hedge ratio assumption is not supported by this data."),
        tags$li("Notable periods: beta collapsed through mid-2020 into early 2021; recovered partially around Uri (Feb 2021) and the European gas crisis (Oct 2021) when systemic shocks repriced the full curve; then declined again through 2022."),
        tags$li("There is no reliable cross-commodity hedge for natural gas. Alternatives used in practice include weather derivatives (degree-day contracts) and power derivatives, which address the demand drivers directly rather than proxying through another energy commodity.")
      )
    ),
    bslib::card(
      bslib::card_header("3-2-1 Crack Spread — Refinery Margin"),
      plotly::plotlyOutput(ns("crack_spread")),
      tags$ul(style = "margin-top: 12px;",
        tags$li("The 3-2-1 crack spread estimates the gross refining margin: for every 3 barrels of crude processed, a refinery yields approximately 2 barrels of gasoline (RB) and 1 barrel of heating oil (HO). The spread = (2\u00d7RB + 1\u00d7HO \u2212 3\u00d7CL) / 3, with RB and HO converted from USD/gallon to USD/barrel (\u00d742)."),
        tags$li("A refiner is structurally long crude and short refined products. Hedging the crack spread locks in the margin: sell RB and HO futures, buy CL futures in a 2:1:3 ratio."),
        tags$li("Crack spread volatility is driven by demand shocks (COVID spring 2020 collapsed it), supply disruptions (Ukraine 2022 spiked it as European refined product supply tightened), and seasonal refinery turnarounds.")
      )
    ),
    bslib::card(
      bslib::card_header("CL Term Structure Rolling Betas vs CL01"),
      plotly::plotlyOutput(ns("cl_term_beta")),
      tags$ul(style = "margin-top: 12px;",
        tags$li("Near-term contracts (CL02, CL03) carry betas close to 1 — they move almost in lockstep with the front month. Longer-dated contracts (CL12, CL24) have lower betas — they are more insulated from front-month supply and storage shocks."),
        tags$li("April 2020: all betas collapsed to near zero simultaneously — including CL24. When CL01 goes negative and produces extreme returns, the beta regression breaks down across the entire curve, not just the front end."),
        tags$li("The appropriate hedge ratio varies across the curve. Using a single fixed ratio to hedge across maturities introduces systematic error — particularly in volatile, event-driven markets.")
      )
    )
  )
}

#' Hedge Ratios Module Server
#' @param id Module namespace id
#' @param app_data Reactive data list from mod_data_server

mod_hedgeratios_server <- function(id, app_data) {
  moduleServer(id, function(input, output, session) {


    rb_cl_returns <- shiny::reactive({
      dplyr::bind_rows(
        filter_futures(app_data()$prices, "RB", contracts = 1) %>% calc_daily_returns(),
        filter_futures(app_data()$prices, "CL", contracts = 1) %>% calc_daily_returns(method = "diff")
      )
    })

    ng_returns <- shiny::reactive({
      dplyr::bind_rows(
        filter_futures(app_data()$prices, "NG", contracts = 1) %>% calc_daily_returns(),
        filter_futures(app_data()$prices, "NG", contracts = 6) %>% calc_daily_returns()
      ) %>%
        dplyr::filter(date >= as.Date("2020-01-01"), date <= as.Date("2022-06-30"))
    })

    cl_returns <- shiny::reactive({
      filter_futures(app_data()$prices, "CL", contracts = c(1, 2, 3, 6, 12, 24)) %>%
        calc_daily_returns(method = "diff")
    })


    output$crack_spread <- plotly::renderPlotly({

      cs <- calc_crack_spread(app_data()$prices)

      covid_date  <- as.Date("2020-03-11")
      ukraine_date <- as.Date("2022-02-24")

      plotly::plot_ly(cs, x = ~date, y = ~crack_spread,
                      type = "scatter", mode = "lines",
                      name = "3-2-1 Crack Spread",
                      line = list(color = "steelblue", width = 2)) %>%
        plotly::layout(
          shapes = list(
            list(type = "line", x0 = covid_date, x1 = covid_date,
                 y0 = 0, y1 = 1, yref = "paper",
                 line = list(color = "firebrick", dash = "dash", width = 1)),
            list(type = "line", x0 = ukraine_date, x1 = ukraine_date,
                 y0 = 0, y1 = 1, yref = "paper",
                 line = list(color = "firebrick", dash = "dash", width = 1))
          ),
          annotations = list(
            list(x = covid_date, y = 1, yref = "paper",
                 text = "COVID declared", showarrow = FALSE,
                 textangle = -90, xanchor = "right",
                 font = list(size = 9, color = "firebrick")),
            list(x = ukraine_date, y = 1, yref = "paper",
                 text = "Russia invades Ukraine", showarrow = FALSE,
                 textangle = -90, xanchor = "right",
                 font = list(size = 9, color = "firebrick"))
          ),
          xaxis     = list(title = ""),
          yaxis     = list(title = "Crack Spread (USD/bbl)"),
          hovermode = "x unified"
        )
    })


    output$rb_cl_beta <- plotly::renderPlotly({

      beta <- calc_rolling_beta(rb_cl_returns(),
                                series_x = "CL01",
                                series_y = "RB01",
                                window   = input$window)

      covid_date  <- as.Date("2020-03-11")
      neg_date    <- as.Date("2020-04-20")

      plotly::plot_ly(beta, x = ~date, y = ~rolling_beta,
                      type = "scatter", mode = "lines",
                      name = "RB01 vs CL01 Beta",
                      line = list(color = "steelblue", width = 2)) %>%
        plotly::layout(
          shapes = list(
            list(type = "line", x0 = covid_date, x1 = covid_date,
                 y0 = 0, y1 = 1, yref = "paper",
                 line = list(color = "firebrick", dash = "dash", width = 1)),
            list(type = "line", x0 = neg_date, x1 = neg_date,
                 y0 = 0, y1 = 1, yref = "paper",
                 line = list(color = "firebrick", dash = "dash", width = 1))
          ),
          annotations = list(
            list(x = covid_date, y = 1, yref = "paper",
                 text = "COVID declared", showarrow = FALSE,
                 textangle = -90, xanchor = "right",
                 font = list(size = 9, color = "firebrick")),
            list(x = neg_date, y = 1, yref = "paper",
                 text = "WTI goes negative", showarrow = FALSE,
                 textangle = -90, xanchor = "right",
                 font = list(size = 9, color = "firebrick"))
          ),
          xaxis     = list(title = ""),
          yaxis     = list(title = "Rolling Beta"),
          hovermode = "x unified"
        )
    })


    output$ng_beta <- plotly::renderPlotly({

      beta <- calc_rolling_beta(ng_returns(),
                                series_x = "NG01",
                                series_y = "NG06",
                                window   = input$window)

      uri_date <- as.Date("2021-02-10")

      plotly::plot_ly(beta, x = ~date, y = ~rolling_beta,
                      type = "scatter", mode = "lines",
                      name = "NG06 vs NG01 Beta",
                      line = list(color = "steelblue", width = 2)) %>%
        plotly::layout(
          shapes = list(
            list(type = "line", x0 = uri_date, x1 = uri_date,
                 y0 = 0, y1 = 1, yref = "paper",
                 line = list(color = "firebrick", dash = "dash", width = 1))
          ),
          annotations = list(
            list(x = uri_date, y = 1, yref = "paper",
                 text = "Winter Storm Uri", showarrow = FALSE,
                 textangle = -90, xanchor = "right",
                 font = list(size = 9, color = "firebrick"))
          ),
          xaxis     = list(title = ""),
          yaxis     = list(title = "Rolling Beta"),
          hovermode = "x unified"
        )
    })


    output$cl_term_beta <- plotly::renderPlotly({

      deferred <- c("CL02", "CL03", "CL06", "CL12", "CL24")

      betas <- purrr::map_dfr(deferred, function(contract) {
        calc_rolling_beta(cl_returns(),
                          series_x = "CL01",
                          series_y = contract,
                          window   = input$window) %>%
          dplyr::mutate(contract = contract)
      })

      neg_date <- as.Date("2020-04-20")

      plotly::plot_ly(betas, x = ~date, y = ~rolling_beta,
                      color = ~contract, type = "scatter", mode = "lines") %>%
        plotly::layout(
          shapes = list(
            list(type = "line", x0 = neg_date, x1 = neg_date,
                 y0 = 0, y1 = 1, yref = "paper",
                 line = list(color = "firebrick", dash = "dash", width = 1))
          ),
          annotations = list(
            list(x = neg_date, y = 1, yref = "paper",
                 text = "WTI goes negative", showarrow = FALSE,
                 textangle = -90, xanchor = "right",
                 font = list(size = 9, color = "firebrick"))
          ),
          xaxis     = list(title = ""),
          yaxis     = list(title = "Rolling Beta vs CL01"),
          hovermode = "x unified"
        )
    })

  })
}
