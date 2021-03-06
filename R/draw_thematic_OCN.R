
draw_thematic_OCN <- function(theme,OCN,
                              discreteLevels=FALSE,
                              colLevels=NULL,
                              cutoff=FALSE,
                              colPalette=colorRampPalette(c("yellow","red","black")),
                              exactDraw=FALSE,
                              chooseCM=FALSE,
                              drawNodes=FALSE,
                              cex=2,
                              pch=21,
                              nanColor="#0099FF",
                              riverColor="#0099FF",
                              backgroundColor="#999999",
                              addLegend=TRUE){
  
  # initialization
  
  if (!("RN" %in% names(OCN))){
    stop('Missing fields in OCN. You should run aggregate_OCN prior to draw_thematic_OCN.')
  }
  
  if (discreteLevels == FALSE) {
    if (is.null(colLevels)){
      colLevels <- c(min(theme[!(is.nan(theme))]),max(theme[!(is.nan(theme))]),1000)
    }
    N_colLevels <- colLevels[3]
    minval <- colLevels[1]
    maxval <- colLevels[2]
    if (minval==maxval) {maxval <- minval + 1}
    Breakpoints <- seq(minval,maxval,len = N_colLevels+1)
  } else if (discreteLevels == TRUE) {
    if (is.null(colLevels)){
    N_colLevels <- length(unique(theme[!is.nan(theme)]))
    Breakpoints <- c(sort(unique(theme[!is.nan(theme)])),2*max(theme[!is.nan(theme)]))
  } else {N_colLevels <- length(colLevels) - 1
  Breakpoints <- colLevels}}
  
  if (typeof(colPalette)=="closure") {
    colPalette <- colPalette(N_colLevels)
  } else if (typeof(colPalette)=="character") {
    colPalette <- colPalette[1:N_colLevels] }
  
  tmp <- "TMP"
  if (length(theme)==OCN$RN$nNodes && (length(theme)==OCN$AG$nNodes)){
    while ((tmp != "RN") && (tmp != "AG"))
      tmp <- readline(prompt="theme can be interpreted as a vector both at the RN and AG levels. Choose desired level by typing RN or AG: ")
    if (tmp == "RN"){
      byRN = TRUE
    } else if (tmp == "AG"){
      byRN = FALSE
    } else {
      print('Wrong input!')
    }
  } 
  
  if (length(theme)==OCN$RN$nNodes){
    byRN = TRUE
  } else if (length(theme)==OCN$AG$nNodes){
    byRN = FALSE
  } else {
    stop('theme has invalid length')
  }
  
  if (length(cex)>1 && length(cex) != length(theme)){
    stop('cex has invalid length')
  }
  
  if (length(pch)>1 && length(pch) != length(theme)){
    stop('pch has invalid length')
  }
  
  if (chooseCM==TRUE && is.logical(chooseCM)){
    chooseCM <- which(OCN$CM$A==max(OCN$CM$A))
  } else if (isFALSE(chooseCM)) {
    chooseCM <- 1:OCN$nOutlet
  }
  
  if (exactDraw==TRUE){
    X <- OCN$FD$XDraw#[which( OCN$FD$toCM %in% chooseCM )]
    Y <- OCN$FD$YDraw#[which( OCN$FD$toCM %in% chooseCM )]
    Xc <- OCN$CM$XContourDraw
    Yc <- OCN$CM$YContourDraw
  } else {
    X <- OCN$FD$X#[which( OCN$FD$toCM %in% chooseCM )]
    Y <- OCN$FD$Y#[which( OCN$FD$toCM %in% chooseCM )]
    Xc <- OCN$CM$XContour
    Yc <- OCN$CM$YContour
  }
  
  if (length(cex)==1){
    cex_vec <- cex*rep(1,length(theme))
  } else {cex_vec <- cex}
  
  if (length(pch)==1){
    pch_vec <- pch*rep(1,length(theme))
  } else {pch_vec <- pch}
  
  AvailableNodes <- setdiff(which(OCN$FD$toCM %in% chooseCM),OCN$FD$outlet)
  #old.par <- par(no.readonly = TRUE)
  #on.exit(par(old.par))
  #par(bty="n")
  plot(c(min(X[OCN$FD$toCM %in% chooseCM]),max(X[OCN$FD$toCM %in% chooseCM])),
       c(min(Y[OCN$FD$toCM %in% chooseCM]),max(Y[OCN$FD$toCM %in% chooseCM])),
       type="n",xlab=" ",ylab=" ",axes=FALSE,asp=1)
  
  if (!is.null(backgroundColor)){
    if ((length(chooseCM) > 1) && (length(backgroundColor)==1) ){
      backgroundColor=rep(backgroundColor,length(chooseCM))}
    for (i in chooseCM){
      for (j in 1:length(Xc[[i]])){
        polygon(Xc[[i]][[j]],Yc[[i]][[j]],col=backgroundColor[i],lty=0)
      }}
  }
  
  for (i in AvailableNodes){
    rn <- OCN$FD$toRN[i]
    reach <- OCN$RN$toAGReach[OCN$FD$toRN[i]]
    if (OCN$FD$A[i]>=OCN$thrA & 
        abs(X[i]-X[OCN$FD$downNode[i]]) <= OCN$cellsize & 
        abs(Y[i]-Y[OCN$FD$downNode[i]]) <= OCN$cellsize  ) {
      if ( (byRN==TRUE && (is.nan(theme[rn])==TRUE | is.na(theme[rn])==TRUE)) ||
          (byRN==FALSE && (is.nan(theme[reach])==TRUE | is.na(theme[reach])==TRUE)) ||
          (byRN==TRUE && cutoff==TRUE && (theme[rn] < min(Breakpoints) || theme[rn] > max(Breakpoints))) ||
          (byRN==FALSE && cutoff==TRUE && (theme[reach] < min(Breakpoints) || theme[reach] > max(Breakpoints))) )  {
        hexcolor <- nanColor
      } else {
        if (byRN==TRUE){val <- theme[rn]} else {val <- theme[reach]}
        
        colvalue <- which(Breakpoints > val)[1] - 1  
        if (isTRUE(colvalue==0)) {colvalue <- 1}
        if (is.na(colvalue)) {colvalue <- N_colLevels}
        # if (byRN==TRUE){
        #   
        #   colvalue <- 1+round((N_colLevels-1)*max(0,min(1,(theme[rn]-minval)/(maxval-minval))))
        # } else {colvalue <- 1+round((N_colLevels-1)*max(0,min(1,(theme[reach]-minval)/(maxval-minval))))}
        
        hexcolor <- colPalette[colvalue]
      }
      if (drawNodes==TRUE){
        lines(c(X[i],X[OCN$FD$downNode[i]]),c(Y[i],Y[OCN$FD$downNode[i]]),
              lwd=0.5+4.5*(OCN$FD$A[i]/(OCN$FD$nNodes*OCN$cellsize^2))^0.5,col=riverColor)
      } else {
        lines(c(X[i],X[OCN$FD$downNode[i]]),c(Y[i],Y[OCN$FD$downNode[i]]),
              lwd=0.5+4.5*(OCN$FD$A[i]/(OCN$FD$nNodes*OCN$cellsize^2))^0.5,col=hexcolor)}
    }
  }
  
  if (drawNodes==TRUE && exactDraw==FALSE){
    if (byRN==TRUE){
      nodes <- which(OCN$RN$toCM %in% chooseCM)
    } else {nodes <- which(OCN$AG$toCM %in% chooseCM)}
    for (i in nodes){
      if (is.nan(theme[i]) || (cutoff==TRUE && (theme[i] < min(Breakpoints) || theme[i] > max(Breakpoints)) )){
        hexcolor <- nanColor
      } else {
        colvalue <- which(Breakpoints > theme[i])[1] - 1
        if (isTRUE(colvalue==0)) {colvalue <- 1}
        if (is.na(colvalue)) {colvalue <- N_colLevels}
        #colvalue <- 1+round((N_colLevels-1)*max(0,min(1,(theme[i]-minval)/(maxval-minval))))
        hexcolor <- colPalette[colvalue]
      }
      if (byRN==TRUE){
        points(OCN$RN$X[i],OCN$RN$Y[i],bg=hexcolor,pch=pch_vec[i],cex=cex_vec[i])
      } else {
        points(OCN$AG$X[i],OCN$AG$Y[i],bg=hexcolor,pch=pch_vec[i],cex=cex_vec[i])  
      }
    }
  }
  
  if (drawNodes==TRUE && exactDraw==TRUE){
    if (byRN==TRUE){
      nodes <- which(OCN$RN$toCM %in% chooseCM)
    } else {nodes <- which(OCN$AG$toCM %in% chooseCM)}
    for (i in nodes){
      if (is.nan(theme[i]) || (cutoff==TRUE && (theme[i] < min(Breakpoints) || theme[i] > max(Breakpoints)) )){
        hexcolor <- nanColor
      } else {
        colvalue <- which(Breakpoints > theme[i])[1] - 1  
        if (isTRUE(colvalue==0)) {colvalue <- 1}
        if (is.na(colvalue)) {colvalue <- N_colLevels}
        #colvalue <- 1+round((N_colLevels-1)*max(0,min(1,(theme[i]-minval)/(maxval-minval))))
        hexcolor <- colPalette[colvalue]
      }
      if (byRN==TRUE){
        node <- which(OCN$FD$X==OCN$RN$X[i] & OCN$FD$Y==OCN$RN$Y[i])
        points(X[node],Y[node],bg=hexcolor,pch=pch_vec[i],cex=cex_vec[i])
      } else {
        node <- which(OCN$FD$X==OCN$AG$X[i] & OCN$FD$Y==OCN$AG$Y[i])
        points(X[node],Y[node],bg=hexcolor,pch=pch_vec[i],cex=cex_vec[i])  
      }
    }
  }
  
  
  if (addLegend) {
    if (discreteLevels==FALSE){
      tmp <- par()$plt[2]
      pr <- 1 - tmp
      image.plot(col=colPalette,legend.only=TRUE,zlim=c(minval,maxval),
                 smallplot=c(0.88, 0.9,par()$plt[3],par()$plt[4]))
    } else {
      if (is.null(colLevels)){
        str <- NULL
        for (level in 1:N_colLevels){
          str <- c(str, as.character(round(1000*Breakpoints[level])/1000) )}
      } else { 
        str <- vector(mode="character", N_colLevels)
        for (level in 1:(N_colLevels-1)){
          str[level] <- paste("[",as.character(round(1000*Breakpoints[level])/1000),"; ",
                              as.character(round(1000*Breakpoints[level+1])/1000),")",sep="")
        } 
        str[N_colLevels] <- paste("[",as.character(round(1000*Breakpoints[N_colLevels])/1000),"; ",
                                  as.character(round(1000*Breakpoints[N_colLevels+1])/1000),"]",sep="")
      }
      
      legend(x=1.01*max(X[OCN$FD$toCM %in% chooseCM]),y=max(Y[OCN$FD$toCM %in% chooseCM]),
             str,fill=colPalette,ncol=ceiling(N_colLevels/20), xpd=TRUE, cex=0.8, bty="n")
    }
  }
  invisible()
}