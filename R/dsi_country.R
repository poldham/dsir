#' @title Search NCBI entrez databases for country information
#' @description This function is for searching NCBI entrez databases for country information.
#' The function is a simplified wrapper for the \code{rentrez::entrez_search()} function
#' \url{https://github.com/ropensci/rentrez}. For a list
#' of entrez databases use \code{rentrez::entrez_dbs()} The function is designed to
#' download the summary data for the results of the search which can be many
#' Gibabytes (e.g. 2.4 million records from South Africa is 45Gb). The function
#' does not download the sequences. See the rentrez package to download the
#' actual sequences in different formats.
#' @param country A country name or country and date or other terms (see
#'   examples)
#' @param db database to search
#' @details For available fields for query construction see
#'   \url{https://www.ncbi.nlm.nih.gov/books/NBK49540/}. For functions in the
#'   \code{rentrez} package see \url{https://github.com/ropensci/rentrez}
#' @return a list of xml objects
#' @export
#' @importFrom rentrez entrez_search
#' @importFrom rentrez entrez_summary
#' @importFrom purrr map
#' @examples \dontrun{bahamas <- dsi_country(country = "bahamas", db = "nuccore")
#'
#' # Get records with a publication date kenya_pub <- dsi_country(country =
#' "(Kenya) AND 2020/02/26[PDAT]", db = "nuccore", use_history = TRUE)
#' kenya_pub_range <- dsi_country(country = "(Kenya) AND
#' 2020/01/01:2020/05/18[PDAT]", db = "nuccore", use_history = TRUE)
#'
#' # Get records with a modification date kenya_mod <- dsi_country(country =
#' "(Kenya) AND 2020/05/18[Modification Date]", db = "nuccore",  use_history =
#' TRUE) kenya_mod_range <- dsi_country(country = "(Kenya) AND
#' 2020/01/01:2020/05/18[Modification Date]", db = "nuccore",  use_history =
#' TRUE) }
dsi_country <- function(country = NULL, db = "nuccore") {

  raw <- entrez_search(db,
                term = country, use_history = TRUE)

  ccount <- raw$count

retstart_seq <- seq(1, ccount, 10000)

rentrez_map <- function(retstart_seq) {

   rentrez::entrez_summary(db, web_history = raw$web_history,
                 retmode="xml", retmax = 10000, retstart = retstart_seq)
}

out <- map(retstart_seq, rentrez_map)

}
