#' NG Module UI
#' @param id Module namespace id
#' @export
mod_ng_ui <- function(id) {
  ns <- NS(id)
  tagList(
    h2("Natural Gas (Henry Hub)"),
    plotly::plotlyOutput(ns("price_chart")),
    uiOutput(ns("narrative")),
    plotly::plotlyOutput(ns("eia_storage_chart")),
    plotly::plotlyOutput(ns("seasonality_heatmap")),
    plotly::plotlyOutput(ns("curve_animation")),
    plotly::plotlyOutput(ns("vol_surface")),
    selectInput(ns("contract_select"), "GARCH Contract",
                choices = paste0("NG0", 1:9)),
    sliderInput(ns("rolling_window"), "Rolling Window",
                min = 30, max = 252, value = 60, step = 30),
    plotly::plotlyOutput(ns("garch_chart"))
  )
}

#' NG Module Server
#' @param id Module namespace id
#' @export
mod_ng_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$price_chart         <- plotly::renderPlotly(shinipsum::random_ggplotly())
    output$narrative           <- renderUI(HTML(shinipsum::random_text(nwords = 60)))
    output$eia_storage_chart   <- plotly::renderPlotly(shinipsum::random_ggplotly())
    output$seasonality_heatmap <- plotly::renderPlotly(shinipsum::random_ggplotly())
    output$curve_animation     <- plotly::renderPlotly(shinipsum::random_ggplotly())
    output$vol_surface         <- plotly::renderPlotly(shinipsum::random_ggplotly())
    output$garch_chart         <- plotly::renderPlotly(shinipsum::random_ggplotly())
  })
}
