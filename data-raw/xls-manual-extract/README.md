This directory contains files that resulted from "manual" extraction out of Excel workbooks downloaded from Gapminder. I opened the workbook in Excel and saved as tab-delimited text in each case. This original preparation started in 2008, was revisited in 2009, and was last touched in 2010.

In 2014, I am re-cleaning this data, to make the excerpt into a proper R package and to use the cleaning for teaching purposes. This relies on direct extraction from the Excel files via `gdata::read.xls()` and related functions. However, it seems like a good idea to preserve these raw, manually extracted delimited files in this repo.

