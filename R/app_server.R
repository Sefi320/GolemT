#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  mod_cl_server("cl")
  mod_ng_server("ng")
  mod_brn_server("brn")
  mod_rb_server("rb")
  mod_ho_server("ho")
  mod_cmt_server("cmt")
}
