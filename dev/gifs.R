

# I had to add this to save the create and render the gifs outside of the app.
# Each gif takes ~17 secs to run, if I leave for the app, then its 17*6 - TOO LONG


library(GolemT)

prices <- load_data()$prices

commodities <- c("CL", "NG", "BRN", "HO", "RB")

for (cmdty in commodities) {
  anim <- anim_plot(
    filter_futures(prices, cmdty),
    start = "2020-01-01",
    end   = "2020-12-31",
    title  = paste0(cmdty, " Term Structure for the year 2020"),
    y_title = "Price ($)"
  )
  gganimate::anim_save(
    here::here("inst/extdata", paste0(cmdty, "_curve.gif")),
    anim
  )
}
