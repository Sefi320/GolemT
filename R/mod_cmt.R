#' CMT Module UI
#' @param id Module namespace id
#' @export
mod_cmt_ui <- function(id) {
  ns <- NS(id)
  tagList(
    h2("CMT Yields"),
    plotly::plotlyOutput(ns("curve_animation")),
    uiOutput(ns("narrative")),
    plotly::plotlyOutput(ns("rate_cycle_chart")),
    plotly::plotlyOutput(ns("rolling_vol_chart")),
    plotly::plotlyOutput(ns("cmt_brn_chart"))
  )
}

#' CMT Module Server
#' @param id Module namespace id
#' @export
mod_cmt_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$curve_animation  <- plotly::renderPlotly(shinipsum::random_ggplotly())
    output$narrative        <- renderUI(HTML(shinipsum::random_text(nwords = 60)))
    output$rate_cycle_chart <- plotly::renderPlotly(shinipsum::random_ggplotly())
    output$rolling_vol_chart <- plotly::renderPlotly(shinipsum::random_ggplotly())
    output$cmt_brn_chart    <- plotly::renderPlotly(shinipsum::random_ggplotly())
  })
}
