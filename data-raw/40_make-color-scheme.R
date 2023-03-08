#' ---
#' date: "`r format(Sys.Date())`"
#' output: github_document
#' ---

library(here)
library(gapminder)
library(RColorBrewer)
library(tidyverse)
library(forcats)

#' map continent and country into colors

by_continent <- gapminder %>%
  group_by(continent) %>%
  nest() %>%
  arrange(continent)

f <- function(x) {
  x[["country"]] %>%
    fct_drop() %>%
    fct_reorder(x[["pop"]], fun = max) %>%
    levels() %>%
    rev()
}

by_continent <- by_continent %>%
  mutate(country = map(data, f)) %>%
  select(-data) %>%
  mutate(n_cty = lengths(country))

#' choose a range of colors for each continent
display.brewer.all(type = "div")

color_anchors_by_continent <-
  list(
    Africa = brewer.pal(n = 11, "PuOr")[1:5], # orange/brown/gold
    Americas = brewer.pal(n = 11, "RdYlBu")[1:5], # red
    Asia = brewer.pal(n = 11, "PRGn")[1:5], # purple
    Europe = brewer.pal(n = 11, "PiYG")[11:7], # green
    Oceania = brewer.pal(n = 11, "RdYlBu")[11:10]
  ) %>% # blue
  enframe(name = "continent", value = "anchors")

by_continent <- by_continent %>%
  left_join(color_anchors_by_continent)

f <- function(anchors, n) {
  color_fun <- colorRampPalette(anchors)
  color_fun(n)
}

by_continent <- by_continent %>%
  mutate(color = map2(anchors, n_cty, f)) %>%
  select(-anchors)

#' color scheme and country count for continents
(continent_colors_df <- by_continent %>%
  select(-country) %>%
  mutate(color = map_chr(color, 1)))
write_tsv(
  continent_colors_df,
  here("data-raw", "40_continent-colors.tsv")
)
file.copy(
  from = here("data-raw", "40_continent-colors.tsv"),
  to = here("inst", "extdata", "continent-colors.tsv"),
  overwrite = TRUE
)

country_colors_df <- by_continent %>%
  unnest() %>%
  select(country, color, continent)

write_tsv(
  country_colors_df,
  here("data-raw", "40_country-colors.tsv")
)
file.copy(
  from = here("data-raw", "40_country-colors.tsv"),
  to = here("inst", "extdata", "country-colors.tsv"),
  overwrite = TRUE
)

#' convert country and continent colors into named character vectors
country_colors <- country_colors_df %>%
  select(-continent) %>%
  deframe()

continent_colors <- continent_colors_df %>%
  select(-n_cty) %>%
  deframe()

## save for the package
save(
  country_colors,
  file = here("data", "country_colors.rdata")
)
save(
  continent_colors,
  file = here("data", "continent_colors.rdata")
)

#' make a nice figure of my color scheme. try to use as few packages as possible
#' here so can repurpose as example
#'
#' prep work
char_limit <- 12 # truncate country names
j_cex <- 4 # cex for ggplot2
y_boundaries <- map(
  continent_colors_df$n_cty,
  ~ seq(0, 1, length.out = .x + 1)
)

df <- tibble( # utility data.frame with rectangle boundaries
  xmax = rep(
    seq_len(length(continent_colors)),
    sapply(y_boundaries, length) - 1
  ),
  xmin = xmax - 1,
  ymin = unlist(lapply(y_boundaries, function(y) head(y, -1))),
  ymax = unlist(lapply(y_boundaries, function(y) y[-1])),
  ymid = (ymin + ymax) / 2
)
df <- df %>%
  bind_cols(country_colors_df) %>%
  mutate(
    cex = j_cex,
    continent = factor(continent)
  )
df$cex[df$continent == "Africa"] <- j_cex * 0.75

#' base R graphics

#' control printing of country names
base_cex <- 0.75

op <- par(mar = c(1, 4, 1, 1) + 0.1)
plot(c(0, length(continent_colors)), c(0, 1),
  type = "n",
  xlab = "", ylab = "", xaxt = "n", yaxt = "n", bty = "n"
)
with(
  df,
  rect(
    xleft = xmin,
    ybottom = ymin,
    xright = xmax,
    ytop = ymax,
    col = color, border = NA
  )
)
with(
  df,
  text(
    x = xmin + 0.5,
    y = ymid,
    labels = substr(country, 1, char_limit),
    cex = base_cex * cex / j_cex
  )
)
mtext(continent_colors_df$continent,
  side = 1,
  line = -0.5, at = seq_len(length(continent_colors)) - 0.5
)
mtext(c("smallest\npop", "largest\npop"),
  side = 2, at = c(0.9, 0.1), las = 1
)
par(op)

dev.print(
  pdf,
  here("data-raw", "gapminder-color-scheme-base.pdf"),
  width = 7, height = 10
)
file.copy(
  from = here("data-raw", "gapminder-color-scheme-base.pdf"),
  to = here("man", "figures", "gapminder-color-scheme-base.pdf"),
  overwrite = TRUE
)

#' ggplot2
p <- ggplot(df, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax)) +
  geom_rect(fill = df$color) +
  annotate("text",
    x = unclass(df$continent) - 0.5,
    y = df$ymid,
    label = df$country %>% substr(1, char_limit),
    cex = df$cex
  ) +
  scale_x_continuous(
    breaks = seq_len(length(continent_colors)) - 0.5,
    labels = levels(df$continent)
  ) +
  scale_y_continuous(
    breaks = c(0.9, 0.1),
    labels = c("smallest\npop", "largest\npop")
  ) +
  theme_bw() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.border = element_blank(),
    axis.text = element_text(size = rel(1.5)),
    axis.ticks = element_blank(),
    axis.title = element_blank()
  )
p

ggsave(
  here("data-raw", "gapminder-color-scheme-ggplot2.png"),
  p,
  height = 10, width = 7
)
file.copy(
  from = here("data-raw", "gapminder-color-scheme-ggplot2.png"),
  to = here("man", "figures", "gapminder-color-scheme-ggplot2.png"),
  overwrite = TRUE
)
