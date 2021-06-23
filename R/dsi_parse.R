#' @title Parse the Esummary from rentrez_country to a data frame
#' @description Function to parse the results of a call to rentrez_fetch to a data frame. Note that does not presently include the statistics
#' Tested on 10,0000 records for the Bahamas
#' @param x a list object from entrez_summary nucleotide database
#' @details This function returns all available esummary meta data except the statistics chunk (as this partly repeats information such as sequence length)
#' @return data frame
#' @export
#' @importFrom purrr compact
#' @importFrom purrr map_chr
#' @importFrom purrr map
#' @importFrom purrr map_df
#' @importFrom purrr pluck
#' @importFrom purrr reduce
#' @importFrom tibble tibble
#' @importFrom tibble enframe
#' @importFrom tibble add_column
#' @importFrom dplyr bind_rows
#' @importFrom dplyr full_join
#' @importFrom dplyr left_join
#' @importFrom dplyr select
#' @importFrom dplyr rename
#' @importFrom tidyr pivot_wider
#' @importFrom dplyr bind_cols
#' @importFrom tidyr separate_rows
#' @examples \dontrun{
#' # get the data
#' bahamas_country <- dsi_country(country = "bahamas", dbase = "nuccore")
#' # map it to a data frame
#' bahamas_sequences <- map_df(bahamas_country, dsi_parse)
#' }
dsi_parse <- function(x) {

  #usethis::ui_todo(" add progress bar for parsing each set using progressr")
  #progressr::handlers(global = TRUE)

 # p <- progressor(along = x)

# Parse Data --------------------------------------------------------------

  # This code is written to overcome the problem that entries in the esummary may in reality be NULL
  # For example, 2 million records may process directly but then a few somewhere will contain NULL values
  # The code below fixes this but repeats for each var, replace with a function.

  vecnames <- tibble(id = names(x))

  accession = x %>% compact("Caption") %>% map_chr(., pluck, "Caption") %>% enframe("id", "accession")
  title = x %>% compact("Title") %>% map_chr(., pluck, "Title")  %>% enframe("id", "title")
  extra = x %>% compact("Extra") %>% map_chr(., pluck, "Extra") %>% enframe("id", "extra")
  gi = x %>% compact("Gi") %>% map_chr(., pluck, "Gi") %>% enframe("id", "gi")
  create_date = x %>% compact("CreateDate") %>% map_chr(., pluck, "CreateDate") %>% enframe("id", "create_date")
  update_date = x %>% compact("UpdateDate") %>% map_chr(., pluck, "UpdateDate") %>% enframe("id", "update_date")
  flags = x %>% compact("Flags") %>% map_chr(., pluck, "Flags") %>% enframe("id", "flags")
  taxid = x %>% compact("TaxId") %>% map_chr(., pluck, "TaxId") %>% enframe("id", "taxid")
  slen = x %>% compact("Slen") %>% map_chr(., pluck, "Slen")%>% enframe("id", "slen")
  biomol = x %>% compact("Biomol") %>% map_chr(., pluck, "Biomol") %>% enframe("id", "biomol")
  moltype = x %>% compact("MolType") %>% map_chr(., pluck, "MolType") %>% enframe("id", "moltype")
  sourcedb = x %>% compact("SourceDb") %>% map_chr(., pluck, "SourceDb") %>% enframe("id", "sourcedb")
  segsetsize = x %>% compact("SegSetSize") %>% map_chr(., pluck, "SegSetSize") %>% enframe("id", "segsetsize")
  assemblygi = x %>% compact("AssemblyGi") %>% map_chr(., pluck, "AssemblyGi") %>% enframe("id", "assemblygi")
  genetic_code = x %>% compact("GeneticCode") %>% map_chr(., pluck, "GeneticCode")  %>% enframe("id", "genetic_code")
  genome <- x %>% compact(., "Genome") %>% map_chr(., pluck, "Genome") %>% enframe("id", "genome")
  assemblyacc <- x %>% compact(., "AssemblyAcc") %>% map_chr(., pluck, "AssemblyAcc") %>% enframe("id", "assemblyacc")
  tech <- x %>% compact(., "Tech") %>% map_chr(., pluck, "Tech") %>% enframe("id", "tech")
  completeness <- x %>% compact(., "Completeness") %>% map_chr(., pluck, "Completeness") %>% enframe("id", "completeness")
  strand <- x %>% compact(., "Strand") %>% map_chr(., pluck, "Strand") %>% enframe("id", "strand")
  organism <- x %>% compact(., "Organism") %>% map_chr(., pluck, "Organism") %>% enframe("id", "organism")
  strain <- x %>% compact(., "Strain") %>% map_chr(., pluck, "Strain") %>% enframe("id", "strain")
  biosample <- x %>% compact(., "BioSample") %>% map_chr(., pluck, "BioSample") %>% enframe("id", "biosample")
  accession_version <- x %>% compact(., "AccessionVersion") %>% map_chr(., pluck, "AccessionVersion") %>% enframe("id", "accession_version")
  subtype <- x %>% compact(., "SubType") %>% map_chr(., pluck, "SubType") %>% enframe("id", "subtype")
  subname <- x %>% compact(., "SubName") %>% map_chr(., pluck, "SubName") %>% enframe("id", "subname")
  #statistics <- x %>% compact(., "Statistics") %>% map_chr(., pluck, "Statistics") %>% enframe("id", "Statistics")

  # added statistics for completeness, but if stored as list will not write to csv

  df <- list(vecnames, accession, title, extra, gi, create_date, update_date, flags, taxid,
        slen, biomol, moltype, sourcedb, segsetsize, assemblygi, genetic_code, genome,
        assemblyacc, tech, completeness, strand, organism, strain, biosample, accession_version, subtype,
        subname) %>%
     reduce(full_join, by = "id")

  ui_info("To parse the concatenated fields in subtype and subname use dsir_type()")

  invisible(df)

  }
