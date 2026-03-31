#' BRN Module UI
#' @param id Module namespace id
#' @export
mod_brn_ui <- function(id) {
  ns <- NS(id)
  div(
    style = "display: flex; flex-direction: column; gap: 20px; padding: 24px;",
    bslib::card(
      bslib::card_header("Price History — Brent Crude"),
      plotly::plotlyOutput(ns("price_chart"))
    ),
    bslib::card(
      bslib::card_header("BRN–CL Spread"),
      plotly::plotlyOutput(ns("brn_cl_spread_chart"))
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
      plotly::plotlyOutput(ns("curve_animation"))
    ),
    bslib::card(
      bslib::card_header("Volatility Surface"),
      plotly::plotlyOutput(ns("vol_surface"))
    ),
    bslib::card(
      bslib::card_header("GARCH"),
      selectInput(ns("contract_select"), "Contract",
                  choices = paste0("BRN0", 1:9)),
      sliderInput(ns("rolling_window"), "Rolling Window",
                  min = 30, max = 252, value = 60, step = 30),
      plotly::plotlyOutput(ns("garch_chart"))
    )
  )
}

#' BRN Module Server
#' @param id Module namespace id
#' @export
mod_brn_server <- function(id,app_data) {
  moduleServer(id, function(input, output, session) {
    output$price_chart          <- plotly::renderPlotly(shinipsum::random_ggplotly())
    output$brn_cl_spread_chart  <- plotly::renderPlotly(shinipsum::random_ggplotly())
    output$narrative            <- renderUI(HTML(shinipsum::random_text(nwords = 60)))
    output$seasonality_heatmap  <- plotly::renderPlotly(shinipsum::random_ggplotly())
    output$curve_animation      <- plotly::renderPlotly(shinipsum::random_ggplotly())
    output$vol_surface          <- plotly::renderPlotly(shinipsum::random_ggplotly())
    output$garch_chart          <- plotly::renderPlotly(shinipsum::random_ggplotly())
  })
}
