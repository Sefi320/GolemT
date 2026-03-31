#' CMT Module UI
#' @param id Module namespace id
#' @export
mod_cmt_ui <- function(id) {
  ns <- NS(id)
  div(
    style = "display: flex; flex-direction: column; gap: 20px; padding: 24px;",
    bslib::card(
      bslib::card_header("Yield Curve Animation"),
      plotly::plotlyOutput(ns("curve_animation"))
    ),
    bslib::card(
      bslib::card_header("Market Narrative"),
      uiOutput(ns("narrative"))
    ),
    bslib::card(
      bslib::card_header("Rate Cycle"),
      plotly::plotlyOutput(ns("rate_cycle_chart"))
    ),
    bslib::card(
      bslib::card_header("Rolling Volatility"),
      plotly::plotlyOutput(ns("rolling_vol_chart"))
    ),
    bslib::card(
      bslib::card_header("CMT vs Brent"),
      plotly::plotlyOutput(ns("cmt_brn_chart"))
    )
  )
}

#' CMT Module Server
#' @param id Module namespace id
#' @export
mod_cmt_server <- function(id,app_data) {
  moduleServer(id, function(input, output, session) {
    output$curve_animation  <- plotly::renderPlotly(shinipsum::random_ggplotly())
    output$narrative        <- renderUI(HTML(shinipsum::random_text(nwords = 60)))
    output$rate_cycle_chart <- plotly::renderPlotly(shinipsum::random_ggplotly())
    output$rolling_vol_chart <- plotly::renderPlotly(shinipsum::random_ggplotly())
    output$cmt_brn_chart    <- plotly::renderPlotly(shinipsum::random_ggplotly())
  })
}
