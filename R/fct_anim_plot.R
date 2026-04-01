#' anim_plot
#'
#' @description Wrapper for filter_futures. Start and end dates, then builds an animation of the term strucure over that period
#'
#' @return A gganimate plot
#'
#' @noRd


anim_plot <- function(futures_df, start, end, title, y_title) {

  monthly <- futures_df %>%
    dplyr::filter(date >= start, date <= end) %>%
    dplyr::mutate(month_year = tsibble::yearmonth(date)) %>%
    dplyr::group_by(month_year, month) %>%
    dplyr::summarise(avg_price = mean(value, na.rm = T), .groups = "drop")


  structure_labels <- monthly %>%
    dplyr::group_by(month_year) %>%
    dplyr::summarise(
      front = avg_price[month == min(month)],
      back  = avg_price[month == max(month)],
      .groups = "drop"
    ) %>%
    dplyr::mutate(structure = dplyr::if_else(front > back, "backwardation", "contango"))

  panel <- monthly %>%
    dplyr::left_join(structure_labels %>% dplyr::select(month_year, structure),
                     by = "month_year") %>%
    dplyr::mutate(month_year = as.Date(month_year))

  p <- panel %>%
    ggplot2::ggplot(ggplot2::aes(x = month, y = avg_price, colour = structure, group = month_year))+
    ggplot2::geom_line()+
    ggplot2::geom_point()+
    ggplot2::scale_color_manual(values = c("contango"      = "steelblue",
                                           "backwardation" = "firebrick")) +
    ggplot2::labs(y = y_title,
         title = title,
         x = "Contract Month",
         color = "Structure") +
    ggplot2::theme_minimal() +
    gganimate::transition_time(month_year) +
    gganimate::ease_aes("linear")

  gganimate::animate(p, fps = 6, width = 800, height = 400,
                     renderer = gganimate::gifski_renderer())


}
