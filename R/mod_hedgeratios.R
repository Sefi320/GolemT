#' Hedge Ratios Module UI
#' @param id Module namespace id
#' @export
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
      plotly::plotlyOutput(ns("rb_cl_beta"))
    ),
    bslib::card(
      bslib::card_header("NG01-NG06 Rolling Beta — Uri 2021"),
      plotly::plotlyOutput(ns("ng_beta"))
    ),
    bslib::card(
      bslib::card_header("CL Term Structure Rolling Betas vs CL01"),
      plotly::plotlyOutput(ns("cl_term_beta"))
    )
  )
}

#' Hedge Ratios Module Server
#' @param id Module namespace id
#' @param app_data Reactive data list from mod_data_server
#' @export
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

    # --- Section 1: RB-CL rolling beta ---
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
