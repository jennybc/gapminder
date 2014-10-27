#' Gapminder data.
#' 
#' Excerpt of the Gapminder data on life expectancy, GDP per capita, and
#' population by country, every five years, from 1952 to 2007
#' 
#' @format A data frame with 1704 rows and 6 variables:
#' \describe{ 
#'   \item{country}{factor with 142 levels}
#'   \item{continent}{factor with 5 levels}
#'   \item{year}{ranges from 1952 to 2007 in increments of 5 years}
#'   \item{lifeExp}{life expectancy at birth, in years}
#'   \item{pop}{population}
#'   \item{gdpPercap}{GDP per capita}
#'   }
#' @source \url{http://www.gapminder.org/data/}
#' @examples
#' if (require("dplyr")) {
#' gapminder
#' gapminder %>%
#'   filter(year == 2007) %>%
#'   group_by(continent) %>%
#'   summarise(lifeExp = median(lifeExp))
#' }
#'
"gapminder"
