#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    golem_add_external_resources(),
    bslib::page_navbar(
      title = "Energy Dynamics",
      theme = bslib::bs_theme(
        version = 5,
        bg = "#1e293b",
        fg = "#cbd5e1",
        primary = "#3b82f6",
        secondary = "#94a3b8",
        "card-bg" = "#273548",
        "card-border-color" = "transparent",
        "card-box-shadow" = "0 2px 12px rgba(0,0,0,0.25)",
        "navbar-dark-color" = "rgba(255,255,255,0.75)",
        "navbar-dark-hover-color" = "#ffffff",
        "navbar-dark-active-color" = "#ffffff",
        "navbar-dark-brand-color" = "#ffffff"
      ),
      bg = "#0f172a",
      bslib::nav_panel(
        title = "Home",
        div(
          style = paste(
            "min-height: calc(100vh - 56px);",
            "background-image: url('www/app_cover.jpg');",
            "background-size: cover;",
            "background-position: center;",
            "position: relative;",
            "display: flex;",
            "align-items: center;",
            "justify-content: center;"
          ),
          div(
            style = paste(
              "position: absolute; top: 0; left: 0; right: 0; bottom: 0;",
              "background: rgba(0,0,0,0.55);"
            )
          ),
          div(
            style = paste(
              "position: relative; z-index: 1;",
              "text-align: center; max-width: 600px; padding: 32px;"
            ),
            tags$p(
              style = paste(
                "color: rgba(255,255,255,0.5); font-size: 11px;",
                "font-weight: 700; letter-spacing: 0.2em;",
                "text-transform: uppercase; margin-bottom: 12px;"
              ),
              "FIN 451 \u2014 Final Project"
            ),
            tags$h1(
              style = paste(
                "color: #ffffff; font-size: 2.5rem;",
                "font-weight: 800; margin-bottom: 16px;",
                "letter-spacing: -0.02em;"
              ),
              "Energy Market Dynamics"
            ),
            tags$p(
              style = paste(
                "color: rgba(255,255,255,0.75); font-size: 1rem;",
                "margin-bottom: 28px; line-height: 1.7;"
              ),
              "From Cushing storage limits to OPEC shocks \u2014",
              tags$br(),
              "how energy markets price risk across the curve."
            ),
          )
        )
      ),
      bslib::nav_panel("Crude Oil (WTI)",  mod_cl_ui("cl")),
      bslib::nav_panel("Natural Gas",       mod_ng_ui("ng")),
      bslib::nav_panel("Brent Crude",       mod_brn_ui("brn")),
      bslib::nav_panel("RBOB Gasoline",     mod_rb_ui("rb")),
      bslib::nav_panel("Heating Oil",       mod_ho_ui("ho")),
      bslib::nav_panel("CMT Yields",        mod_cmt_ui("cmt"))
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "GolemT"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
