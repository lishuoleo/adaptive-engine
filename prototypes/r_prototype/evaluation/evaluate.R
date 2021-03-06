##Author: Ilia Rushkin, VPAL Research, Harvard University, Cambridge, MA, USA

#This code is for the purpose of evaluating the predicting power of the algorithm.

if(!exists("training.set")){training.set=users$id}
if(!exists("validation.set")){validation.set=users$id}

LogData.training=subset(LogData,LogData$user_id %in% training.set)
LogData.validation=subset(LogData,LogData$user_id %in% validation.set)
LogData.validation=LogData.validation[order(LogData.validation$time),]
##Overall chance
chance=mean(LogData.training$score,na.rm=TRUE)

##Specific chance for each problem
spec.chance=aggregate(LogData.training$score, by=list(problem_id=LogData.training$problem_id), FUN=mean, na.rm=TRUE)

temp=merge(LogData.validation,spec.chance[,c("problem_id","x")])
temp=temp[order(temp$time),]
x.p.chance=temp$x
x.c=LogData.validation$score
x.p=LogData.validation$predicted
ind=which(!is.na(x.c))
x.c=x.c[ind]
x.p=x.p[ind]
x.p.chance=x.p.chance[ind]
x.p=pmin(pmax(x.p,epsilon),1-epsilon)
x.p.chance=pmin(pmax(x.p.chance,epsilon),1-epsilon)
chance=rep(pmin(pmax(chance,epsilon),1-epsilon),length(x.c))


x.p.r=round(x.p)


# if((!exists("eval.results"))|(!before.optimizing)){
if((!before.optimizing)){
  
  x.c.all=c(x.c.all,x.c)
  x.p.all=c(x.p.all,x.p)
  x.p.chance.all=c(x.p.chance.all,x.p.chance)
  chance.all=c(chance.all,chance)
}

log.like=function(x.c,x.p){
  
if(length(x.p)==1){
  x.p=rep(x.p,length(x.c))
}  
  
all= -(mean(x.c*log(x.p))+mean((1-x.c)*log(1-x.p)))/(2*log(2))

i=which(x.c==1)
correct=-(mean(log(x.p[i])))/(2*log(2))

i=which(x.c==0)
incorrect=-(mean(log(1-x.p[i])))/(2*log(2))
return(list(all=all,incorrect=incorrect,correct=correct))
 # return( -(mean(x.c*log(x.p))+mean((1-x.c)*log(1-x.p)))/(2*log(2)))
  
}
  
  


show.eval=function(eval.results,i=1, rounding=3){
  
  x.c=eval.results[[i]]$x.c
  x.p=eval.results[[i]]$x.p
  x.p.chance=eval.results[[i]]$x.p.chance
  chance=eval.results[[i]]$chance
  x.exposure=eval.results[[i]]$x.exposure
  
  # ind=which(x.exposure>=min.exposure);
  # 
  # x.c=x.c[ind]
  # x.p=x.p[ind]
  # x.p.chance=x.p.chance[ind]
  # chance=chance[ind]
  x.p.r=round(x.p)
  
  cat("Number of observations used:",length(x.p),"\n")
  cat("M =",eval.results[[i]]$M,"eta =",eval.results[[i]]$eta,"\n")
  cat("-LL =",round(log.like(x.c,x.p)$all,rounding),"(overall and problem-specific learned chance would give",round(log.like(x.c,chance)$all,rounding),"and",round(log.like(x.c,x.p.chance)$all,rounding),"respectively)\n")
  cat("-LL correct =",round(log.like(x.c,x.p)$correct,rounding),"(overall and problem-specific learned chance would give",round(log.like(x.c,chance)$correct,rounding),"and",round(log.like(x.c,x.p.chance)$correct,rounding),"respectively)\n")  
    cat("-LL incorrect =",round(log.like(x.c,x.p)$incorrect,rounding),"(overall and problem-specific learned chance would give",round(log.like(x.c,chance)$incorrect,rounding),"and",round(log.like(x.c,x.p.chance)$incorrect,rounding),"respectively)\n")

  cat("MAE =",round(mean(abs(x.c-x.p)),rounding),"(overall and problem-specific learned chance would give",round(mean(abs(x.c-chance)),rounding),"and",round(mean(abs(x.c-x.p.chance)),rounding),"respectively)\n")
  
  cat("RMSE =",round(sqrt(mean((x.c-x.p)^2)),rounding),"(overall and problem-specific learned chance would give",round(sqrt(mean((x.c-chance)^2)),rounding),"and",round(sqrt(mean((x.c-x.p.chance)^2)),rounding),"respectively)\n")
  
  m=matrix(0,nrow=2,ncol=2);
  colnames(m)=c("Incorrect","Correct")
  rownames(m)=c("Predict Incorrect","Predict Correct")
  m["Predict Incorrect","Incorrect"]=length(which((x.p.r==0)&(x.c==0)))
  m["Predict Incorrect","Correct"]=length(which((x.p.r==0)&(x.c==1)))
  m["Predict Correct","Incorrect"]=length(which((x.p.r==1)&(x.c==0)))
  m["Predict Correct","Correct"]=length(which((x.p.r==1)&(x.c==1)))
  
  m=100*m/length(x.c)
  
  print("Confusion matrix:")
  print(round(m,1))
  print(paste("True: ",round(m[1,1]+m[2,2],1)))
  
  x.p.r=round(chance)
  m=matrix(0,nrow=2,ncol=2);
  colnames(m)=c("Incorrect","Correct")
  rownames(m)=c("Predict Incorrect","Predict Correct")
  m["Predict Incorrect","Incorrect"]=length(which((x.p.r==0)&(x.c==0)))
  m["Predict Incorrect","Correct"]=length(which((x.p.r==0)&(x.c==1)))
  m["Predict Correct","Incorrect"]=length(which((x.p.r==1)&(x.c==0)))
  m["Predict Correct","Correct"]=length(which((x.p.r==1)&(x.c==1)))
  
  m=100*m/length(x.c)
  print("Confusion matrix of overall chance:")
  print(round(m,1))
  print(paste("True: ",round(m[1,1]+m[2,2],1)))
  
  x.p.r=round(x.p.chance)
  m=matrix(0,nrow=2,ncol=2);
  colnames(m)=c("Incorrect","Correct")
  rownames(m)=c("Predict Incorrect","Predict Correct")
  m["Predict Incorrect","Incorrect"]=length(which((x.p.r==0)&(x.c==0)))
  m["Predict Incorrect","Correct"]=length(which((x.p.r==0)&(x.c==1)))
  m["Predict Correct","Incorrect"]=length(which((x.p.r==1)&(x.c==0)))
  m["Predict Correct","Correct"]=length(which((x.p.r==1)&(x.c==1)))
  
  m=100*m/length(x.c)
  print("Confusion matrix of specific chance:")
  print(round(m,1))
  print(paste("True: ",round(m[1,1]+m[2,2],1)))
}

