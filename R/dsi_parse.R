#' Parse the Esummary from rentrez_country to a data frame
#' Function to parse the results of a call to rentrez_fetch to a data frame. Note that does not presently include the statistics
#' Tested on 10,0000 records for the Bahamas
#' @param x a list object from entrez_summary nucleotide database
#' @details This function returns all available esummary meta data except the statistics chunk (as this partly repeats infornation such as sequence length)
#' @return data frame
#' @export
#' @importFrom purrr compact
#' @importFrom purrr map_chr
#' @importFrom purrr map
#' @importFrom purrr pluck
#' @importFrom purrr reduce
#' @importFrom tibble enframe
#' @importFrom rentrez extract_from_esummary
#' @importFrom tibble rownames_to_column
#' @importFrom dplyr select
#' @importFrom dplyr mutate
#' @importFrom tidyr separate
#' @importFrom dplyr select_if
#' @importFrom dplyr bind_rows
#' @importFrom dplyr arrange
#' @importFrom dplyr group_by
#' @importFrom dplyr group_split
#' @importFrom dplyr bind_rows
#' @importFrom dplyr rename
#' @importFrom dplyr full_join
#' @importFrom dplyr left_join
#' @importFrom janitor row_to_names
#' @importFrom janitor clean_names
#' @importFrom stringr str_count
#' @examples \dontrun{
#'
#' # with a single result set
#'
#' bs_nucleotide <- entrez_search(db = "nucleotide",
#' term = "Bahamas", use_history = TRUE), then
#' bs_summary <- entrez_summary(db="nucleotide", web_history = bs_nucleotide$web_history,
#' retmode="xml", retmax=10000, retstart=seq_start) then
#' bs_results <- dsi_parse(bs_summary)
#'
#' # With multiple list objects
#'
#' bahamas_country <- dsi_country(country = "bahamas", dbase = "nucleotide")
#' bahamas_sequences <- map_df(bahamas_sequences, dsi_parse)
#'
#' }
dsi_parse <- function(x) {

  usethis::ui_todo("Examine source of janitor warning aboout non uniue from names to rows")
  usethis::ui_todo(" add progress bar for parsing each set using progressr")
  # ADD IN A COUNTER TO SAY WHAT RECORD IS BEING PARSED AS VERY HARD TO TELL WHEN LONG LISTS

  len <- length(x)

  usethis::ui_todo("Statistics data is not included in this data")



# Parse Data --------------------------------------------------------------

  # This code is written to overcome the problem that entries in the esummary may in reality be NULL
  # For example, 2 million records may process directly but then a few somewhere will contain NULL values
  # The code below fixes this but repeats for the vars. This approach can be replaced with a function.

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

  df <- list(vecnames, accession, title, extra, gi, create_date, update_date, flags, taxid,
        slen, biomol, moltype, sourcedb, segsetsize, assemblygi, genetic_code, genome,
        assemblyacc, tech, completeness, strand, organism, strain, biosample, accession_version) %>%
     reduce(full_join, by = "id")

  #  SubType and SubName Table -----------------------------------------------

  usethis::ui_info("Expect warnings on 9 pieces and filling with NA")
  usethis::ui_info("Expect warnings on input 'seps' and coercion to vector")

  # subtype and type
  type_df <- rentrez::extract_from_esummary(x, elements = c("SubType", "SubName")) %>%
    t() %>%
    as.data.frame() %>%
    tibble::rownames_to_column("id")

  # extract headings
  subtype <- type_df %>%
    select(id, SubType) %>%
    mutate(seps = str_count(SubType, "[|]")) %>%
    separate(SubType, into = c(as.character(1:9)), sep = "[|]")

  # extract content
  subname <- type_df %>%
    select(id, SubName) %>%
    mutate(seps = str_count(SubName, "[|]")) %>%
    separate(SubName, into = c(as.character(1:9)), sep = "[|]")

  # create a function that will process the type_df
  # clean names added to deal with duplicate name col
  # janitor is throwing a warning that Row 1 does not provide unique names
  process_type <- function(df) {
    df %>%
      select_if(~ !any(is.na(.))) %>%
      select(-seps) %>%
      row_to_names(., row_number = 1) %>%
      clean_names() %>%
      rename(id = 1)
  }

  # process the data frame
  # rename strain to strain info as it is already in the set and strain is repeated
  type_df_out <- bind_rows(subtype, subname) %>%
    arrange(id) %>%
    group_by(id) %>%
    group_split() %>%
    map(., process_type) %>%
    bind_rows() %>%
    rename(strain_info = strain)

  out <- df %>% left_join(type_df_out, by = "id")


  }
