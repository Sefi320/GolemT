#' CL Module UI
#' @param id Module namespace id
#' @export
mod_cl_ui <- function(id) {
  ns <- NS(id)
  div(
    style = "display: flex; flex-direction: column; gap: 20px; padding: 24px;",
    bslib::card(
      bslib::card_header("Price History — WTI Crude Oil"),
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

#' CL Module Server
#' @param id Module namespace id
#' @export
mod_cl_server <- function(id,app_data) {
  moduleServer(id, function(input, output, session) {

    output$price_chart <- plotly::renderPlotly(
                            plot_price(
                              filter_futures(app_data()$prices, "CL", contracts = 1)))

    output$narrative <- renderUI(HTML(shinipsum::random_text(nwords = 60)))

    output$seasonality_heatmap <- plotly::renderPlotly(
      plot_seasonality(
        calc_seasonality(
          filter_futures(app_data()$prices,contracts = 1),
          "CL")))

    output$curve_animation <- shiny::renderImage({
      list(src = app_sys("extdata/cl_curve.gif"), contentType = "image/gif")
    }, deleteFile = FALSE)

    outputOptions(output, "curve_animation", suspendWhenHidden = FALSE)

    output$vol_surface <- plotly::renderPlotly(
      plot_vol_surface(app_data()$prices, "CL", method = "diff", start = "2024-01-01", end = "2024-03-26"))

    output$garch_chart <- shiny::renderPlot(calc_garch(
      calc_daily_returns(
      filter_futures(
        app_data()$prices,
        cmdty = "CL",
        contracts = input$contract_select)) %>%
        dplyr::filter(
          date >= as.Date("2017-07-01"),
          date <= as.Date("2023-07-31")),
      series_name = paste0("CL0", input$contract_select)))

  })
}
