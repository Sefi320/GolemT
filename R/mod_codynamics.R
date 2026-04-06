#' Co-Dynamics Module UI
#' @param id Module namespace id

mod_codynamics_ui <- function(id) {
  ns <- NS(id)
  div(
    style = "display: flex; flex-direction: column; gap: 20px; padding: 24px;",


    bslib::card(
      bslib::card_header("Cushing Storage vs WTI Price — COVID 2020"),
      plotly::plotlyOutput(ns("padd2_cl_chart")),
      tags$ul(style = "margin-top: 12px;",
        tags$li("PADD 2 is the Cushing, Oklahoma storage hub — the physical delivery point for WTI futures. When storage fills, sellers have nowhere to deliver physical barrels."),
        tags$li("COVID demand collapse (March 2020) drove inventory to capacity limits. By April 20, front-month WTI hit \u221237.63/bbl: sellers were paying buyers to take delivery. This chart shows the direct causal link between physical inventory and financial price.")
      )
    ),


    bslib::card(
      bslib::card_header("BRN-CL Spread — Ukraine 2022"),
      plotly::plotlyOutput(ns("brn_cl_spread")),
      tags$ul(style = "margin-top: 12px;",
        tags$li("The raw spread (BRN \u2212 CL) conflates the true Brent premium with the cost to move a barrel from landlocked Cushing to Houston export terminals."),
        tags$li("HTT is the WTI Houston \u2212 WTI Cushing differential \u2014 it captures pipeline transport friction. Subtracting HTT isolates the true Brent premium: BRN \u2212 (CL + HTT)."),
        tags$li("Russia\u2019s invasion (February 2022) drove a sharp spread blowout. Brent \u2014 the global benchmark \u2014 repriced faster and higher as markets priced in European supply disruption and sanctions risk.")
      )
    ),


    bslib::card(
      bslib::card_header("Rolling Window"),
      shiny::sliderInput(
        ns("rolling_window"),
        label  = "Rolling Window (days)",
        min    = 30,
        max    = 90,
        value  = 30,
        step   = 10,
        width  = "300px"
      )
    ),

    bslib::card(
      bslib::card_header("BRN vs NG Rolling Volatility — Ukraine 2022"),
      plotly::plotlyOutput(ns("brn_ng_vol")),
      tags$ul(style = "margin-top: 12px;",
        tags$li("Russia\u2019s invasion simultaneously disrupted global crude supply (Brent) and European natural gas pipelines \u2014 two separate transmission channels, one geopolitical shock."),
        tags$li("NG volatility surged harder than BRN: Europe had heavy pipeline dependency on Russia with limited alternative supply. The vol spike reflects illiquidity and repricing of a structurally constrained market."),
        tags$li("Adjust the rolling window to see how the shock propagated \u2014 vol peaked within weeks, then mean-reverted as markets absorbed the new supply reality.")
      )
    ),

  )
}

#' Co-Dynamics Module Server
#' @param id Module namespace id
#' @param app_data Reactive data list from mod_data_server


mod_codynamics_server <- function(id, app_data) {
  moduleServer(id, function(input, output, session) {


    output$padd2_cl_chart <- plotly::renderPlotly({

      padd2 <- app_data()$eia_data %>%
        dplyr::filter(role == "padd2_crude_stocks",
                      date >= as.Date("2019-01-01"),
                      date <= as.Date("2021-06-30"))

      cl <- filter_futures(app_data()$prices, "CL", contracts = 1) %>%
        dplyr::filter(date >= as.Date("2019-01-01"), date <= as.Date("2021-06-30")) %>%
        dplyr::select(date, cl = value)

      covid_date <- as.Date("2020-03-11")
      neg_date   <- as.Date("2020-04-20")

      plotly::plot_ly() %>%
        plotly::add_lines(
          data = padd2, x = ~date, y = ~value,
          name = "PADD 2 Crude Stocks (kbbl)",
          yaxis = "y1",
          line  = list(color = "steelblue", width = 2)
        ) %>%
        plotly::add_lines(
          data = cl, x = ~date, y = ~cl,
          name = "CL01 (USD/bbl)",
          yaxis = "y2",
          line  = list(color = "orange", width = 2)
        ) %>%
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
          xaxis  = list(title = ""),
          yaxis  = list(title = "PADD 2 Crude Stocks (kbbl)", side = "left"),
          yaxis2 = list(title = "CL01 Price (USD/bbl)", side = "right",
                        overlaying = "y"),
          hovermode = "x unified",
          legend    = list(orientation = "h", y = -0.15)
        )
    })


    output$brn_cl_spread <- plotly::renderPlotly({

      spread <- calc_htt_spread(app_data()$prices) %>%
        dplyr::filter(date >= as.Date("2021-01-01"), date <= as.Date("2023-12-31"))

      ukraine_date <- as.Date("2022-02-24")

      plotly::plot_ly(spread, x = ~date) %>%
        plotly::add_trace(
          y        = ~brn_cl_adj,
          type     = "scatter", mode = "lines",
          name     = "BRN \u2212 (CL + HTT)",
          line     = list(color = "steelblue", width = 2)
        ) %>%
        plotly::add_trace(
          y         = ~brn_cl_raw,
          type      = "scatter", mode = "lines",
          name      = "BRN \u2212 CL (raw)",
          fill      = "tonexty",
          fillcolor = "rgba(150, 150, 150, 0.25)",
          line      = list(color = "grey", width = 2)
        ) %>%
        plotly::layout(
          shapes = list(
            list(type = "line", x0 = ukraine_date, x1 = ukraine_date,
                 y0 = 0, y1 = 1, yref = "paper",
                 line = list(color = "firebrick", dash = "dash", width = 1))
          ),
          annotations = list(
            list(x = ukraine_date, y = 1, yref = "paper",
                 text = "Russia invades Ukraine", showarrow = FALSE,
                 textangle = -90, xanchor = "right",
                 font = list(size = 9, color = "firebrick"))
          ),
          xaxis     = list(title = ""),
          yaxis     = list(title = "Spread (USD/bbl)"),
          hovermode = "x unified",
          legend    = list(orientation = "h", y = -0.15)
        )
    })


    output$brn_ng_vol <- plotly::renderPlotly({

      brn_ret <- filter_futures(app_data()$prices, "BRN", contracts = 1) %>%
        calc_daily_returns()

      ng_ret <- filter_futures(app_data()$prices, "NG", contracts = 1) %>%
        calc_daily_returns()

      vol <- dplyr::bind_rows(brn_ret, ng_ret) %>%
        calc_rolling_vol(window = input$rolling_window) %>%
        dplyr::filter(date >= as.Date("2021-01-01"), date <= as.Date("2023-12-31"))

      ukraine_date <- as.Date("2022-02-24")

      plotly::plot_ly(vol, x = ~date, y = ~rolling_vol,
                      color = ~series, type = "scatter", mode = "lines",
                      colors = c("BRN01" = "orange", "NG01" = "steelblue")) %>%
        plotly::layout(
          shapes = list(
            list(type = "line", x0 = ukraine_date, x1 = ukraine_date,
                 y0 = 0, y1 = 1, yref = "paper",
                 line = list(color = "firebrick", dash = "dash", width = 1))
          ),
          annotations = list(
            list(x = ukraine_date, y = 1, yref = "paper",
                 text = "Russia invades Ukraine", showarrow = FALSE,
                 textangle = -90, xanchor = "right",
                 font = list(size = 9, color = "firebrick"))
          ),
          xaxis     = list(title = ""),
          yaxis     = list(title = "Annualised Volatility"),
          hovermode = "x unified"
        )
    })



  })
}
