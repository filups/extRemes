"gpdf.gui" <-
function( base.txt) {

#
# This function provides a gui for Stuart Coles
# 'gpd.fit' function and helpers
#



#  Set the tcl variables
lmom.var <- tclVar(0)
plot.diags<-tclVar(0)
threshold.value <- tclVar("")
npy <- tclVar("365.25")
sig.link<-tclVar("identity")
gam.link<-tclVar("identity")
save.as.value <- tclVar("")
maxit.value <- tclVar("10000")

#########################################
# internal functions
#########################################

refresh <- function() {

# when a data object is chosen, this function will reset the various lists
# to have the correct covariates, etc... (at least in theory)

if( !is.nothing) {
	data.select <- as.numeric( tkcurselection( data.listbox))+1
	dd <- get( full.list[ data.select])
	} else dd <- extRemesData

	tkdelete( resp.listbox, 0.0, "end")
	tkdelete( sig.covlist, 0.0, "end")
	tkdelete( gam.covlist, 0.0, "end")

	for( i in 1:ncol(dd$data))
        	tkinsert( resp.listbox, "end",
			paste( colnames( dd$data)[i]))
		# end of for i loop

	for (i in 1:ncol(dd$data))
        	tkinsert(sig.covlist,"end",
			paste(colnames(dd$data)[i]))
		# end of for i loop

	for (i in 1:ncol(dd$data))
        	tkinsert(gam.covlist,"end",
			paste(colnames(dd$data)[i]))
		# end of for i loop

	} # end of refresh fcn

redolists<-function() {
# When a response variable is selected, this function eliminates it
#  as a covariate option from the other lists.

if( !is.nothing) {
	data.select <- as.numeric( tkcurselection( data.listbox))+1
	dd <- get( full.list[ data.select])
	} else dd <- extRemesData

dd2 <- dd$data[, as.numeric( tkcurselection( resp.listbox))+1]

resp.name <-
	colnames(dd$data)[as.numeric(tkcurselection(resp.listbox))+1] 

    # put the correct eligible covariates in the other list boxes
    tkdelete(sig.covlist,0.0,"end")
    tkdelete(gam.covlist,0.0,"end")

	for (i in colnames(dd$data)) {
		if (i != resp.name) {
        		tkinsert(sig.covlist,"end",i)
        		tkinsert(gam.covlist,"end",i)
      		} # end of if i != resp.name stmt
 
	} # end of for i loop    
} # end of redolists fcn

submit <- function() {
    #
    # The meat of this program.  Actually fits the gpd to the data.
    #

    # names of the covariates used (if any) 
    cov.names.cmd <- "cov.names<-character(0)"
	eval( parse( text=cov.names.cmd))
        write( cov.names.cmd, file="extRemes.log", append=TRUE)

	if( !is.nothing) {
		data.select <- as.numeric( tkcurselection( data.listbox))+1
		dd.cmd <- paste( "dd <- get( \"", full.list[ data.select], "\")", sep="")
	} else dd.cmd <- "dd <- extRemesData"
	eval( parse( text=dd.cmd))
	write( dd.cmd, file="extRemes.log", append=TRUE)

    resp.select<-as.numeric(tkcurselection(resp.listbox))+1
 
    # make sure that a response was selected
    if (is.na(resp.select))
      return()


    # tkconfigure(base.txt,state="normal")
    # tkinsert(base.txt,"end",paste("GPD fit \n"))
    # tkinsert(base.txt,"end",paste("-----------------------------------\n"))
    # tkinsert(base.txt,"end",paste("Response variable:",
     #         colnames( dd$data)[resp.select],"\n"))

    # process the covariates and link functions
	covs.cmd <- "covs <- NULL"
	eval( parse( text=covs.cmd))
	write( covs.cmd, file="extRemes.log", append=TRUE)
	cur.cov.cols <- 0

	istherecovs <- FALSE

# do the sigma 
   
    # sig.cov.cols<-NULL 
    if (tclvalue( tkcurselection(sig.covlist)) !="") {

     # get the right covariates
     # temp.cols<-as.numeric(strsplit(tkcurselection(sig.covlist)," ")[[1]])
temp.cols <- 
	as.numeric( unlist( strsplit( tclvalue( tkcurselection(sig.covlist)), " ")))
      cov.selected.cmd <- "cov.selected<-character(0)"
	eval( parse( text=cov.selected.cmd))
	write( cov.selected.cmd, file="extRemes.log", append=TRUE)
      for (i in temp.cols) {
        cov.selected.cmd <- paste( "cov.selected<-c(cov.selected, \"", tclvalue( tkget(sig.covlist,i)), "\")", sep="")
	eval( parse( text=cov.selected.cmd))
	write( cov.selected.cmd, file="extRemes.log", append=TRUE)
      }
 
      # match the covariate names to the cols of  dd
 
      dat.cols.cmd <- "dat.cols<-numeric(0)"
	eval( parse( text=dat.cols.cmd))
	write( dat.cols.cmd, file="extRemes.log", append=TRUE)
      for (j in 1:length(colnames( dd$data))) {
        for (i in cov.selected) {
          if (i == colnames( dd$data)[j]) {
            dat.cols.cmd <- paste( "dat.cols<-c(dat.cols, ", j, ")", sep="")
		eval( parse( text=dat.cols.cmd))
		write( dat.cols.cmd, file="extRemes.log", append=TRUE)
          }
        }
      }
      # covs <- cbind(covs,as.matrix( dd$data[,dat.cols]))
	# covs.cmd <- paste( "covs <- cbind( covs, ", "as.matrix( ", full.list[ data.select],
	# 							"$data[,", dat.cols, "]))", sep="")
	covs.cmd <- "covs <- cbind( covs, as.matrix( dd[[\"data\"]][, dat.cols]))"
	eval( parse( text=covs.cmd))
	write( covs.cmd, file="extRemes.log", append=TRUE)

      # sig.cov.cols.cmd <- "sig.cov.cols<-(cur.cov.cols+1):(length(dat.cols)+cur.cov.cols)"
	sig.cov.cols.cmd <- paste("sig.cov.cols <- ", cur.cov.cols+1,":", length(dat.cols)+cur.cov.cols, sep="")
        eval( parse( text=sig.cov.cols.cmd))
	write( sig.cov.cols.cmd, file="extRemes.log", append=TRUE)

      cur.cov.cols<-cur.cov.cols+length(dat.cols)
      # cov.names<-c(cov.names,colnames( dd$data)[dat.cols])
	cov.names.cmd <- "cov.names <- c( cov.names, colnames( dd[[\"data\"]])[dat.cols])"
	eval( parse( text=cov.names.cmd))
	write( cov.names.cmd, file="extRemes.log", append=TRUE)

	istherecovs <- TRUE
    } else {
	sig.cov.cols.cmd <- "sig.cov.cols<-NULL"
	eval( parse( text=sig.cov.cols.cmd))
	write( sig.cov.cols.cmd, file="extRemes.log", append=TRUE)
	}


    # do the gamma
    
    # gam.cov.cols<-NULL
    if (tclvalue( tkcurselection(gam.covlist)) !="") {

     # get the right covariates
     #  temp.cols<-as.numeric(strsplit(tkcurselection(gam.covlist)," ")[[1]])
	temp.cols <- as.numeric( unlist( strsplit( tclvalue( tkcurselection(gam.covlist)), " ")))
      cov.selected.cmd <- "cov.selected<-character(0)"
	eval( parse( text=cov.selected.cmd))
	write( cov.selected.cmd, file="extRemes.log", append=TRUE)
      for (i in temp.cols) {
        cov.selected.cmd <- paste( "cov.selected<-c(cov.selected, \"", tclvalue( tkget(gam.covlist,i)), "\")", sep="")
	eval( parse( text=cov.selected.cmd))
	write( cov.selected.cmd, file="extRemes.log", append=TRUE)
      }
 
      # match the covariate names to the cols of  dd

	dat.cols.cmd <- "dat.cols<-numeric(0)"
	eval( parse( text=dat.cols.cmd))
	write( dat.cols.cmd, file="extRemes.log", append=TRUE) 
      for (j in 1:length(colnames( dd$data))) {
        for (i in cov.selected) {
          if (i == colnames( dd$data)[j]) {
            dat.cols.cmd <- paste( "dat.cols<-c(dat.cols, ", j, ")", sep="")
		eval( parse( text=dat.cols.cmd))
		write( dat.cols.cmd, file="extRemes.log", append=TRUE)
          }
        }
      }

      # covs <- cbind(covs,as.matrix( dd$data[,dat.cols]))
	# covs.cmd <- paste( "cbind( covs, as.matrix( ", full.list[ data.select], "$data[,", dat.cols, "]))", sep="")
	covs.cmd <- "covs <- cbind( covs, as.matrix( dd[[\"data\"]][, dat.cols]))"
	eval( parse( text=covs.cmd))
	write( covs.cmd, file="extRemes.log", append=TRUE)

      # gam.cov.cols.cmd <- "gam.cov.cols<-(cur.cov.cols+1):(length(dat.cols)+cur.cov.cols)"
	gam.cov.cols.cmd <- paste("gam.cov.cols <- ", cur.cov.cols+1, ":", length(dat.cols)+cur.cov.cols, sep="")
        eval( parse( text=gam.cov.cols.cmd))
	write( gam.cov.cols.cmd, file="extRemes.log", append=TRUE)
      cur.cov.cols<-cur.cov.cols+length(dat.cols)
      # cov.names<-c(cov.names,colnames( dd$data)[dat.cols])
	cov.names.cmd <- "cov.names <- c( cov.names, colnames( dd[[\"data\"]])[ dat.cols])"
	eval( parse( text=cov.names.cmd))
	write( cov.names.cmd, file="extRemes.log", append=TRUE)

	istherecovs <- TRUE
    } else {
	gam.cov.cols.cmd <- "gam.cov.cols<-NULL"
	eval( parse( text=gam.cov.cols.cmd))
	write( gam.cov.cols.cmd, file="extRemes.log", append=TRUE)
	}


    # process the link functions for each
    if (tclvalue(sig.link) =="identity") {
      sig.linker.cmd <- "sig.linker<-identity"
    }
    else {
      sig.linker.cmd <- "sig.linker<-exp"
    }
	eval( parse( text=sig.linker.cmd))
	write( sig.linker.cmd, file="extRemes.log", append=TRUE)

    if (tclvalue(gam.link) =="identity") {
      gam.linker.cmd <- "gam.linker<-identity"
    }
    else {
      gam.linker.cmd <- "gam.linker<-exp"
    }
	eval( parse( text=gam.linker.cmd))
	write( gam.linker.cmd, file="extRemes.log", append=TRUE)

method.list <- c("Nelder-Mead", "BFGS", "CG", "L-BFGS-B", "SANN")
method.select <- as.numeric( tkcurselection( method.listbox))+1
if( length( method.select) == 0) {
                cat( paste( "No optimization method selected.  Using \"Nelder-Mead\"",
                        "(use \'help( optim)\' for more details)"), sep="\n")
                method.value <- "Nelder-Mead"
} else method.value <- method.list[ method.select]

maxit.val <- as.numeric( tclvalue( maxit.value))

number.of.models <- length( dd$models)
names.of.models <- names( dd$models)
if( is.null( names.of.models)) names.of.models <- character(0)
jj <- 0
if( number.of.models > 0) for( i in 1:number.of.models) if( class( dd$models[[i]]) == "gpd.fit") jj <- jj+1
names.of.models <- c( names.of.models, paste( "gpd.fit", jj+1, sep=""))

# data.cmd <- paste( "xdata <- ", full.list[ data.select], "$data[,", resp.select, "]", sep="")
data.cmd <- paste( "xdata <- dd[[\"data\"]][, ", resp.select, "]", sep="")
eval( parse( text=data.cmd))
write( data.cmd, file="extRemes.log", append=TRUE)

# fit the GPD
if( tclvalue(lmom.var)==1) {
   cmd <- paste( "utmp <- ",  as.numeric( tclvalue( threshold.value)), sep="")
   eval( parse( text=cmd))
   write( cmd, file="extRemes.log", append=TRUE)

   cmd <- "lmom <- Lmoments( xdata[ xdata>utmp] - utmp)"
   eval( parse( text=cmd))
   write( cmd, file="extRemes.log", append=TRUE)

   cmd <- "tau2 <- lmom[2]/lmom[1]"
   eval( parse( text=cmd))
   write( cmd, file="extRemes.log", append=TRUE)

   cmd <- "sigma <- lmom[1]*(1/tau2 - 1)"
   eval( parse( text=cmd))
   write( cmd, file="extRemes.log", append=TRUE)

   cmd <- "kappa <- 1/tau2 - 2"
   eval( parse( text=cmd))
   write( cmd, file="extRemes.log", append=TRUE)

   cmd <- "xi <- -kappa"
   eval( parse( text=cmd))
   write( cmd, file="extRemes.log", append=TRUE)

   if( !is.null( sig.cov.cols)) {
      cmd <- paste( "sigma <- c( sigma, rep(0, ", length( sig.cov.cols), "))", sep="")
      eval( parse( text=cmd))
      write( cmd, file="extRemes.log", append=TRUE)
  }

      if( !is.null( gam.cov.cols)) {
      cmd <- paste( "xi <- c( xi, rep(0, ", length( gam.cov.cols), "))", sep="")
      eval( parse( text=cmd))
      write( cmd, file="extRemes.log", append=TRUE)
   }

   cmd <- paste( "dd[[\"models\"]][[\"gpd.fit", jj+1, "\"]] <- ",
                "gpd.fit( xdat=xdata, threshold=", as.numeric( tclvalue( threshold.value)), ", npy=",
                as.numeric( tclvalue( npy)),
                ", ydat=covs, sigl=sig.cov.cols, siglink=sig.linker, shl=gam.cov.cols, shlink=gam.linker, ",
		"siginit=sigma, shinit=xi, ",
                "method=\"", method.value,"\"", ", maxit=", maxit.val, ", show=FALSE)", sep="")
   eval( parse( text=cmd))
   write( cmd, file="extRemes.log", append=TRUE)

   cat("\n", "L-moments estimates for (stationary) GPD are:\n")
   cat("scale: ", sigma[1], "\n")
   cat("shape: ", xi[1], "\n")
   cat("These L-moments estimators were used as initial parameter estimates.\n")
} else {
   cmd <- paste( "dd[[\"models\"]][[\"gpd.fit", jj+1, "\"]] <- ",
		"gpd.fit( xdat=xdata, threshold=", as.numeric( tclvalue( threshold.value)), ", npy=",
		as.numeric( tclvalue( npy)),
		", ydat=covs, sigl=sig.cov.cols, siglink=sig.linker, shl=gam.cov.cols, shlink=gam.linker, ",
		"method=\"", method.value,"\"", ", maxit=", maxit.val, ", show=FALSE)", sep="")
   # dd$models[[number.of.models+1]] <-
   eval( parse( text=cmd))
   # cmd <- paste( full.list[ data.select], "$models$", names.of.models[number.of.models+1], " <- ", cmd, sep="")
   write( cmd, file="extRemes.log", append=TRUE)
}

if( !istherecovs) {
           cmd <- paste( "tmpfit <- dd[[\"models\"]][[\"gpd.fit", jj+1, "\"]]", sep="")
           eval( parse( text=cmd))
           write( cmd, file="extRemes.log", append=TRUE)

	   cmd <- paste( "utmp <- ", as.numeric( tclvalue( threshold.value)), sep="")
           eval( parse( text=cmd))
           write( cmd, file="extRemes.log", append=TRUE)

	   cmd <- "tmpn <- sum( xdata > utmp, na.rm=TRUE)"
	   eval( parse( text=cmd))
           write( cmd, file="extRemes.log", append=TRUE)
	   
	   cmd <- "sigma <- mean( xdata[xdata>utmp] - utmp, na.rm=TRUE)"
	   eval( parse( text=cmd))
           write( cmd, file="extRemes.log", append=TRUE)

	   cmd <- "Sx <- sum( xdata[xdata>utmp] - utmp, na.rm=TRUE)"
	   eval( parse( text=cmd))
           write( cmd, file="extRemes.log", append=TRUE)

	   cmd <- "m0 <- tmpn*log( sigma) + Sx/sigma"
	   eval( parse( text=cmd))
           write( cmd, file="extRemes.log", append=TRUE)

	   cmd <- "m1 <- tmpfit[[\"nllh\"]]"
	   eval( parse( text=cmd))
           write( cmd, file="extRemes.log", append=TRUE)

           cmd <- "Dev <- deviancestat( m0, m1, v=1)"
           eval( parse( text=cmd))
           write( cmd, file="extRemes.log", append=TRUE)

           if( Dev$DS > Dev$c.alpha) {
                cat( "\n", "Likelihood ratio test (5% level) for xi=0 does not accept Exponential hypothesis.\n")
                cat( "likelihood ratio statistic is ",  Dev$DS, " > ", Dev$c.alpha, " 1 df chi-square critical value.\n")
           } else {
                cat( "\n", "Likelihood ratio test (5% level) for xi=0 does not reject Exponential hypothesis.\n")
                cat( "likelihood ratio statistic is ",  Dev$DS, " < ", Dev$c.alpha, " 1 df chi-square critical value.\n")
           }
           cat("\n", "p-value for likelihood-ratio test is ", Dev$p.val, "\n")
        } # end of if !istherecovs stmts.


# class( dd$models[[number.of.models+1]]) <- "gpd.fit"
# class.cmd <- paste( "class(", full.list[ data.select], "$models$gpd.fit", jj+1, ") <- \"gpd.fit\"", sep="")
# class.cmd <- paste( "class( dd[[\"models\"]][[\"gpd.fit", jj+1, "\"]]) <- \"gpd.fit\"", sep="")
# eval( parse( text=class.cmd))
# write( class.cmd, file="extRemes.log", append=TRUE)

# names( dd$models) <- names.of.models
# add.new.model.name.cmd <- paste( "names( ", full.list[ data.select], "[[\"models\"]]) <- names.of.models", sep="")
# eval( parse( text=add.new.model.name.cmd))
# write( add.new.model.name.cmd, file="extRemes.log", append=TRUE)

# tmp <- eval( parse( text=cmd))
# dd$models[[number.of.models+1]] <- eval( parse( text=cmd))
# cmd <- paste( full.list[ data.select], "[[\"models\"]][[", number.of.models+1, "]] <- ", cmd, sep="")
# 	gpd.fit(	xdat=dd$data[,resp.select],
# 			threshold=as.numeric( tclvalue( threshold.value)),
# 			npy=as.numeric( tclvalue( npy)),
# 			ydat=covs,
# 			sigl=sig.cov.cols,
# 			siglink=sig.linker,
# 			shl=gam.cov.cols,
# 			shlink=gam.linker,
# 			method=method.value,
# 			maxit=maxit.val)
# if( is.null( dd$models)) dd$models <- list()
# names( dd$models) <- names.of.models
# class( dd$models[[number.of.models+1]]) <- "gpd.fit"

# fit.obj.cmd <- paste( "fit.obj <- ", full.list[ data.select], "[[\"models\"]][[", number.of.models+1,"]]", sep="")
# eval( parse( text=fit.obj.cmd))
# write( fit.obj.cmd, file="extRemes.log", append=TRUE)

if( is.null( dd$models[[number.of.models+1]])) {
      # failure to fit

      # fail.str<-paste(" ", "Fit failed.", " ", sep="\n")
	cat("\n", "Fit failed.\n")
      # tkinsert(base.txt,"end",fail.str)
      tkyview.moveto(base.txt,1.0)

    }
    else {

	if( is.nothing) assignCMD <- "assign( \"extRemesData\", dd, pos=\".GlobalEnv\")"
	else assignCMD <- paste( "assign( \"", full.list[ data.select], "\", dd, pos=\".GlobalEnv\")", sep="")
	eval( parse( text=assignCMD))
	write( assignCMD, file="extRemes.log", append=TRUE)
	# write( cmd, file="extRemes.log", append=TRUE)
      # print the output

	# fit.obj <- dd$models[[number.of.models+1]]

      links<-c( tclvalue(sig.link), tclvalue(gam.link))

# Print some informative output to the main gui window.
## Print to R console instead.
	# tkconfigure( base.txt, state="normal")
	# nl1 <- paste( " ", "**********", " ", sep="\n")
        # nl2 <- paste( "   ", "   ", sep="\n")
	# tkinsert( base.txt, "end", nl1)
        # tkinsert( base.txt, "end", nl2)

        # Print info about convergence of 'optim' function.
# fit.obj <- get( full.list[ data.select])$models[[number.of.models+1]]
# fit.obj.cmd <- paste( full.list[ data.select], "[[\"models\"]][[", number.of.models+1, "]]", sep="")
fit.obj.cmd <- paste( "fit.obj <- dd[[\"models\"]][[\"gpd.fit", jj+1, "\"]]", sep="")
eval( parse( text=fit.obj.cmd))
# write( fit.obj.cmd, file="extRemes.log", append=TRUE)
if( fit.obj$conv == 0) cat("\n", "Convergence successfull!\n") # CONV.msg <- paste("Convergence successfull!")
else if( fit.obj$conv == 1) {
	cat("\n", "Iteration limit exceeded.\n")
	cat("Did not converge.\n")
# CONV.msg <- paste("Iteration limit exceeded.",
#                                         "Did not convergence.", sep="\n")
	} else if( fit.obj$conv == 51 | fit.obj$conv == 52) cat("\n", fit.obj$message, "\n")#CONV.msg<-paste(fit.obj$message)
 	else cat( "\n", "Convergence code: ", fit.obj$conv, " (See help file for optim for more info).\n")

# CONV.msg <- paste("Convergence code: ", fit.obj$conv, " (See help file for optim for more info)", sep="")
# 
#         tkinsert( base.txt, "end", CONV.msg)
#         tkinsert( base.txt, "end", nl2)
# 	tkinsert( base.txt, "end", nl2)
#         Thresh.msg <- paste( paste("Threshold = ", fit.obj$threshold, sep=""),
#                                 paste("Number of exceedances = ", fit.obj$nexc, sep=""),
#                                 paste("Exceedance rate (per year) = ", fit.obj$rate*fit.obj$npy, sep=""), sep="\n")
#         tkinsert( base.txt, "end", Thresh.msg)
#         tkinsert( base.txt, "end", nl2)
#         tkinsert( base.txt, "end", nl2)
 	# rnames <- c( paste("SIGMA: (", links[1], ")	", sep = ""))
 	# rnames <- c(rnames, paste("Xi: (", links[2], ")	", sep = ""))
#

## Prepare summary information.
c1 <- cbind( fit.obj$mle, fit.obj$se)
colnames( c1) <- c( "MLE", "Std. Err.")
if( tclvalue( sig.link)=="log") rnames <- c( paste( "log Scale: ", sep=""))
        else rnames <- c( paste( "Scale (sigma): ", sep=""))
         if( !is.null( fit.obj$model[[1]]))
                 rnames <- c( rnames, paste( cov.names[ fit.obj$model[[1]]], sep=""))
                        #       ": (", links[1], ")     ", sep=""))
        if( tclvalue( gam.link) == "log") rnames <- c(rnames, paste("log Shape: ", sep=""))
        else rnames <- c( rnames, paste("Shape (xi): ", sep=""))
if( !is.null( fit.obj$model[[2]])) rnames <- c(rnames, paste( cov.names[ fit.obj$model[[2]]], sep=""))
                        #       ": (", links[2], ")     ", sep=""))
rownames( c1) <- rnames
dd$models[[number.of.models+1]]$parameter.names <- rnames
dd$models[[number.of.models+1]]$summary1 <- c1

# summary( dd$models[[number.of.models+1]])
# msg.cmd <- paste( "summary( ", full.list[ data.select], "$models$", names.of.models[number.of.models+1], ")", sep="")
msg.cmd <- paste( "print( summary( dd[[\"models\"]][[\"gpd.fit", jj+1, "\"]]))", sep="")
eval( parse( text=msg.cmd))
write( msg.cmd, file="extRemes.log", append=TRUE)

# names( dd$models) <- names.of.models
# class( dd$models[[number.of.models+1]]) <- "gpd.fit"
 
  	 if( is.nothing) assignCMD <- "assign( \"extRemesData\", dd, pos=\".GlobalEnv\")"
         else assignCMD <- paste( "assign( \"", full.list[ data.select], "\", dd, pos=\".GlobalEnv\")", sep="")
	eval( parse( text=assignCMD))
	write( assignCMD, file="extRemes.log", append=TRUE)
# 
#         tkinsert( base.txt, "end", paste( "			",
# 			colnames( c1)[1], "		",
# 			colnames( c1)[2]))
#         tkinsert( base.txt, "end", nl2)
#         for( i in 1:dim( c1)[1]) {
#                 tkinsert( base.txt, "end",
#                         paste( rownames( c1)[i], " ",
# 				round( c1[i,1], digits=5),
# 				"	",
# 				round( c1[i,2], digits=5), sep=""))
#                 tkinsert( base.txt, "end", nl2)
#                 } # end of for i loop
#         tkinsert( base.txt, "end", nl2)
# 
#       nllh.str <- paste( "\n Negative log likelihood:",
#                         round(dd$models[[number.of.models+1]]$nllh,4),"\n")
#       tkinsert( base.txt, "end", nllh.str)
#       tkinsert( base.txt,"end", nl1)
 	final.msg <- paste("Model name: ", names.of.models[number.of.models+1], sep="")
	cat( final.msg)
# 	tkinsert( base.txt, "end", final.msg)
#       tkyview.moveto( base.txt, 1.0)

      # plot diagnostics if requested

      if (tclvalue(plot.diags)==1) {
	# plotcmd <- paste( "plot( ", full.list[ data.select], "$models[[", number.of.models+1,"]])", sep="")
	plotCMD <- paste( "plot( dd[[\"models\"]][[\"gpd.fit", jj+1, "\"]])", sep="")
	eval( parse( text=plotCMD))
	write( plotCMD, file="extRemes.log", append=TRUE)
	# plot( dd$models[[number.of.models+1]])
      }

    }
 
    tkdestroy(base)
    # tkconfigure(base.txt,state="disabled")
} # end of submit fcn

gpdfithelp <- function() {
	cat("\n", "Invokes the \'ismev\' function \'gpd.fit\'.  ", "\n", "Use \'help( gpd.fit)\' for more help.\n")
	# help( gpd.fit)
	cat("\n", "If \'Calculate L-moments\' is selected, then L-moments estimates will be displayed, and\n")
	cat("they will be used as initial estimates in the MLE optimization routine.\n")
	} # end of gpdfithelp fcn

  endprog<-function() {
	tkdestroy(base)
  }

#################################
# Frame/button setup
#################################


base<-tktoplevel()
tkwm.title(base,"Fit Data to Generalized Pareto (GP) Distribution")

data.frm <- tkframe( base, borderwidth=2, relief="groove")
top.frm <- tkframe(base,borderwidth=2,relief="groove")
bot.frm <- tkframe(base,borderwidth=2,relief="groove")
args.frm <- tkframe( base, borderwidth=2, relief="groove")
threshold.frm <- tkframe( args.frm, borderwidth=2, relief="groove")
npy.frm <- tkframe( args.frm, borderwidth=2, relief="groove")
optim.frm <- tkframe( base, borderwidth=2, relief="groove")
method.frm <- tkframe( optim.frm, borderwidth=2, relief="flat")
maxit.frm <- tkframe( optim.frm, borderwidth=2, relief="flat")

# Choose which data object to use (set the listbox to contain all objects of
# class "extRemesDataObject").

data.listbox <- tklistbox(data.frm,
			yscrollcommand=function(...) tkset(data.scroll,...),
			selectmode="single",
			width=20,
			height=5,
			exportselection=0)

data.scroll <- tkscrollbar( data.frm, orient="vert",
			command=function(...)tkyview(data.listbox,...))

# initialize variables for data list.
# 'temp' is list of everything in global environment.
# 'full.list' will be list of all objects in '.GlobalEnv' of class "extRemesDataObject".
temp <- ls(all.names=TRUE, name=".GlobalEnv")
is.nothing <- TRUE
full.list <- character(0)
for( i in 1:length( temp)) {
	if( is.null( class( get( temp[i])))) next
	if( (class( get( temp[i]))[1] == "extRemesDataObject")) {
		tkinsert( data.listbox, "end", paste( temp[i]))
		full.list <- c( full.list, temp[i])
		is.nothing <- FALSE
		}
} # end of for i loop

tkpack( tklabel( data.frm, text="Data Object", padx=4), side="left")
tkpack( data.listbox, side="left")
tkpack( data.scroll, side="right", fill="y")
tkpack( data.frm)

# place binding on data.listbox to reflect the chosen data from the list.
tkbind( data.listbox, "<ButtonRelease-1>", refresh)

# top frame for response variable

top.r <- tkframe(top.frm,borderwidth=2)
top.l <- tkframe(top.frm,borderwidth=2)
resp.listbox <-
	tklistbox(top.l,yscrollcommand=function(...)tkset(resp.scroll,...),
			selectmode="single",width=35,height=4,exportselection=0)
resp.scroll <- tkscrollbar(top.l,orient="vert",
			command=function(...)tkyview(resp.listbox,...))
if( is.nothing) {
for( i in 1:ncol( extRemesData$data)) 
	tkinsert( resp.listbox, "end", paste(colnames( extRemesData$data)[i]))  
# end of for i loop
	} else tkinsert( resp.listbox, "end", "")

tkpack(tklabel(top.l,text="Response:",padx=4), side="top")
tkpack(resp.listbox, resp.scroll, side="left", fill="y")

# place binding on resp.listbox to eliminate the response from the 
# lists of covs.
tkbind(resp.listbox,"<ButtonRelease-1>",redolists)

# threshold frame

threshold.entry <- tkentry( threshold.frm, textvariable=threshold.value,
						width=5)

tkpack( tklabel( threshold.frm, text="Threshold", padx=4),
		threshold.entry, side="left")

# npy frame

# npy.value <- tkscale(	npy.frm,
# 			variable=npy,
# 			tickinterval=182,
# 			length=250,
# 			from=0,
# 			to=365,
# 			label="Number of obs per year",
# 			orient="horizontal")
npy.entry <- tkentry( npy.frm, textvariable=npy, width=6)
tkpack( tklabel( npy.frm, text="Number of obs per year", padx=4),
	npy.entry, side="left")
tkpack( threshold.frm, npy.frm, side="left", fill="both")

param.frm <- tkframe( top.r, borderwidth=2, relief="groove")
sig.frm <- tkframe( param.frm, borderwidth=2, relief="groove")
gam.frm <- tkframe( param.frm, borderwidth=2, relief="groove")

# sigma frame
 
sig.l <- tkframe(sig.frm,borderwidth=2)
sig.r <- tkframe(sig.frm,borderwidth=2)
sig.covlist <-
	tklistbox(sig.l,yscrollcommand=function(...)tkset(sig.covscr,...),
		selectmode="multiple",width=15,height=4,exportselection=0)
sig.covscr <- tkscrollbar(sig.l,orient="vert",
		command=function(...)tkyview(sig.covlist,...))

if( is.nothing) { 
for (i in 1:ncol( extRemesData$data)) 
	tkinsert(sig.covlist,"end",paste(colnames( extRemesData$data)[i]))
# end of for i loop
	} else tkinsert( sig.covlist, "end", "")

tkpack(sig.covlist,side="left")
tkpack(sig.covscr,side="right",fill="y")
 
tkpack(tklabel(sig.r,text="Link:"),side="left")

for (i in c("identity","log")) {
	tmp <- tkradiobutton(sig.r,text=i,value=i,variable=sig.link)
	tkpack(tmp,anchor="w")
} # end of for i loop
 
tkpack( sig.l, side="top") 
tkpack( sig.r, side="top", before=sig.l)
tkpack( tklabel( sig.frm, text="Scale parameter (sigma):", padx=4), side="top", before=sig.r)

# gamma frame
 
gam.l <- tkframe( gam.frm, borderwidth=2)
gam.r <- tkframe( gam.frm, borderwidth=2)
gam.covlist <-
	tklistbox(gam.l,yscrollcommand=function(...)tkset(gam.covscr,...),
		selectmode="multiple",width=15,height=4,exportselection=0)
gam.covscr <- tkscrollbar(gam.l,orient="vert",
		command=function(...)tkyview(gam.covlist,...))

if( is.nothing) { 
for (i in 1:ncol( extRemesData$data))
	tkinsert(gam.covlist,"end",paste(colnames( extRemesData$data)[i]))
# end of for i loop
	} else tkinsert( gam.covlist, "end", "")

tkpack( gam.covlist, side="left")
tkpack( gam.covscr, side="right", fill="y")
 
tkpack( tklabel( gam.r, text="Link:"), side="left")
for (i in c("identity","log")) {
	tmp <- tkradiobutton(gam.r,text=i,value=i,variable=gam.link)
	tkpack(tmp,anchor="w")
} # end of for i loop
 
tkpack( gam.l, side="top")
tkpack( gam.r, side="top", before=gam.l)
tkpack( tklabel( gam.frm, text="Shape parameter (xi):",padx=4), side="top", before=gam.r)

lmom.but <- tkcheckbutton(top.r,text="Calculate L-moments",variable=lmom.var)
plot.but<- tkcheckbutton(top.r,text="Plot diagnostics",variable=plot.diags)
tkpack(lmom.but, plot.but,side="top")

tkpack(top.l,top.r,side="left")

# method frame

method.listbox <- tklistbox( method.frm,
                        yscrollcommand=function(...)tkset(methodscr,...),
                        selectmode="single",
                        width=50,
                        height=1,
                        exportselection=0)

methodscr <- tkscrollbar( method.frm, orient="vert",
                command=function(...)tkyview(method.listbox, ...))

tkinsert( method.listbox, "end", paste( "Nelder-Mead"))
tkinsert( method.listbox, "end", paste( "BFGS quasi-Newton"))
tkinsert( method.listbox, "end", paste( "Conjugate Gradients"))
tkinsert( method.listbox, "end", paste( "L-BFGS-B"))
tkinsert( method.listbox, "end", paste( "Simulated Annealing (Belisle 1992)"))

tkpack( tklabel( method.frm, text="Method", padx=4), side="left")
tkpack( method.listbox, methodscr, side="left")

# maxit frame

maxit.entry <- tkentry( maxit.frm, textvariable=maxit.value, width=6)
tkpack( tklabel( maxit.frm, text="Max iterations", padx=4), maxit.entry,
		side="left")
tkpack( method.frm, maxit.frm, side="top")

# bottom frame
ok.but <- tkbutton(bot.frm,text="OK",command=submit)  
quit.but <- tkbutton(bot.frm,text="Cancel",command=endprog)
help.but <- tkbutton( bot.frm, text="Help", command=gpdfithelp)

tkpack( ok.but, quit.but, side="left")
tkpack( help.but, side="right")

# place bindings on "OK", "Cancel" and "Help" buttons so that user can hit
# the return key to execute them.
tkbind( ok.but, "<Return>", submit)
tkbind( quit.but, "<Return>", endprog)
tkbind( help.but, "<Return>", gpdfithelp)

tkpack( top.frm, side="top", fill="x")
tkpack( optim.frm, args.frm, side="top", fill="both")
tkpack( sig.frm, gam.frm, side="left")
tkpack( param.frm, side="top", fill="x")
tkpack(bot.frm, side="top", fill="x")

} # end of gpd.gui fcn
