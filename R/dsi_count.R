#' @title Obtain a count of country records from an NCBI database
#' @description Search NCBI entrez databases to create counts of country information.
#'
#' This is a wrapper around \code{rentrexz:rentrez_search()} from the \code{rentrez}
#'   \url{https://github.com/ropensci/rentrez} package.
#'
#'  For a list of entrez databases use rentrez::entrez_dbs().
#' @param country A country name or country and date or other terms (see
#'   examples)
#' @param db database to search
#'@details The counts generated for summaries are for country names across data
#'  fields. The counts will include cases where the country is listed in the
#'  country field and where it appears in an organism name (e.g. a specific
#'  strain). To filter the data on the country field download the data with
#'  \code{dsi_country}.
#'
#'  For available fields for query construction see
#'  \url{https://www.ncbi.nlm.nih.gov/books/NBK49540/}. For functions in the
#'  \code{rentrez} package see \url{https://github.com/ropensci/rentrez}
#' @return character
#' @export
#' @importFrom rentrez entrez_search
#' @importFrom usethis ui_info
#' @importFrom usethis ui_value
#' @importFrom glue glue
#' @importFrom dplyr mutate
#' @examples \dontrun{bahamas <- dsi_count(country = "bahamas", db = "nuccore")
#' dsi_count(country = "bahamas", db = "biosample")
#' dsi_count(country = "bahamas", db = "bioproject")
#' dsi_count(country = "bahamas", db = "protein")
#'
#' # Get counts with a publication date kenya_pub <- dsi_count(country =
#' "(Kenya) AND 2020/02/26[PDAT]", db = "nuccore", ) kenya_pub_range <-
#' dsi_count(country = "(Kenya) AND 2020/01/01:2020/05/18[PDAT]", db =
#' "nuccore")
#'
#' # Get counts with a modification date kenya_mod <- dsi_count(country =
#' "(Kenya) AND 2020/05/18[Modification Date]", db = "nuccore", )
#' kenya_mod_range <- dsi_count(country = "(Kenya) AND
#' 2020/01/01:2020/05/18[Modification Date]", db = "nuccore")
#'
#' # Get counts for and without Homo sapiens and check they add up kenya_all <-
#' dsi_count(country = "kenya", db = "nuccore") # 469351 kenya_homo <-
#' dsi_count(country = "(Kenya AND Homo sapiens[ORGN])", db = "nuccore") # 2313
#' kenya_not <- dsi_count(country = "(Kenya NOT Homo sapiens[ORGN])", db =
#' "nuccore") # 467038 (kenya_homo + kenya_not) == kenya_all # expect TRUE
#' }
dsi_count <- function(country = NULL, db = "nuccore") {

  raw <- entrez_search(db, term = country, use_history = FALSE)

  # for a country table needs to have names.
  # Need to add in the country name, using glue

  ccount <- raw$count

  ui_info('there are {ui_value(ccount)} records in the {ui_value(db)} database for {ui_value(country)}')

  out <- tibble::tibble(country = glue({{country}}), total = glue({{ccount}}, db = glue({{db}}))) %>%
    mutate(total = as.numeric(total))


  #invisible(ccount)

}
