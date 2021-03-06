vcov.coxph <- function (object, complete=TRUE, ...) {
    # conform to the standard vcov results
    vmat <- object$var
    vname <- names(object$coefficients)
    dimnames(vmat) <- list(vname, vname)
    if (!complete && any(is.na(coef(object)))) {
        keep <- !is.na(coef(object))
        vmat[keep, keep, drop=FALSE]
        }
    else vmat
}

vcov.survreg<-function (object, complete=TRUE, ...) {
    if (!complete && any(is.na(coef(object)))) {
        keep <- !is.na(coef(object))
        object$var[keep, keep, drop=FALSE]
    }
    else object$var
}

# The extractAIC methods for coxph and survreg objects are defined
#  in the stats package.  Don't reprise them here.
extractAIC.coxph.penal<- function(fit,scale,k=2,...){
    edf<-sum(fit$df)
    loglik <- fit$loglik[length(fit$loglik)]
    c(edf, -2 * loglik + k * edf)
}

extractAIC.coxph.null <- function(fit, scale, k=2, ...) {
    c(0, -2*fit$loglik[1])
}

labels.survreg <- function(object, ...) attr(object,"term.labels")

rep.Surv <- function(x, ...) {
    indx <- rep(1:nrow(x), ...)
    x[indx,]
}

# This function is just like all.vars -- except that it does not recur
#  on the $ sign, it follows both arguments of +, * and - in order to
#  track formulas, all arguments of Surv, and only the first of things 
#  like ns().  And - it works only on formulas.
# This is used to generate a warning in coxph if the same variable is used
#  on both sides, so perfection is not required of the function.
terms.inner <- function(x) {
    if (inherits(x, "formula")) {
        if (length(x) ==3) c(terms.inner(x[[2]]), terms.inner(x[[3]]))
        else terms.inner(x[[2]])
    }
    else if (inherits(x, "call") && 
             (x[[1]] != as.name("$") && x[[1]] != as.name("["))) {
        if (x[[1]] == '+' || x[[1]]== '*' || x[[1]] == '-') {
            # terms in a model equation, unary minus only has one argument
            if (length(x)==3) c(terms.inner(x[[2]]), terms.inner(x[[3]]))
            else terms.inner(x[[2]])
        }
        else if (x[[1]] == as.name("Surv"))
                 unlist(lapply(x[-1], terms.inner))
        else terms.inner(x[[2]])
    }
    else(deparse(x))
}


    
