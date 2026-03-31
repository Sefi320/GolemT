#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  app_data <- mod_data_server("data")
  mod_cl_server("cl",app_data)
  mod_ng_server("ng",app_data)
  mod_brn_server("brn",app_data)
  mod_rb_server("rb",app_data)
  mod_ho_server("ho",app_data)
  mod_cmt_server("cmt",app_data)
}
