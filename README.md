
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dsir

<!-- badges: start -->
<!-- badges: end -->

### Status: Experimental testing only

The `dsir` package provides an easy way for researchers and governments
to obtain country data on digital sequence information (genetic sequence
data) submitted to [NCBI
databases](https://www.ncbi.nlm.nih.gov/guide/all/) such as
[GenBank](https://www.ncbi.nlm.nih.gov/genbank/).

Digital Sequence Information (DSI) is a placeholder term for genetic
sequence data in international policy debates. The governance of DSI has
become a major focus of debate under the [United Nations Convention on
Biological Diversity and its Nagoya
Protocol](https://www.cbd.int/dsi-gr/) as well as the [Plant
Treaty](http://www.fao.org/cgrfa/topics/digital-sequence-information/en/),
the ongoing negotiations of the [new treaty on marine
biodiversity](https://www.un.org/bbnj/) (Biodiversity Beyond National
Jurisdiction or BBNJ) under UNCLOS and the sharing of virus materials
under the [PIP Framework](https://www.who.int/influenza/pip/en/) at the
World Health Organisation (WHO). The pandemic has sharpened attention to
the governance of sequence data.

One challenge for governments in these debates, notably from developing
countries, is identifying up to date data on sequence submissions that
originate in samples from their country to inform evidence based
discussion. This is the challenge that `dsir` aims to help solve.

Existing tools for sequence data focus on submitting and accessing
sequence listings. In contrast, for policy discussions what is mainly of
interest is the `metadata` about the sequences. What is needed is a
slimmed down approach that focuses on metadata… while allowing sequence
data to be accessed as needed.

This package provides the following:

-   A small set of R functions to obtain up to date NCBI esummary
    (metadata) on sequences from countries
-   A set of country datasets to allow researchers to explore the data
    in detail.

`dsir` provides simplified wrappers for some of the functions from the
[ROpenSci](https://ropensci.org/)
[rentrez](https://docs.ropensci.org/rentrez/) package created by David
Winter and collaborators. `rentrez` provides access to the NCBI [E-Utils
API](https://www.ncbi.nlm.nih.gov/books/NBK25500/) for remotely
accessing NCBI databases. The credit for the underlying code that powers
`dsir` therefore belongs with David Winter and collaborators. You can
visit `rentrez`
[here](%5Bhttps://github.com/ropensci/rentrez%5D(https://github.com/ropensci/rentrez))
and give it some love by leaving a star.

`dsir` is designed to be easy to use for people who are new to R and to
facilitate the automated retrieval and monitoring of sequence data
originating from a country. However, the underlying `rentrez` package
provides a powerful set of tools for the exploration and retrieval of
sequence related data from the network of NCBI databases. More advanced
R users will want to engage with the rich function set provided by the
`rentrez` package.

## Installation

If you have arrived here and you are completely new to the R programming
language, do not fear. You need to start by installing R and RStudio on
your computer following the instructions in Garrett Grolemund’s
excellent and free [Hands On Programming with
R](https://rstudio-education.github.io/hopr/). Follow Garret’s
instructions
[here](https://rstudio-education.github.io/hopr/starting.html) and when
you have time read the rest of the book.

`dsir` is not on CRAN and can be installed from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("poldham/dsir")
```

## Getting Started

The NCBI API provides higher level access to data if you register with
the system and obtain an API token (a unique key). You can use the
functions without an API key but access is limited to three calls per
second.

To register for an account with NCBI go
[here](https://www.ncbi.nlm.nih.gov/account/register/?back_url=https%3A%2F%2Fwww.ncbi.nlm.nih.gov%2Fhome%2Fdevelop%2Fapi%2F&partners-uri=cms:/account/partners).
Note that from June 2021 NCBI will move to third party logins
(e.g. using Google, and institutional or government login), see
[here](https://ncbiinsights.ncbi.nlm.nih.gov/2021/01/05/important-changes-ncbi-accounts-2021/)
for more details. Depending on when you land on this page, follow the
latest instructions.

Inside your account profile you will be able to create an API. Go to
your name in the top right corner to access your account details. There
you will see a panel called `API Key Management`. Generate an API key
and copy it.

The recommended way to store the key is in your R environment with the
`usethis` package. As `dsir` is built on `rentrez` we should also
install it at the same time

``` r
install.packages("usethis")
install.packages("rentrez")
```

``` r
usethis::edit_r_environ()
```

In the R environment file enter the following, save the file and then
`Session > Restart R` so that the change takes effect.

``` r
ENTREZ_KEY="my Entrez key"
```

When you have restarted R you will be good to go. The approach above is
that used by `rentrez` and so you can now happily also use the `rentrez`
package without further setup.

### Understanding the databases

NCBI contains a large number of databases. These databases are linked
together through a spiders web of connections.

To understand the databases that are accessible we can use `rentrez`.

``` r
library(rentrez)
entrez_dbs()
#>  [1] "pubmed"          "protein"         "nuccore"         "ipg"            
#>  [5] "nucleotide"      "structure"       "genome"          "annotinfo"      
#>  [9] "assembly"        "bioproject"      "biosample"       "blastdbinfo"    
#> [13] "books"           "cdd"             "clinvar"         "gap"            
#> [17] "gapplus"         "grasp"           "dbvar"           "gene"           
#> [21] "gds"             "geoprofiles"     "homologene"      "medgen"         
#> [25] "mesh"            "ncbisearch"      "nlmcatalog"      "omim"           
#> [29] "orgtrack"        "pmc"             "popset"          "proteinclusters"
#> [33] "pcassay"         "protfam"         "biosystems"      "pccompound"     
#> [37] "pcsubstance"     "seqannot"        "snp"             "sra"            
#> [41] "taxonomy"        "biocollections"  "gtr"
```

For those interested in GenBank (the best known of these databases) note
that there is no entry for genbank. What we want here is the `nuccore`
(for nucleotice core, also known as nucleotide) database. But, before
rushing on, notice all of the other databases such as pubmed for
publications, bioproject and biosample. If you work with a public
collection you will probably want to take a look at biocollections.

These databases are all linked in various ways and degrees. To see the
linkages we use another `rentrez` function.

``` r
library(rentrez)
rentrez::entrez_db_links("nuccore")
#> Databases with linked records for database 'nuccore'
#>  [1] assembly        assembly        biocollections  bioproject     
#>  [5] bioproject      bioproject      biosample       biosystems     
#>  [9] ccds            clone           nuccore         dbvar          
#> [13] gene            genome          genome          geoprofiles    
#> [17] homologene      nuccore         nuccore         nuccore        
#> [21] nuccore         nuccore         nuccore         nuccore        
#> [25] nuccore         nuccore         nuccore         omim           
#> [29] pccompound      pcsubstance     pmc             popset         
#> [33] probe           protein         protein         protein        
#> [37] protein         protein         protein         protein        
#> [41] protein         proteinclusters pubmed          pubmed         
#> [45] pubmed          snp             sparcle         sra            
#> [49] sra             structure       taxonomy        trace
```

We won’t go into the detail of these linkages here except to highlight
that once you have the data from one database you can then retrieve data
from other linked databases.

### Counting Sequence Records from A Country

Country names appear in NCBI data in two main forms:

1.  In the country field (country tag)
2.  In an organism description (e.g. for a strain or variety)

We want to capture both of these bearing in mind that in a later step we
will want to examine and filter out any noisy records.

To search and obtain country data we follow a four step process:

1.  Obtain a count of the records
2.  Fetch the records
3.  Parse the records to a table (data.frame)
4.  Save the data

We want to start by obtaining a count because even though we are working
with summary records the data gets big… fast. For example, the summary
records for 2.4 million summary records for South Africa take up 45Gb.
So, let’s not blow up the laptop by accident.

We use `dsi_count()` to generate counts. Note that the default database
for all functions is ‘nuccore’.

``` r
library(dsir)
south_africa <- dsi_count(country = "South Africa", db = "nuccore")
#> ℹ there are 2409451 records in the 'nuccore' database for 'South Africa'
```

We can elaborate on this for other types of count. In international
debates on genetic sequence data human genetic material is excluded.
Let’s see how many of the South Africa records are for humans and how
many are non-human.

``` r
library(dsir)
southafrica_homo <- dsi_count(country = "(South Africa AND Homo sapiens[ORGN])", db = "nuccore")
#> ℹ there are 20429 records in the 'nuccore' database for '(South Africa AND Homo sapiens[ORGN])'
southafrica_not <- dsi_count(country = "(South Africa NOT Homo sapiens[ORGN])", db = "nuccore")
#> ℹ there are 2389022 records in the 'nuccore' database for '(South Africa NOT Homo sapiens[ORGN])'
```

We can figure out if these counts are correct by checking that they add
up to the total.

``` r
(southafrica_homo + southafrica_not) == south_africa
#> [1] TRUE
```

Now that we are happy that the counts are working out we can generate
other types of count. For example, to avoid dealing with a very large
dataset we might want to filter the data by publication date (or
optionally record modification date).

We can do this by specifying a range of dates in this case for the first
few months until 2021.

``` r
south_africa_range <- dsi_count(country = "(South Africa) AND 2021/01/01:2021/05/19[PDAT] NOT Homo sapiens[ORGN])", db = "nuccore")
#> ℹ there are 36729 records in the 'nuccore' database for '(South Africa) AND 2021/01/01:2021/05/19[PDAT] NOT Homo sapiens[ORGN])'
```

When you have registered with NCBI and using an access token the
underlying `rentrez` package will take care of any rate limiting when
retrieving results. We now turn to retrieving the results.

### Retrieving results

To retrieve the raw results we use the `dsi_country()` function. In
contrast with `dsi_count()` the `dsi_country` function will retrieve all
of the results by default. As that can take a number of hours it is good
practice to always use `dsi_count()` first.

``` r
za_sample <- dsi_country(country = "(South Africa) AND 2021/01/01:2021/05/19[PDAT] NOT Homo sapiens[ORGN])", db = "nuccore")
```

In the background the function is making repeated calls to the Entrez
API and requesting 10,000 records per time (the maximum). Note that this
maximum may vary depending on the NCBI database and it is a good idea to
read the [rentrez
tutorial](https://cran.r-project.org/web/packages/rentrez/vignettes/rentrez_tutorial.html)
on the web history if you want to navigate through these issues.

When the search has finished we will have a za\_sample in the
environment (in this case it takes a few minutes).

The object that comes back is a list that contains chunks of 10,000
records (up to the 36,729 above). These records are in XML format and
need to be parsed to a table.

### Parsing the Results

To parse the results we use `dsi_parse()`. This will iterate over each
of the list objects and convert the data to a data.frame that we can
save. Note that this can take some time to do. If we simply call
dsi\_parse the result will be another list (this time of data.frames) so
we use `map_df()` from `purrr` (part of the tidyverse) to bind them all
together. If you don’t have the tidyverse then use
`install.packages(tidyverse)` to get it.

One ppint to note about the parsing of the esummary data is that the
existing function does not parse the statistics table inside the
summary. The reason for this is that basic statistics such as the
sequence length are already included and the stats table does not in
reality add much to this. If you want to inspect the stats data to
confirm this open up the list object returned above to assess it.

``` r
library(purrr)
za_results <- map_df(za_sample, dsi_parse)
```

As we iterate over the list messages will start to appear. These relate
to warnings that will automatically be generated with notes to
`Expect warnings`
