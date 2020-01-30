#' IBD triangle plot
#'
#' The IBD triangle is typically used to visualize the pairwise relatedness of
#' non-inbred individuals. Various annotations are available, including points
#' marking the most common relationships, contour lines for the kinship
#' coefficients, and shading of the unattainable region.
#'
#' For any pair of non-inbred individuals A and B, their genetic relationship
#' can be summarized by the IBD coefficients \eqn{(\kappa_0, \kappa_1,
#' \kappa_2)}{(\kappa0, \kappa1, \kappa2)}, where \eqn{\kappa_i} = P(A and B
#' share i alleles IBD at random autosomal locus). Since \eqn{\kappa_0 +
#' \kappa_1 + \kappa_2 = 1}{\kappa0 + \kappa1 + \kappa2 = 1}, any relationship
#' corresponds to a point in the triangle in the \eqn{(\kappa_0,
#' \kappa_2)}{(\kappa0, \kappa2)}-plane defined by \eqn{\kappa_0 \ge 0, \kappa_2
#' \ge 0, \kappa_0 + \kappa_2 \le 1}{\kappa0 \ge 0, \kappa2 \ge 0, \kappa0 +
#' \kappa2 \le 1}. The choice of \eqn{\kappa_0}{\kappa0} and
#' \eqn{\kappa_2}{\kappa2} as the axis variables is done for reasons of symmetry
#' and is not significant (other authors have used different views of the
#' triangle).
#'
#' As shown in (Thompson, 1976) points in the subset of the triangle defined by
#' \eqn{4\kappa_0\kappa_2 > \kappa_1^2}{4*\kappa0*\kappa2 > \kappa1^2} are
#' unattainable for pairwise relationships. By default this region in shaded in
#' a 'lightgray' colour.
#'
#' The IBD coefficients are linearly related to the kinship coefficient
#' \eqn{\phi} by the formula \deqn{\phi = 0.25\kappa_1 + 0.5\kappa_2.}{\phi =
#' 0.25*\kappa1 + 0.5*\kappa2.} By indicating values for \eqn{\phi} in the
#' `kinshipLines` argument, the corresponding contour lines are shown as dashed
#' lines in the triangle plot.
#'
#' The following abbreviations are valid entries in the `relationships`
#' argument:
#'
#' * UN = unrelated
#'
#' * PO = parent/offspring
#'
#' * MZ = monozygotic twins
#'
#' * S = full siblings
#'
#' * H,U,G = half sibling/avuncular (\strong{u}ncle)/grandparent
#'
#' * FC = first cousins
#'
#' * SC = second cousins
#'
#' * DFC = double first cousins
#'
#' * Q = quadruple first half cousins
#'
#' @param relationships A character vector indicating relationships points to be
#'   included in the plot. See Details for a list of valid entries.
#' @param kinshipLines A numeric vector (see Details).
#' @param shading The shading colour for the unattainable region.
#' @param pch Symbol used for the relationship points (see [par()]).
#' @param cex_points A number controlling the symbol size for the relationship
#'   points.
#' @param cex_text A number controlling the font size for the relationship
#'   labels.
#' @param axes A logical: Draw surrounding axis box?
#' @param xlab,ylab Axis labels
#' @param cex_lab A number controlling the font size for the axis labels.
#' @param xlim,ylim,mar Graphical parameters; see [par()].
#' @param keep.par A logical. If TRUE, the graphical parameters are not reset
#'   after plotting, which may be useful for adding additional annotation.
#' @return None
#' @author Magnus Dehli Vigeland
#' @seealso [IBDestimate()]
#' @references
#'
#' * E. A. Thompson (1975). _The estimation of pairwise relationships._ Annals
#' of Human Genetics 39.
#'
#' * E. A. Thompson (1976). _A restriction on the space of genetic
#' relationships._ Annals of Human Genetics 40.
#'
#' @examples
#' opar = par(no.readonly = TRUE) # store graphical parameters
#'
#' IBDtriangle()
#' IBDtriangle(kinshipLines = c(0.25, 0.125), shading = NULL, cex_text = 0.8)
#'
#' par(opar) # reset graphical parameters
#'
#' @importFrom graphics abline grconvertX grconvertY layout legend mtext par
#'   plot points polygon rect segments text
#'
#' @export
IBDtriangle = function(relationships = c("UN", "PO", "MZ", "S", "H,U,G", "FC"),
                       kinshipLines = numeric(), shading = "lightgray",
                       pch = 16, cex_points = 1.2, cex_text = 1.2, axes = FALSE,
                       xlim = c(0, 1), ylim = c(0, 1),
                       xlab = expression(kappa[0]), ylab = expression(kappa[2]),
                       cex_lab = cex_text, mar = c(3.1, 3.1, 1, 1), keep.par = TRUE) {

    xpd = all(c(xlim, ylim) == c(0,1,0,1))
    opar = par(xpd = xpd, mar = mar, pty = "s")
    if (!keep.par)
      on.exit(par(opar))

    plot(NULL, xlim = xlim, ylim = ylim, axes = axes, ann = FALSE)

    # Axis labels
    mtext(text = c(xlab, ylab), side = 1:2, line = c(1, 0.5), las = 1, cex = cex_lab)

    # impossible region shading(do borders afterwards)
    kk0 = seq(0, 1, length = 501)
    kk2 = 1 + kk0 - 2 * sqrt(kk0)
    polygon(kk0, kk2, col = shading, border = NA)
    # text(.4, .4, 'impossible region', srt = -45)

    # impossible border
    points(kk0, kk2, type = "l", lty = 3)

    # axes
    segments(c(0, 0, 0), c(0, 0, 1), c(1, 0, 1), c(0, 1, 0))

    # kinship lines
    for (phi in kinshipLines) {
        if (phi < 0 || phi > 0.5)
            stop2("kinship coefficient not in intervall [0, 0.5]", phi)
        abline(a = (4 * phi - 1), b = 1, lty = 2)
        labpos.x = 0.5 * (1.2 - (4 * phi - 1))
        labpos.y = 1.2 - labpos.x
        lab = substitute(paste(phi1, " = ", a), list(a = phi))
        text(labpos.x, labpos.y, labels = lab, pos = 3, srt = 45)
    }

    # relationships
    RELS = data.frame(
      label = c("UN", "PO", "MZ", "S", "H,U,G", "FC", "SC", "DFC", "Q"),
      k0 = c(1, 0, 0, 1/4, 1/2, 3/4, 15/16, 9/16, 17/32),
      k1 = c(0, 1, 0, 1/2, 1/2, 1/4, 1/16, 6/16, 14/32),
      k2 = c(0, 0, 1, 1/4, 0, 0, 0, 1/16, 1/32),
      pos = c(1, 1, 4, 4, 1, 1, 1, 3, 4))

    if (length(relationships) > 0) {
        rels = RELS[RELS$label %in% relationships, ]
        points(rels$k0, rels$k2, pch = pch, cex = cex_points)
        text(rels$k0, rels$k2, labels = rels$label, pos = rels$pos, cex = cex_text, offset = 0.7)
    }
}

#' Add points to the IBD triangle
#'
#' Utility function for plotting points in the IBD triangle.
#'
#' @param k0,k2 Numerical vectors giving coordinates for points to be plotted in
#'   the IBD triangle. Alternatively, `k0` may be a data.frame containing columns
#'   named `k0` and `k2`.
#' @param new Logical indicating if a new IBDtriangle should be drawn.
#' @param col,cex,pch,lwd Parameters passed onto [points()].
#' @param labels A character of same length as `k0` and `k2`, or a single
#'   logical `TRUE` or `FALSE`. If TRUE, and `k0` is a data.frame, labels will
#'   be created by pasting columns "ID1" and "ID2", if these are present. By
#'   default, no labels are plotted.
#' @param col_labels,cex_labels,pos,adj Parameters passed onto [text()] (if
#'   `labels` is non-NULL).
#' @param \dots Plot arguments passed on to `IBDtriangle()`.
#'
#' @return None
#' @author Magnus Dehli Vigeland
#' @seealso [IBDestimate()]
#'
#' @examples
#' showInTriangle(k0 = 3/8, k2 = 1/8, label = "3/4 siblings", pos = 1)
#'
#' @export
showInTriangle = function(k0, k2 = NULL, new = TRUE, col = "blue",
                          cex = 1, pch = 4, lwd = 2, labels = FALSE,
                          col_labels = col, cex_labels = 0.8,
                          pos = 1, adj = NULL, ...) {

  if(is.matrix(k0))
    k0 = as.data.frame(k0)

  if(is.data.frame(k0)) {
    if(!is.null(k2))
      stop2("When the first argument is a data.frame, `k2` must be NULL")

    df = k0
    if(!all(c("k0", "k2") %in% names(df)))
      stop2("When the first argument is a data.frame, it must contain columns named `k0` and `k2`")

    k2 = df$k2
    k0 = df$k0 # k0 changes here!

    if(isTRUE(labels)) {
      if(!all(c("ID1", "ID2") %in% names(df)))
        stop2("Trying to create labels, but cannot find necessary column: ",
              setdiff(c("ID1", "ID2"), names(df)))
      labels = paste(df$ID1, df$ID2, sep = "-")
    }
  }
  else {
    if(is.null(k2)) stop2("`k2` is NULL")
    if(length(k0) != length(k2)) stop2("Arguments `k0` and `k2` must have the same length")
  }

  if(is.character(labels) && length(labels) != length(k0))
    stop2("When `labels` is a character, it must have the same length as `k0`")

  if(new) {
    opar = par(no.readonly = TRUE) # store graphical parameters
    on.exit(par(opar))

    IBDtriangle(...)
  }

  points(k0, k2, col = col, pch = pch, lwd = lwd, cex = cex)

  if(is.character(labels))
    text(k0, k2, labels = labels, col = col_labels, cex = cex_labels, pos = pos, adj = adj)
}