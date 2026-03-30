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
      title = "GolemT — Energy Market Dynamics",
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
