#' NG Module UI
#' @param id Module namespace id

mod_ng_ui <- function(id) {
  ns <- NS(id)
  div(
    style = "display: flex; flex-direction: column; gap: 20px; padding: 24px;",
    bslib::card(
      bslib::card_header("Price History — Natural Gas (Henry Hub)"),
      plotly::plotlyOutput(ns("price_chart"))
    ),
    bslib::card(
      bslib::card_header("Market Narrative"),
      uiOutput(ns("narrative"))
    ),
    bslib::card(
      bslib::card_header("EIA Storage vs 5-Year Average"),
      plotly::plotlyOutput(ns("eia_storage_chart"))
    ),
    bslib::card(
      bslib::card_header("Return Seasonality"),
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

#' NG Module Server
#' @param id Module namespace id

mod_ng_server <- function(id,app_data) {
  moduleServer(id, function(input, output, session) {

    output$price_chart <- plotly::renderPlotly(
      plot_price(
        filter_futures(app_data()$prices, "NG", contracts = 1)))

    output$narrative <- renderUI(tags$ul(
      tags$li("Henry Hub (Louisiana) is a purely North American market. Unlike crude, there is no meaningful LNG arbitrage to global prices in this dataset — North American supply and demand fully determines price."),
      tags$li("Storage is the dominant driver: gas is injected in summer and withdrawn in winter, creating a steep seasonal forward curve. The storage chart shows how deviations from the 5-year average precede price moves."),
      tags$li("Winter Storm Uri (Feb 2021): wellheads AND pipelines froze simultaneously — both supply and transport failed at the same time. Spot prices spiked over 10x. NG and HO became briefly correlated as heating demand surged."),
      tags$li("Natural gas is the highest-volatility contract in the energy complex. A closed market plus extreme weather sensitivity means tail moves are larger and more frequent than crude."),
      tags$li("The forward curve animation shows the injection/withdrawal cycle embedded in the curve shape — steep contango in summer, backwardation into winter withdrawal season.")
    ))

    output$eia_storage_chart <- plotly::renderPlotly(
      plot_storage_seasonality(app_data()$eia_data, role = "ng_storage", y_label = "Bcf")
    )

    output$seasonality_heatmap <- plotly::renderPlotly(
      plot_seasonality(
        calc_seasonality(
          filter_futures(app_data()$prices,contracts = 1),
          "NG")))

    output$curve_animation <- shiny::renderImage({
      list(src = app_sys("extdata/NG_curve.gif"), contentType = "image/gif")
    }, deleteFile = FALSE)

    outputOptions(output, "curve_animation", suspendWhenHidden = FALSE)


    output$vol_surface <- plotly::renderPlotly(
      plot_vol_surface(app_data()$prices, "NG", method = "log",
                       start = "2024-01-01", end = "2024-03-26"))


    output$garch_chart <- shiny::renderPlot(calc_garch(
      calc_daily_returns(
        filter_futures(
          app_data()$prices,
          cmdty = "NG",
          contracts = input$contract_select)) %>%
        dplyr::filter(
          date >= as.Date("2019-01-01"),
          date <= as.Date("2023-07-31")),
      series_name = paste0("NG0", input$contract_select)))

  })
}
