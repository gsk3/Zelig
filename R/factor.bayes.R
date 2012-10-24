#' Interface between the Zelig Model factor.bayes and 
#' the Pre-existing Model-fitting Method
#' @param formula a formula
#' @param ... additonal parameters
#' @param data a data.frame 
#' @return a list specifying '.function'
#' @export
zelig2factor.bayes <- function (
                                formula, 
                                factors = 2,
                                burnin = 1000, mcmc = 20000, 
                                verbose=0, 
                                ..., 
                                data
                                ) {

  loadDependencies(survey)

  if (missing(verbose))
    verbose <- round((mcmc + burnin)/10)

  if (factors < 2)
    stop("Number of factors needs to be at least 2")

  x <- as.matrix(model.response(model.frame(formula, data=data, na.action=NULL)))

  list(
       .function = "MCMCfactanal",
       .hook = "McmcHookFactor",

       formula = formula,
       x = x,
       burnin = burnin,
       mcmc   = mcmc,
       verbose= verbose,
       data   = data,

       ...
       )
}

#' @S3method param factor.bayes
param.factor.bayes <- function (...) {
}

#' @S3method param factor.bayes
qi.factor.bayes <- function(obj, x=NULL, x1=NULL, y=NULL, num=1000, param=NULL) {
  stop('There is no qi function for the "factor.bayes" model')
  list(
       "Expected Value: E(Y|X)" = NA
       )
}

#' @S3method describe factor.bayes
describe.factor.bayes <- function(...) {
  list(
       authors = "",
       text = ""
       )
}