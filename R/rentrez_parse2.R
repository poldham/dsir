#' Parse Esummary from rentrez to data frame
#' Function to parse the results of a call to rentrez_fetch to a data frame. Note that does not presently include the statistics
#' Tested on 10,0000 records for the Bahamas
#' @param x a list object from entrez_summary nucleotide database
#'
#' @return data frame
#' @export
#'
#' @examples \dontrun{
#' 
#' # with a single result set
#' 
#' bs_nucleotide <- entrez_search(db = "nucleotide",
#' term = "Bahamas", use_history = TRUE), then 
#' bs_summary <- entrez_summary(db="nucleotide", web_history = bs_nucleotide$web_history, 
#' retmode="xml", retmax=10000, retstart=seq_start) then
#' bs_results <- entrez_parse(bs_summary)
#' 
#' # With multiple list objects
#' 
#' bahamas_country <- rentrez_country(country = "bahamas", dbase = "nucleotide")
#' bahamas_sequences <- map_df(bahamas_sequences, rentrez_parse)
#' 
#' }
rentrez_parse2 <- function(x) {
  
  usethis::ui_todo("Examine source of janitor warning aboout non uniue from names to rows")
  usethis::ui_todo(" add progress bar for parsing each set using progressr")
  # ADD IN A COUNTER TO SAY WHAT RECORD IS BEING PARSED AS VERY HARD TO TELL WHEN LONG LISTS
  
  len <- length(x)
  
  
  
  usethis::ui_todo("Statistics data is not included in this data")
  
  # Handle Null cases -------------------------------------------------------
  
  vecnames <- tibble(id = names(x))
  
  accession = x %>% compact("Caption") %>% map_chr(., pluck, "Caption") %>% tibble::enframe("id", "accession")
  title = x %>% compact("Title") %>% map_chr(., pluck, "Title")  %>% tibble::enframe("id", "title")
  extra = x %>% compact("Extra") %>% map_chr(., pluck, "Extra") %>% tibble::enframe("id", "extra")
  gi = x %>% compact("Gi") %>% map_chr(., pluck, "Gi") %>% tibble::enframe("id", "gi")
  create_date = x %>% compact("CreateDate") %>% map_chr(., pluck, "CreateDate") %>% tibble::enframe("id", "create_date")
  update_date = x %>% compact("UpdateDate") %>% map_chr(., pluck, "UpdateDate") %>% tibble::enframe("id", "update_date")
  flags = x %>% compact("Flags") %>% map_chr(., pluck, "Flags") %>% tibble::enframe("id", "flags")
  taxid = x %>% compact("TaxId") %>% map_chr(., pluck, "TaxId") %>% tibble::enframe("id", "taxid")
  slen = x %>% compact("Slen") %>% map_chr(., pluck, "Slen")%>% tibble::enframe("id", "slen")
  biomol = x %>% compact("Biomol") %>% map_chr(., pluck, "Biomol") %>% tibble::enframe("id", "biomol")
  moltype = x %>% compact("MolType") %>% map_chr(., pluck, "MolType") %>% tibble::enframe("id", "moltype")
  sourcedb = x %>% compact("SourceDb") %>% map_chr(., pluck, "SourceDb") %>% tibble::enframe("id", "sourcedb")
  segsetsize = x %>% compact("SegSetSize") %>% map_chr(., pluck, "SegSetSize") %>% tibble::enframe("id", "segsetsize")
  assemblygi = x %>% compact("AssemblyGi") %>% map_chr(., pluck, "AssemblyGi") %>% tibble::enframe("id", "assemblygi")
  genetic_code = x %>% compact("GeneticCode") %>% map_chr(., pluck, "GeneticCode")  %>% tibble::enframe("id", "genetic_code")
  genome <- x %>% compact(., "Genome") %>% map_chr(., pluck, "Genome") %>% tibble::enframe("id", "genome")
  assemblyacc <- x %>% compact(., "AssemblyAcc") %>% map_chr(., pluck, "AssemblyAcc") %>% tibble::enframe("id", "assemblyacc")
  tech <- x %>% compact(., "Tech") %>% map_chr(., pluck, "Tech") %>% tibble::enframe("id", "tech")
  completeness <- x %>% compact(., "Completeness") %>% map_chr(., pluck, "Completeness") %>% tibble::enframe("id", "completeness")
  strand <- x %>% compact(., "Strand") %>% map_chr(., pluck, "Strand") %>% tibble::enframe("id", "strand")
  organism <- x %>% compact(., "Organism") %>% map_chr(., pluck, "Organism") %>% tibble::enframe("id", "organism")
  strain <- x %>% compact(., "Strain") %>% map_chr(., pluck, "Strain") %>% tibble::enframe("id", "strain")
  biosample <- x %>% compact(., "BioSample") %>% map_chr(., pluck, "BioSample") %>% tibble::enframe("id", "biosample")
  accession_version <- x %>% compact(., "AccessionVersion") %>% map_chr(., pluck, "AccessionVersion") %>% tibble::enframe("id", "accession_version")
  
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
      janitor::row_to_names(., row_number = 1) %>%
      janitor::clean_names() %>%
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