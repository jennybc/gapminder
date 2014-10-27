install.packages(pkgs = "~/teaching//gapminder",
                 lib = "~/resources/R/libraryDev",
                 repos = NULL,
                 type = "source")

library(gapminder)
head(gapminder)
tail(gapminder)
str(gapminder)

if (require("dplyr")) {
  gapminder
  gapminder %>%
    filter(year == 2007) %>%
    group_by(continent) %>%
    summarise(lifeExp = median(lifeExp))
}
