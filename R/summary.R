# Summary of MCMCZelig Object
#
# This method produces a summary object for \code{MCMCZelig} objects
# @param object an "MCMCZelig" object
# @param quantiles a numeric vector specifying the quantiles to use in the
# summary object.
# @param ... ignored parameters
# @return a \code{summary.MCMCZelig} object
#' @S3method summary MCMCZelig
summary.MCMCZelig <- function(object, quantiles = c(0.025, 0.5, 0.975), ...) {
  out <- list()
  out$summary <- cbind(
                       summary(coef(object))$statistics[,1:2],
                       summary(coef(object), quantiles=quantiles)$quantiles
                       )
                       
  colnames(out$summary) <- c("Mean", "SD", paste(quantiles*100, "%",sep=""))
  stuff <- attributes(coef(object))
  out$call <- object$call
  out$start <- stuff$mcpar[1]
  out$end <- stuff$mcpar[2]
  out$thin <- stuff$mcpar[3]
  out$nchain <- 1
  class(out) <- "summary.MCMCZelig"
  out
}
#' Method for summarizing simulations of multiply imputed quantities of interest
#'
#' @S3method summary MI.sim
#' @usage \method{summary}{MI.sim}(object, ...)
#' @param object a `MI.sim' object
#' @param ... ignored parameters
#' @return a `summarized.MI.sim' object
#' @export
#' @author Matt Owen \email{mowen@@iq.harvard.edu}
summary.MI.sim <- function(object, ...) {

  summarized.list <- list()

  for (key in names(object)) {

    stats <- object[[key]]$stats

    for (qi.name in names(stats))
      summarized.list[[qi.name]][[key]] <- stats[[qi.name]]

  }

  class(summarized.list) <- "summarySim.MI"

  summarized.list
}
#' Summary of Generalized Linear Model with Robust Error Estimates
#'
#' Returns summary of a glm model with robust error estimates. This only
#' slightly differs from how the standard GLM's behave.
#' @usage \method{summary}{glm.robust}(object, ...)
#' @S3method summary glm.robust
#' @param object a ``glm.robust'' fitted model
#' @param ... parameters to pass to the standard ``summary.glm'' method
#' @return a object of type ``summary.glm.robust'' and ``summary.glm''
summary.glm.robust <- function(object, ...) {
  class(object) <- c("glm", "lm")
  res <- summary.glm(object, ...)
  if (is.null(object$robust)) {
    res$cov.unscaled <- covmat.unscaled <- vcovHAC(object)
    res$robust <- "vcovHAC"
  } else {
    fn <- object$robust$method
    res$robust <- object$robust$method
    object$robust$method <- NULL
    arg <- object$robust
    arg$x <- object
    res$cov.unscaled <- covmat.unscaled <- eval(do.call(fn, args=arg))
  }
  res$cov.scaled <- covmat <- covmat.unscaled*res$dispersion
  if (!is.null(res$correlation)) {
    dd <- sqrt(diag(res$cov.unscaled))
    res$correlation <- res$cov.unscaled/outer(dd, dd)
    dimnames(res$correlation) <- dimnames(res$cov.unscaled)
  }

  res$coefficients[,2] <- s.err <- sqrt(diag(covmat))
  res$coefficients[,3] <- tvalue <- coefficients(object)/s.err
  if (length(dimnames(res$coefficients)[[2]])>3) {
    if (dimnames(res$coefficients)[[2]][3]=="z value")
      res$coefficients[,4] <- 2 * pnorm(-abs(tvalue))
    else
      res$coefficients[,4] <- 2 * pt(-abs(tvalue), object$df.residual)
  }
  class(res) <- c("summary.glm.robust","summary.glm")
  return(res)
}
#' Return a Summary of a Set of Pooled Simulated Interests
#'
#' Returns the summary information from a set of pooled simulated interests.
#' The object returned contains the slots ``labels'', a character-vector
#' specifying the labels (explanatory variable titles) of the qi's, ``titles'',
#' a character vector specifying the names of the quantities of interest, and
#" ``stats'', a list containing quantities of interests.
#' @usage \method{summary}{pooled.sim}(object, ...)
#' @S3method summary pooled.sim
#' @param object a ``pooled.sim'' object, containing information about
#' simulated quantities of interest
#' @param ... Ignored parameters
#' @return a ``summary.pooled.sim'' object storing the replicated quantities of
#' interest
#' @author Matt Owen \email{mowen@@iq.harvard.edu}
summary.pooled.sim <- function (object, ...) {
  model <- list()
  stats <- list()
  titles <- list()
  original <- list()
  call <- list()
  x <- list()
  x1 <- list()

  #
  for (key in names(object)) {
    o <- object[[key]]

    stats[[key]] <- o$stats
    titles[[key]] <- o$titles
  }

  s <- list(
            labels = names(object),
            titles = names(object[[1]]$stats),
            stats = stats
            )

  class(s) <- "summary.pooled.sim"

  s
}
#' Summary for ``Relogit'' Fitted Model
#'
#' Summarize important components of the ``relogit'' model
#' @usage \method{summary}{Relogit}(object, ...)
#' @S3method summary Relogit
#' @param object a ``Relogit'' object
#' @param ... other parameters
#' @return a ``summary.relogit'' object
summary.Relogit <- function(object, ...) {
  dta <- model.matrix(terms(object), data=model.frame(object))
  class(object) <- class(object)[2]
  res <- summary(object, ...)
  if (object$bias.correct) {
    n <- nrow(dta)
    k <- ncol(dta)
    res$cov.unscaled <- res$cov.unscaled * (n/(n+k))^2
    res$cov.scaled <- res$cov.unscaled * res$dispersion
    res$coefficients[,2] <- sqrt(diag(res$cov.scaled))
    res$coefficients[,3] <- res$coefficients[,1] / res$coefficients[,2]
    res$coefficients[,4 ] <- 2*pt(-abs(res$coefficients[,3]), res$df.residual)
  }
  res$call <- object$call
  res$tau <- object$tau
  res$bias.correct <- object$bias.correct
  res$prior.correct <- object$prior.correct
  res$weighting <- object$weighting
  class(res) <- "summary.relogit"
  return(res)
}
#' Summary for ``Relogit2'' Fitted Model
#'
#' Summarize important components of the ``relogit'' model
#' @usage \method{summary}{Relogit2}(object, ...)
#' @S3method summary Relogit2
#' @param object a ``Relogit2'' object
#' @param ... other parameters
#' @return a ``summary.relogit2'' object
summary.Relogit2 <- function(object, ...) {
  res <- list()
  res$lower.estimate <- summary.Relogit(object$lower.estimate)
  res$upper.estimate <- summary.Relogit(object$upper.estimate)
  res$call <- object$call
  class(res) <- "summary.relogit2"
  return(res)
}












#' Method for summarizing simulations of quantities of interest
#'
#' Return a ``summary.sim'' object (typically for display)
#' @S3method summary sim
#' @usage \method{summary}{sim}(object, ...)
#' @param object a 'MI.sim' object
#' @param ... ignored parameters
#' @return a 'summarized.MI.sim' object
#' @export
#' @author Matt Owen \email{mowen@@iq.harvard.edu}
summary.sim <- function(object, ...) {
  res <- list(
              model    = object$model,
              stats    = object$stats,
              titles   = object$titles,
              original = object$result,
              call     = object$call,
              zeligcall= object$zcall,
              x        = object$x,
              x1       = object$x1,
              num      = object$num
              )
  class(res) <- c(object$name, "summary.sim")
  res
}
#' Zelig Object Summaries
#'
#' Compute summary data for zelig objects
#' @S3method summary zelig
#' @usage \method{summary}{zelig}(object, ...)
#' @param object a zelig object
#' @param ... parameters forwarded to the generic summary object
#' @return the summary of the fitted model
#' @export
#' @author Matt Owen \email{mowen@@iq.harvard.edu}
summary.zelig <- function (object, ...) {
  # For now, simply get the summary of the result object
  obj <- eval(object$result)

  if (isS4(obj)) {

    sigs <- findMethodSignatures('summary')
    classes <- class(obj)

    # Remove classes that do not have 'summary' methods
    intersection <- classes[ ! sigs %in% classes ]
    intersection <- na.omit(intersection)
    intersection <- as.character(intersection)

    # Summary only has one parameter, so we only consider the first one
    # This may be slightly dangerous, but it should not fail
    sig <- intersection[1]
    
    # if an attempt to get the summary fails, replace with a call to the S3
    SUMMARY <- tryCatch(getMethod('summary', sig), error = function(e) summary)

    # return
    SUMMARY(obj)
  }

  else
    # S3 objects have no problem figuring out which method to use
    summary(obj)
}
#' Sumary of ``setx'' Object
#'
#' Compute summary data for ``setx'' objects
#' @S3method summary zelig
#' @usage \method{summary}{zelig}(object, ...)
#' @param object a zelig object
#' @param ... parameters forwarded to the generic summary object
#' @return the summary of the fitted model
#' @export
#' @author Matt Owen \email{mowen@@iq.harvard.edu}
summary.setx <- function (object, ...) {
  mm <- object$matrix
  attr(mm, "assign") <- NULL
  attr(mm, "contrasts") <- NULL


  structure(
    list(
      call = object$call,
      label = object$label,
      model.name = object$name,
      formula = object$formula,
      model.matrix = mm
    ),
    class = "summary.setx"
    )
}
#' Summary of Multiply Imputed Statistical Models Using Rubin's Rule
#'
#' ...
#' @S3method summary MI
#' @usage \method{summary}{MI}(object, ...)
#' @param object a set of fitted statistical models
#' @param ... parameters to forward
#' @return a list of summaries
#' @author Matt Owen \email{mowen@@iq.harvard.edu}
summary.MI <- function (object, subset = NULL, ...) {

  if (length(object) == 0)
    stop('Invalid input for "subset"')

  else if (length(object) == 1)
    return(summary(object[[1]]))

  #
  getcoef <- function(obj) {
    # S4
    if (!isS4(obj))
      coef(obj)
    else if ("coef3" %in% slotNames(obj))
      obj@coef3
    else
      obj@coef
  }


  #
  res <- list()

  # Get indices
  subset <- if (is.null(subset))
    1:length(object)
  else
    c(subset)

  # Compute the summary of all objects
  for (k in subset) {
    res[[k]] <- summary(object[[k]])
  }


  # Answer
  ans <- list(
              zelig = object[[1]]$name,
              call = object[[1]]$result$call,
              all = res
              )

  #
  coef1 <- se1 <- NULL

  #
  for (k in subset) {
    tmp <-  getcoef(res[[k]])
    coef1 <- cbind(coef1, tmp[, 1])
    se1 <- cbind(se1, tmp[, 2])
  }

  rows <- nrow(coef1)
  Q <- apply(coef1, 1, mean)
  U <- apply(se1^2, 1, mean)
  B <- apply((coef1-Q)^2, 1, sum)/(length(subset)-1)
  var <- U+(1+1/length(subset))*B
  nu <- (length(subset)-1)*(1+U/((1+1/length(subset))*B))^2

  coef.table <- matrix(NA, nrow = rows, ncol = 4)
  dimnames(coef.table) <- list(rownames(coef1),
                               c("Value", "Std. Error", "t-stat", "p-value"))
  coef.table[,1] <- Q
  coef.table[,2] <- sqrt(var)
  coef.table[,3] <- Q/sqrt(var)
  coef.table[,4] <- pt(abs(Q/sqrt(var)), df=nu, lower.tail=F)*2
  ans$coefficients <- coef.table
  ans$cov.scaled <- ans$cov.unscaled <- NULL

  for (i in 1:length(ans)) {
    if (is.numeric(ans[[i]]) && !names(ans)[i] %in% c("coefficients")) {
      tmp <- NULL
      for (j in subset) {
        r <- res[[j]]
        tmp <- cbind(tmp, r[[pmatch(names(ans)[i], names(res[[j]]))]])
      }
      ans[[i]] <- apply(tmp, 1, mean)
    }
  }

  class(ans) <- "summaryMI"
  ans
}

print.summaryMI <- function(x, subset = NULL, ...){
  m <- length(x$all)
  if (m == 0)
    m <- 1
  if (any(subset > max(m)))
    stop("the subset selected lies outside the range of available \n        observations in the MI regression output.")
  cat("\n  Model:", x$zelig)
  cat("\n  Number of multiply imputed data sets:", m, "\n")
  if (is.null(subset)) {
    cat("\nCombined results:\n\n")
    cat("Call:\n")
    print(x$call)
    cat("\nCoefficients:\n")
    print(x$coefficients)
    cat("\nFor combined results from datasets i to j, use summary(x, subset = i:j).\nFor separate results, use print(summary(x), subset = i:j).\n\n")
  }
  else {
    if (is.function(subset))
      M <- 1:m
    if (is.numeric(subset))
      M <- subset
    for(i in M){
      cat(paste("\nResult with dataset", i, "\n"))
      print(x$all[[i]], ...)
    }
  }
}

