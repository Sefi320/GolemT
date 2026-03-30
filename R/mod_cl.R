#' CL Module UI
#' @param id Module namespace id
#' @export
mod_cl_ui <- function(id) {
  ns <- NS(id)
  tagList(
    h2("Crude Oil (WTI)"),
    plotly::plotlyOutput(ns("price_chart")),
    uiOutput(ns("narrative")),
    plotly::plotlyOutput(ns("seasonality_heatmap")),
    plotly::plotlyOutput(ns("curve_animation")),
    plotly::plotlyOutput(ns("vol_surface")),
    selectInput(ns("contract_select"), "GARCH Contract",
                choices = paste0("CL0", 1:9)),
    sliderInput(ns("rolling_window"), "Rolling Window",
                min = 30, max = 252, value = 60, step = 30),
    plotly::plotlyOutput(ns("garch_chart"))
  )
}

#' CL Module Server
#' @param id Module namespace id
#' @export
mod_cl_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$price_chart        <- plotly::renderPlotly(shinipsum::random_ggplotly())
    output$narrative          <- renderUI(HTML(shinipsum::random_text(nwords = 60)))
    output$seasonality_heatmap <- plotly::renderPlotly(shinipsum::random_ggplotly())
    output$curve_animation    <- plotly::renderPlotly(shinipsum::random_ggplotly())
    output$vol_surface        <- plotly::renderPlotly(shinipsum::random_ggplotly())
    output$garch_chart        <- plotly::renderPlotly(shinipsum::random_ggplotly())
  })
}
