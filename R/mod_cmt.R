#' CMT Module UI
#' @param id Module namespace id

mod_cmt_ui <- function(id) {
  ns <- NS(id)
  div(
    style = "display: flex; flex-direction: column; gap: 20px; padding: 24px;",
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

mod_cmt_server <- function(id,app_data) {
  moduleServer(id, function(input, output, session) {
    output$narrative <- renderUI(tags$ul(
      tags$li("US Treasury yields are the global cost-of-capital benchmark. Every energy trade is implicitly discounted against the risk-free rate — higher yields raise the cost of carrying inventory and suppress commodity demand."),
      tags$li("2020: The Fed cut to near zero in response to COVID. Both the 2Y and 10Y collapsed, suppressing discount rates and supporting risk assets including energy prices."),
      tags$li("2022: The Fed hiked from 0.25% to 5.25% in 16 months — the fastest tightening cycle since the 1980s. The rate cycle chart shows the 2Y crossing above the 10Y, signalling an inverted yield curve."),
      tags$li("Inversion (2Y > 10Y): short-term rates exceed long-term rates when markets expect future cuts, typically because a recession is anticipated. The 2022-2023 inversion was the deepest since 1981."),
      tags$li("Fed pivot (Sep 2024): the first cut signals the end of the tightening cycle. A softer dollar is a tailwind for dollar-denominated commodities, though supply fundamentals typically dominate over any single macro factor.")
    ))

    output$rate_cycle_chart <- plotly::renderPlotly(
      plot_rate_cycle(app_data()$cmt_data)
    )

    output$rolling_vol_chart <- plotly::renderPlotly(
      plot_cmt_rolling_vol(app_data()$cmt_data)
    )

    output$cmt_brn_chart <- plotly::renderPlotly(
      plot_cmt_brn(
        filter_futures(app_data()$prices, "BRN", contracts = 1),
        app_data()$cmt_data
      )
    )
  })
}
