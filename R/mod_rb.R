#' RB Module UI
#' @param id Module namespace id
#' @export
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
      bslib::card_header("Demand Build"),
      actionButton(ns("next_btn"), "Next Layer"),
      plotly::plotlyOutput(ns("demand_animation"))
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
                  choices = paste0("RB0", 1:9)),
      sliderInput(ns("rolling_window"), "Rolling Window",
                  min = 30, max = 252, value = 60, step = 30),
      plotly::plotlyOutput(ns("garch_chart"))
    )
  )
}

#' RB Module Server
#' @param id Module namespace id
#' @export
mod_rb_server <- function(id,app_data) {
  moduleServer(id, function(input, output, session) {
    output$price_chart         <- plotly::renderPlotly(shinipsum::random_ggplotly())
    output$narrative           <- renderUI(HTML(shinipsum::random_text(nwords = 60)))
    output$demand_animation    <- plotly::renderPlotly(shinipsum::random_ggplotly())
    output$seasonality_heatmap <- plotly::renderPlotly(shinipsum::random_ggplotly())
    output$curve_animation     <- plotly::renderPlotly(shinipsum::random_ggplotly())
    output$vol_surface         <- plotly::renderPlotly(shinipsum::random_ggplotly())
    output$garch_chart         <- plotly::renderPlotly(shinipsum::random_ggplotly())
  })
}
