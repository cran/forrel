% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/kinshipLR.R
\name{kinshipLR}
\alias{kinshipLR}
\title{Likelihood ratios for kinship testing}
\usage{
kinshipLR(
  ...,
  ref = NULL,
  source = NULL,
  markers = NULL,
  likArgs = NULL,
  linkageMap = NULL,
  keepMerlin = NULL,
  verbose = FALSE
)
}
\arguments{
\item{...}{Pedigree alternatives. Each argument should be either a single
\code{ped} object or a list of such. The pedigrees may be named; otherwise they
are assigned names "H1", "H2", ... automatically.

It is also possible to pass a single \code{list} containing all the pedigrees.}

\item{ref}{An index or name indicating which of the input pedigrees should be
used as "reference pedigree", i.e., used in the denominator of each LR. If
NULL (the default), the last pedigree is used as reference.}

\item{source}{An index or name designating one of the input pedigrees as
source for marker data. If given, marker data is transferred from this to
all the other pedigrees (replacing any existing markers). The default
action (\code{source = NULL}) is as follows: If all pedigree have attached
markers, no transfers are done. If exactly one of the pedigrees have
attached markers, these are transferred to the others. all other cases give
an error.}

\item{markers}{A vector of marker names or indices indicating which markers
should be included. If NULL (the default) all markers are used.}

\item{likArgs}{An optional list of arguments to be passed to
\code{\link[pedprobr:likelihood]{pedprobr::likelihood()}}, e.g. \code{likArgs = list(special = TRUE)}.}

\item{linkageMap}{If this is non-NULL, the markers are interpreted as being
linked, and likelihoods will be computed by an external call to MERLIN.

The supplied object should be either:
\itemize{
\item a data frame, whose first three columns must be (i) chromosome (ii)
marker name (iii) centiMorgan position, or
\item a map object created with \code{ibdsim2::uniformMap()} or
\code{ibdsim2::loadMap()}. This will internally be applied to the attached
markers to produce a suitable data frame as above.
}}

\item{keepMerlin}{Either NULL (default) or the path to an existing folder. If
given, MERLIN files are stored here, typically for debugging purposes.}

\item{verbose}{A logical.}
}
\value{
A \code{LRresult} object, which is essentially a list with entries
\itemize{
\item \code{LRtotal} : A vector of length \code{L}, where \code{L} is the number of input
pedigrees. The i'th entry is the total LR (i.e., the product over all
markers) comparing pedigree \code{i} to the reference pedigree. The entry
corresponding to the reference will always be 1.
\item \code{LRperMarker} : A numerical matrix, where the i'th column contains the
marker-wise LR values comparing pedigree \code{i} to the reference. The product
of all entries in a column should equal the corresponding entry in
\code{LRtotal}.
\item \code{likelihoodsPerMarker} : A numerical matrix of the same dimensions as
\code{LRperMarker}, but where the entries are likelihood of each pedigree for
each marker.
\item \code{time} : Elapsed time
}
}
\description{
This function computes likelihood ratios (LRs) for a list of pedigrees. One
of the pedigrees (the last one, by default) is designated as 'reference', to
be used in the denominator in all LR calculations. To ensure that all
pedigrees use the same data set, one of the pedigrees may be chosen as
'source', from which data is transferred to all the other pedigrees.
}
\details{
By default, all markers are assumed to be unlinked. To accommodate linkage, a
genetic map may be supplied with the argument \code{linkageMap}. This requires the
software MERLIN to be installed.
}
\examples{

### Example 1: Full vs half sibs

# Simulate 5 markers for a pair of full sibs
ids = c("A", "B")
sibs = nuclearPed(children = ids)
sibs = simpleSim(sibs, N = 5, alleles = 1:4, ids = ids, seed = 123)

# Create two alternative hypotheses
halfsibs = relabel(halfSibPed(), old = 4:5, new = ids)
unrel = singletons(c("A", "B"))

# Compute LRs. By default, the last ped is used as reference
kinshipLR(sibs, halfsibs, unrel)

# Input pedigrees can be named, reflected in the output
kinshipLR(S = sibs, H = halfsibs, U = unrel)

# Select non-default reference (by index or name)
kinshipLR(S = sibs, H = halfsibs, U = unrel, ref = "H")

# Alternative syntax: List input
peds = list(S = sibs, H = halfsibs, U = unrel)
kinshipLR(peds, ref = "H", source = "S", verbose = TRUE)

# Detailed results
res = kinshipLR(peds)
res$LRperMarker
res$likelihoodsPerMarker


### Example 2: Separating grandparent/halfsib/uncle-nephew
\donttest{
# Requires ibdsim2 and MERLIN
if(requireNamespace("ibdsim2", quietly = TRUE) && pedprobr::checkMerlin()) {

  # Load recombination map
  map = ibdsim2::loadMap("decode19", uniform = TRUE)   # unif for speed

  # Define pedigrees
  ids = c("A", "B")
  H = relabel(halfSibPed(),   old = c(4,5), new = ids)
  U = relabel(avuncularPed(), old = c(3,6), new = ids)
  G = relabel(linearPed(2),   old = c(1,5), new = ids)

  # Attach FORCE panel of SNPs to G
  G = setSNPs(G, FORCE[1:10, ])  # use all for better results

  # Simulate recombination pattern in G
  ibd = ibdsim2::ibdsim(G, N = 1, ids = ids, map = map)

  # Simulate genotypes conditional on pattern
  G = ibdsim2::profileSimIBD(G, ibdpattern = ibd)

  # Compute LR (genotypes are automatically transferred to H and U)
  kinshipLR(H, U, G, linkageMap = map)
}}

}
\seealso{
\code{\link[=LRpower]{LRpower()}}, \code{\link[pedprobr:likelihood]{pedprobr::likelihood()}},
\code{\link[pedprobr:merlin]{pedprobr::likelihoodMerlin()}}
}
\author{
Magnus Dehli Vigeland and Thore Egeland
}
