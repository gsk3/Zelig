#' Constructor for the 'description' class
#'
#' @param authors a character-vector of author names
#' @param year a numeric specifying the year
#' @param model a character-string specifying model name
#' @param text a character-string specifying the title of the model. This
#'   typically includes more exact information than 'model'. E.g., for the
#'   'logit' the title 'Logistic Regression for Dichotomous Variables' would be
#'   a suitable text parameter.
#' @param url a character-string specifying the model's software page
#' @param category deprecated until data-verse bindings are reevaluated
#' @return an object of type 'description'
#' @export
#' @author Matt Owen \email{mowen@@iq.harvard.edu}
description <- function(authors=c("Kosuke Imai", "Gary King", "Olivia Lau"),
                        year=NULL, model="", text="", url="",
                        category = NULL) {
  # error-catching
  if (!is.character(authors))
    author <- "Kosuke Imai, Gary King, and Olivia Lau"

  else if (length(authors) > 1) {
    # collapse author names if it is a character-vector bigger than 1
    authors <- paste(paste(head(authors, -1), collapse=", "),
                     ", and ",
                     tail(authors, 1),
                     sep = ""
                     )
  }

  if (!is.numeric(year))
    year <- as.numeric(format(Sys.Date(), "%Y"))

  if (!is.character(model) || length(model) != 1) {
    print(model)
    stop("model must be a character-string")
  }

  if (length(text) > 1)
    stop("text must be a character-vector of length 1")

  if (is.null(url))
    url <- "http://gking.harvard.edu/zelig"

  if (!is.character(category))
    category <- ""

  else if (length(url) > 1 || !is.character(url))
    stop("url must be a character-vector of length 1")

  # double back-up, even though this should be impossible now
  authors <- ifelse(nchar(authors) > 0, authors, "NAMELESS AUTHOR")
  year <- ifelse(!is.null(year), year, "UNKNOWN YEAR")
  model <- ifelse(nchar(model) > 0, model, "UNNAMED MODEL")

  # construct object
  self <- list(authors = authors,
               year    = year,
               model   = model,
               text    = text,
               url     = url
               )
  class(self) <- "description"
  self
}


#' Citation information for a 'description' object
#' @param descr an object of type 'description'
#' @return a character-string giving citation info
#' @export
#' @author Matt Owen \email{mowen@@iq.harvard.edu}
cite <- function(descr) {
  #
  if (inherits(descr, "list"))
    descr <- as.description(descr)
  else if (!inherits(descr, "description"))
    descr <- description()

  # 
  url <- "http://gking.harvard.edu/zelig"

  title <- if (is.null(descr$text))
    descr$model
  else
    paste(descr$model, ": ", descr$text, sep="")

  # quote
  title <- paste('"', title, '"', sep="")

  # construct string.  This should be done much more elegantly
  # and with localization
  str <- "How to cite this model in Zelig:\n  "
  str <- paste(str, descr$authors, ". ", descr$year, ".\n  ", title, sep="")
  str <- paste(str, "\n  in Kosuke Imai, Gary King, and Olivia Lau, ", sep="")
  str <- paste(str, "\"Zelig: Everyone's Statistical Software,\"", sep="")
  str <- paste(str, "\n  ", url, "\n", sep="")
  str
}


#' Generic Method for Casting 'description' Objects
#' 
#' Convert the result of a call to the 'describe' method into an object 
#' parseble by Zelig. Currently conversions only exist for lists and 
#' description objects.
#' @param descr an object to cast an object of type 'description'
#' @param ... parameters which are reserved for future Zelig revisions
#' @return an object of type 'description'
#' @export
#' @seealso as.description.description as.description.list
#' @author Matt Owen \email{mowen@@iq.harvard.edu}
as.description <- function(descr, ...)
  UseMethod("as.description")


#' description -> description
#'
#' Identity operation on a description object.
#' @S3method as.description description
#' @usage \method{as.description}{description}(descr, ...)
#' @param descr an object of type 'description'
#' @param ... ignored
#' @return the same object
#' @author Matt Owen \email{mowen@@iq.harvard.edu}
as.description.description <- function(descr, ...)
  descr


#' list -> description
#'
#' Convert list into a description object.
#' @usage \method{as.description}{list}(descr, ...)
#' @S3method as.description list
#' @param descr a list
#' @param ... ignored
#' @return an object of type 'description'
#' @author Matt Owen \email{mowen@@iq.harvard.edu}
as.description.list <- function(descr, ...) {

  text <- if (!is.null(descr$text))
    descr$text
  else if (!is.null(descr$description))
    descr$description
  else
    NULL
  
  description(authors = descr$authors,
              year    = descr$year,
              model   = descr$model,
              text    = text,
              url     = descr$url,
              category= descr$category
              )
}
