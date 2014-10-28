#' Gapminder color schemes.
#' 
#' Color schemes for the countries and continents in the Gapminder data.
#' 
#' @aliases continent_colors
#' @format Named character vectors giving country and continent colors:
#' \describe{ 
#'   \item{country_colors}{colors for the 142 countries}
#'   \item{continent_colors}{colors for the 5 continents}
#'   }
#' @examples
#' if (require(ggplot2)) {
#' ggplot(subset(gapminder, continent != "Oceania"),
#'        aes(x = year, y = lifeExp, group = country, color = country)) +
#'   geom_line(lwd = 1, show_guide = FALSE) + facet_wrap(~ continent) +
#'   scale_color_manual(values = country_colors) +
#'   theme_bw() + theme(strip.text = element_text(size = rel(1.1)))
#' }
#'
"country_colors"
