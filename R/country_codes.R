#' Country codes
#' 
#' Data frame of Gapminder country names and ISO 3166-1 country codes:
#' \describe{
#' \item{iso_alpha}{The 3-letter \href{https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3}{ISO 3166-1 alpha-3} code.}
#' \item{iso_num}{The 3-digit \href{https://en.wikipedia.org/wiki/ISO_3166-1_numeric}{ISO 3166-1 numeric-3} code.}
#' }
#' Also includes the countries covered by the supplemental data frame
#' \code{\link{gapminder_unfiltered}}.
#' @examples 
#' if (require("dplyr")) {
#' gapminder %>%
#'   filter(year == 2007, country %in% c("Kenya", "Peru", "Syria")) %>%
#'   select(country, continent) %>% 
#'   left_join(country_codes)
#' }
"country_codes"