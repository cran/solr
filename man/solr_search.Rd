% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/solr_search.r
\name{solr_search}
\alias{solr_search}
\title{Solr search.}
\usage{
solr_search(q = "*:*", sort = NULL, start = 0, rows = NULL,
  pageDoc = NULL, pageScore = NULL, fq = NULL, fl = NULL,
  defType = NULL, timeAllowed = NULL, qt = NULL, wt = "json",
  NOW = NULL, TZ = NULL, echoHandler = NULL, echoParams = NULL,
  key = NULL, base = NULL, callopts = list(), raw = FALSE,
  parsetype = "df", concat = ",", ..., verbose = TRUE)
}
\arguments{
\item{q}{Query terms, defaults to '*:*', or everything.}

\item{sort}{Field to sort on. You can specify ascending (e.g., score desc) or
descending (e.g., score asc), sort by two fields (e.g., score desc, price asc),
or sort by a function (e.g., sum(x_f, y_f) desc, which sorts by the sum of
x_f and y_f in a descending order).}

\item{start}{Record to start at, default to beginning.}

\item{rows}{Number of records to return. Defaults to 10.}

\item{pageDoc}{If you expect to be paging deeply into the results (say beyond page 10,
assuming rows=10) and you are sorting by score, you may wish to add the pageDoc
and pageScore parameters to your request. These two parameters tell Solr (and Lucene)
what the last result (Lucene internal docid and score) of the previous page was,
so that when scoring the query for the next set of pages, it can ignore any results
that occur higher than that item. To get the Lucene internal doc id, you will need
to add [docid] to the &fl list.
e.g., q=*:*&start=10&pageDoc=5&pageScore=1.345&fl=[docid],score}

\item{pageScore}{See pageDoc notes.}

\item{fq}{Filter query, this does not affect the search, only what gets returned}

\item{fl}{Fields to return}

\item{defType}{Specify the query parser to use with this request.}

\item{timeAllowed}{The time allowed for a search to finish. This value only applies
to the search and not to requests in general. Time is in milliseconds. Values <= 0
mean no time restriction. Partial results may be returned (if there are any).}

\item{qt}{Which query handler used.}

\item{wt}{Data type returned, defaults to 'json'}

\item{NOW}{Set a fixed time for evaluating Date based expresions}

\item{TZ}{Time zone, you can override the default.}

\item{echoHandler}{If the echoHandler parameter is true, Solr places the name of
the handle used in the response to the client for debugging purposes.}

\item{echoParams}{The echoParams parameter tells Solr what kinds of Request
parameters should be included in the response for debugging purposes, legal values
include:
\itemize{
 \item none - don't include any request parameters for debugging
 \item explicit - include the parameters explicitly specified by the client in the request
 \item all - include all parameters involved in this request, either specified explicitly
 by the client, or implicit because of the request handler configuration.
}}

\item{key}{API key, if needed.}

\item{base}{URL endpoint.}

\item{callopts}{Call options passed on to httr::GET}

\item{raw}{(logical) If TRUE, returns raw data in format specified by wt param}

\item{parsetype}{(character) One of 'list' or 'df'}

\item{concat}{(character) Character to concatenate elements of longer than length 1.
Note that this only works reliably when data format is json (wt='json'). The parsing
is more complicated in XML format, but you can do that on your own.}

\item{...}{Further args.}

\item{verbose}{If TRUE (default) the url call used printed to console.}
}
\value{
XML, JSON, a list, or data.frame
}
\description{
Solr search.
}
\examples{
\dontrun{
url <- 'http://api.plos.org/search'

solr_search(q='*:*', rows=2, fl='id', base=url)

# Search for word ecology in title and cell in the body
solr_search(q='title:"ecology" AND body:"cell"', fl='title', rows=5, base=url)

# Search for word "cell" and not "body" in the title field
solr_search(q='title:"cell" -title:"lines"', fl='title', rows=5, base=url)

# Wildcards
## Search for word that starts with "cell" in the title field
solr_search(q='title:"cell*"', fl='title', rows=5, base=url)

# Proximity searching
## Search for words "sports" and "alcohol" within four words of each other
solr_search(q='everything:"sports alcohol"~7', fl='abstract', rows=3, base=url)

# Range searches
## Search for articles with Twitter count between 5 and 10
solr_search(q='*:*', fl=c('alm_twitterCount','title'), fq='alm_twitterCount:[5 TO 10]',
rows=3, base=url)

# Boosts
## Assign higher boost to title matches than to body matches (compare the two calls)
solr_search(q='title:"cell" abstract:"science"', fl='title', rows=3,
   base=url)
solr_search(q='title:"cell"^1.5 AND abstract:"science"', fl='title', rows=3,
   base=url)

# Parse data, using the USGS BISON API
url <- "http://bisonapi.usgs.ornl.gov/solr/occurrences/select"
out <- solr_search(q='*:*', fl=c('scientificName','decimalLatitude','decimalLongitude'),
   base=url, raw=TRUE)
solr_parse(out, 'df')
## gives the same result
solr_search(q='*:*', fl=c('scientificName','decimalLatitude','decimalLongitude'), base=url)

## You can choose how to combine elements longer than length 1
solr_search(q='*:*', fl=c('scientificName','decimalLatitude','decimalLongitude'), base=url,
   parsetype='df', concat=';')

# Using the USGS BISON API (http://bison.usgs.ornl.gov/services.html#solr)
## the species names endpoint
url2 <- "http://bisonapi.usgs.ornl.gov/solr/scientificName/select"
solr_search(q='*:*', base=url2, parsetype='list')

# FunctionQuery queries
## This kind of query allows you to use the actual values of fields to calculate
## relevancy scores for returned documents

## Here, we search on the product of counter_total_all and alm_twitterCount
## metrics for articles in PLOS Journals
url <- 'http://api.plos.org/search'
solr_search(q="{!func}product($v1,$v2)", v1 = 'sqrt(counter_total_all)',
   v2 = 'log(alm_twitterCount)', rows=5, fl=c('id','title'), fq='doc_type:full',
   base=url)

## here, search on the product of counter_total_all and alm_twitterCount, using
## a new temporary field "_val_"
solr_search(q='_val_:"product(counter_total_all,alm_twitterCount)"',
   rows=5, fl=c('id','title'), fq='doc_type:full', base=url)

## papers with most citations
solr_search(q='_val_:"max(counter_total_all)"',
   rows=5, fl=c('id','counter_total_all'), fq='doc_type:full', base=url)

## papers with most tweets
solr_search(q='_val_:"max(alm_twitterCount)"',
   rows=5, fl=c('id','alm_twitterCount'), fq='doc_type:full', base=url)
}
}
\references{
See \url{http://wiki.apache.org/solr/#Search_and_Indexing} for
more information.
}
\seealso{
\code{\link{solr_highlight}}, \code{\link{solr_facet}}
}

