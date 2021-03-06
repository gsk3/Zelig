\name{makeModelMatrix}
\alias{makeModelMatrix}
\title{Make a Model Matrix from a Zelig-Style Formula}
\usage{
  makeModelMatrix(formula, data)
}
\arguments{
  \item{formula}{a Zelig-style formula}

  \item{data}{a \code{data.frame}}
}
\value{
  a design (or model) matrix
}
\description{
  This is a helper function that creates a
  \code{model.matrix} like object of Zelig-style formulae.
}
\author{
  Matt Owen \email{mowen@iq.harvard.edu}
}

