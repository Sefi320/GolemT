#' RB Module UI
#' @param id Module namespace id

mod_rb_ui <- function(id) {
  ns <- NS(id)
  div(
    style = "display: flex; flex-direction: column; gap: 20px; padding: 24px;",
    bslib::card(
      bslib::card_header("Price History — RBOB Gasoline"),
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
                  choices = 1:9),
      shiny::plotOutput(ns("garch_chart"))
    )
  )
}

#' RB Module Server
#' @param id Module namespace id

mod_rb_server <- function(id,app_data) {
  moduleServer(id, function(input, output, session) {

    output$price_chart <- plotly::renderPlotly(
      plot_price(
        filter_futures(app_data()$prices, cmdty = "RB", contracts = 1)))

    output$narrative <- renderUI(tags$ul(
      tags$li("RBOB gasoline is the reformulated blendstock used to produce summer-grade gasoline. A mandatory spec switch (summer/winter blend) in spring and fall creates predictable volatility spikes around the transition."),
      tags$li("COVID spring 2020: demand collapsed exactly during the normally peak driving season. The seasonality heatmap shows an unprecedented March-April trough where a seasonal high should be — a stark anomaly."),
      tags$li("RB has the strongest and most consistent seasonal signal in the petroleum complex. The STL decomposition captures it clearly — spring peaks and fall troughs are visible year after year."),
      tags$li("The crack spread (RB minus CL) captures the refinery margin for gasoline production. It widens when driving demand outpaces crude supply and compresses during demand destruction events."),
      tags$li("Forward curve shape: typically in contango into winter (low demand) and backwardation into summer (peak demand). The animation shows this seasonal shift in structure.")
    ))


    output$seasonality_heatmap <- plotly::renderPlotly(
      plot_seasonality(
        calc_seasonality(
          filter_futures(app_data()$prices,cmdty = "RB",contracts = 1),
          "RB")))

    output$curve_animation <- shiny::renderImage({
      list(src = app_sys("extdata/rb_curve.gif"), contentType = "image/gif")
    }, deleteFile = FALSE)

    outputOptions(output, "curve_animation", suspendWhenHidden = FALSE)

    output$vol_surface <- plotly::renderPlotly(
      plot_vol_surface(app_data()$prices, "RB", method = "log",
                       start = "2024-01-01", end = "2024-03-26"))

    output$garch_chart <-  shiny::renderPlot(calc_garch(
      calc_daily_returns(
        filter_futures(
          app_data()$prices,
          cmdty = "RB",
          contracts = input$contract_select)) %>%
        dplyr::filter(
          date >= as.Date("2019-01-01"),
          date <= as.Date("2023-07-31")),
      series_name = paste0("RB0", input$contract_select)))
  })
}
