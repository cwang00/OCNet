\docType{data}
\name{OCN_250_V_hot}
\alias{OCN_250_V_hot}
\title{Example of single-outlet OCN}
\format{A list. See \code{\link{create_OCN}} documentation for details.}
\usage{
data(OCN_250_V_hot)
}
\description{
A network built on a 250x250 lattice obtained by executing \code{set.seed(2); create_OCN(250, 250, typeInitialState = "V", coolingRate = 20, initialNoCoolingPhase = 0.15)}.
}
\keyword{datasets}
