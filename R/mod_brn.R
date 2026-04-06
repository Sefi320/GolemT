#' BRN Module UI
#' @param id Module namespace id

mod_brn_ui <- function(id) {
  ns <- NS(id)
  div(
    style = "display: flex; flex-direction: column; gap: 20px; padding: 24px;",
    bslib::card(
      bslib::card_header("Price History — Brent Crude"),
      plotly::plotlyOutput(ns("price_chart"))
    ),
    bslib::card(
      bslib::card_header("Market Narrative"),
      uiOutput(ns("narrative"))
    ),
    bslib::card(
      bslib::card_header("Seasonality"),
      plotly::plotlyOutput(ns("seasonality_heatmap"))
    ),
    bslib::card(
      bslib::card_header("Forward Curve"),
      shiny::imageOutput(ns("curve_animation"))
    ),
    bslib::card(
      bslib::card_header("Volatility Surface"),
      plotly::plotlyOutput(ns("vol_surface"))
    ),
    bslib::card(
      bslib::card_header("GARCH"),
      selectInput(ns("contract_select"), "Contract",
                  choices =  1:9),
      shiny::plotOutput(ns("garch_chart"))
    )
  )
}

#' BRN Module Server
#' @param id Module namespace id

mod_brn_server <- function(id,app_data) {
  moduleServer(id, function(input, output, session) {

    output$price_chart <- plotly::renderPlotly(
      plot_price(
        filter_futures(app_data()$prices, "BRN", contracts = 1),
        cmdty = "BRN",
        dxy = dplyr::filter(app_data()$cmt_data, role == "dxy")
      ))

    output$narrative <- renderUI(tags$ul(
      tags$li("Brent is the global crude benchmark. OPEC+ sets production policy in reference to Brent, not WTI. It is more sensitive to geopolitical supply shocks than landlocked WTI."),
      tags$li("Russia-Ukraine (Feb 2022): European buyers scrambled for non-Russian barrels. The BRN-CL spread blew out to record levels — the full story is in the Co-Dynamics tab."),
      tags$li("Rate hikes (2022) strengthened the USD, suppressing dollar-denominated oil demand. The DXY overlay on the price chart shows this channel; the CMT tab shows the rate policy driver."),
      tags$li("BRN reacts faster and more severely than WTI during global supply shocks because it prices seaborne crude accessible to all markets, not just the US interior."),
      tags$li("The seasonality heatmap shows a mild summer demand peak and fall refinery maintenance trough — weaker seasonal signal than RB or NG, because global macro factors dominate.")
    ))

    output$seasonality_heatmap <- plotly::renderPlotly(
      plot_seasonality(
        calc_seasonality(
          filter_futures(app_data()$prices,contracts = 1),
          "BRN")))

    output$curve_animation <- shiny::renderImage({
      list(src = app_sys("extdata/brn_curve.gif"), contentType = "image/gif")
    }, deleteFile = FALSE)

    outputOptions(output, "curve_animation", suspendWhenHidden = FALSE)

    output$vol_surface <- plotly::renderPlotly(
      plot_vol_surface(app_data()$prices, "BRN", method = "log",
                       start = "2024-01-01", end = "2024-03-26"))

    output$garch_chart <- shiny::renderPlot(calc_garch(
      calc_daily_returns(
        filter_futures(
          app_data()$prices,
          cmdty = "BRN",
          contracts = input$contract_select), method = "log") %>%
        dplyr::filter(
          date >= as.Date("2019-01-01"),
          date <= as.Date("2023-07-31")),
      series_name = paste0("BRN0", input$contract_select)))
  })
}
