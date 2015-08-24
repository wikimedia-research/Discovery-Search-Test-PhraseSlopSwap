## A function for computing Pearson correlation for IxJ tables & Mantel-Haenszel, M2 pearson correlation for IxJ tables 
# Source: https://onlinecourses.science.psu.edu/stat504/sites/onlinecourses.science.psu.edu.stat504/files/pears.cor_.R
# table = IxJ table or a matrix 
# rscore = vector of row scores 
# cscore = vector of column scores 
pears.cor=function(table, rscore, cscore)
{ 
  dim=dim(table) 
  rbar=sum(margin.table(table,1)*rscore)/sum(table) 
  rdif=rscore-rbar 
  cbar=sum(margin.table(table,2)*cscore)/sum(table) 
  cdif=cscore-cbar 
  ssr=sum(margin.table(table,1)*(rdif^2)) 
  ssc=sum(margin.table(table,2)*(cdif^2)) 
  ssrc=sum(t(table*rdif)*cdif) 
  pcor=ssrc/(sqrt(ssr*ssc)) 
  M2=(sum(table)-1)*pcor^2
  result=c(pcor = pcor, M2 = M2)
  result
} 
