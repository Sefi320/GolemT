#' HO Module UI
#' @param id Module namespace id

mod_ho_ui <- function(id) {
  ns <- NS(id)
  div(
    style = "display: flex; flex-direction: column; gap: 20px; padding: 24px;",
    bslib::card(
      bslib::card_header("Price History — Heating Oil (ULSD)"),
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

#' HO Module Server
#' @param id Module namespace id

mod_ho_server <- function(id,app_data) {
  moduleServer(id, function(input, output, session) {

    output$price_chart <- plotly::renderPlotly(
      plot_price(
        filter_futures(app_data()$prices, cmdty = "HO", contracts = 1)))

    output$narrative <- renderUI(tags$ul(
      tags$li("Heating Oil (ULSD) serves dual demand: residential heating in winter and diesel/jet fuel year-round for logistics, agriculture, and aviation. This creates a bimodal seasonal demand profile."),
      tags$li("Ukraine 2022 hit every demand layer simultaneously — diesel for trucks and farming, heating for European households replacing Russian gas, and jet fuel recovering post-COVID. The price spike reflects all three."),
      tags$li("The diesel crack spread (HO minus CL) is the key refinery output margin for middle distillates. It is structurally higher when geopolitical disruptions tighten European supply."),
      tags$li("ULSD (ultra-low sulfur diesel) trades as a proxy for European gasoil. HO is more globally connected than WTI — European energy policy directly affects New York Harbor ULSD prices."),
      tags$li("Bimodal seasonality: a winter heating peak and a spring/fall refinery maintenance trough. Weaker than RB because the industrial diesel component smooths the pure heating demand signal.")
    ))

    output$seasonality_heatmap <- plotly::renderPlotly(
      plot_seasonality(
        calc_seasonality(
          filter_futures(app_data()$prices,cmdty = "HO",contracts = 1),
          "HO")))

    output$curve_animation <- shiny::renderImage({
      list(src = app_sys("extdata/ho_curve.gif"), contentType = "image/gif")
    }, deleteFile = FALSE)

    outputOptions(output, "curve_animation", suspendWhenHidden = FALSE)

    output$vol_surface <- plotly::renderPlotly(
      plot_vol_surface(app_data()$prices, "HO", method = "log",
                       start = "2024-01-01", end = "2024-03-26"))

    output$garch_chart <-  shiny::renderPlot(calc_garch(
      calc_daily_returns(
        filter_futures(
          app_data()$prices,
          cmdty = "HO",
          contracts = input$contract_select)) %>%
        dplyr::filter(
          date >= as.Date("2019-01-01"),
          date <= as.Date("2023-07-31")),
      series_name = paste0("HO0", input$contract_select)))

  })
}
