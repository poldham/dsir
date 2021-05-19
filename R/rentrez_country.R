#' Search NCBI entrez databases for country information
#' Use the rentrez package to search an NCBI Entrez database for country information. For a list of entrez databases use rentrez::entrez_dbs()
#' The function is designed to download the summary data for the results of the search which can be many Gibabytes (e.g. 2.4 million records from South Africa is 45Gb).
#' The function does not download the sequences. See the rentrez package to download the actual sequences in different formats. 
#' @param country 
#' @param db 
#' @details For available fields for query constructions see \url{https://www.ncbi.nlm.nih.gov/books/NBK49540/}
#' @return
#' @export
#'
#' @examples bahamas <- rentrez_country(country = "bahamas", dbase = "nucleotide")
#' 
#' # Get records with a publication date
#' kenya_pub <- rentrez::entrez_search(db = "nucleotide", term = "(Kenya) AND 2020/02/26[PDAT]", use_history = TRUE)
#' kenya_pub_range <- rentrez::entrez_search(db = "nucleotide", term = "(Kenya) AND 2020/01/01:2020/05/18[PDAT]", use_history = TRUE)
#'
#' # Get records with a modification date
#' kenya_mod <- rentrez::entrez_search(db = "nucleotide", term = "(Kenya) AND 2020/05/18[Modification Date]", use_history = TRUE)
#' kenya_mod_range <- rentrez::entrez_search(db = "nucleotide", term = "(Kenya) AND 2020/01/01:2020/05/18[Modification Date]", use_history = TRUE)
rentrez_country <- function(country = NULL, dbase = "nucleotide", date = NULL) {
  
  raw <- rentrez::entrez_search(db = dbase,
                term = country, use_history = TRUE)
  
  count <- raw$count

retstart_seq <- seq(1, count, 10000)

rentrez_map <- function(retstart_seq) {

  rentrez::entrez_summary(db = dbase, web_history = raw$web_history,
                 retmode="xml", retmax = 10000, retstart = retstart_seq)
}

out <- purrr::map(retstart_seq, rentrez_map)

}