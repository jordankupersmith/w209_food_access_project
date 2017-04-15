setwd('/media/storage/Documents/school/berkeley/w209/project')
setwd('E:/Documents/school/berkeley/w209/project')
getwd()
library(plyr)
library(dplyr)
library(car)

MyData <- read.csv(file="merged_data.csv", header=TRUE, sep=",")
names(MyData)[names(MyData)=="uninsured._rate"] <- "uninsured_rate"
#colnames_data<-colnames(MyData)
#write.csv(colnames_data, "colnames.csv")

varlist<-c("uninsured_rate","Urban","CensusTract","State","County","hs_grad_or_less","did_not_graduate_hs","percent_with_ssi","percent_with_pub_assist","received_snap","PovertyRate","MedianFamilyIncome","EP_POV","EP_UNEMP","EP_PCI","EP_NOHSDP","EP_AGE65","EP_AGE17","EP_DISABL","EP_SNGPNT","EP_MINRTY","EP_LIMENG","EP_MUNIT","EP_MOBILE","EP_CROWD","EP_NOVEH","EP_GROUPQ","SPL_THEME1","RPL_THEME1","LA1and10","LAhalfand10","LA1and20","LATracts_half","LATracts1","LATracts10","LATracts20","LAPOP1_10")
varlist_for_scale<-c("uninsured_rate","hs_grad_or_less","did_not_graduate_hs","percent_with_ssi","percent_with_pub_assist","received_snap","PovertyRate","MedianFamilyIncome","EP_POV","EP_UNEMP","EP_PCI","EP_NOHSDP","EP_AGE65","EP_AGE17","EP_DISABL","EP_SNGPNT","EP_MINRTY","EP_LIMENG","EP_MUNIT","EP_MOBILE","EP_CROWD","EP_NOVEH","EP_GROUPQ","SPL_THEME1","RPL_THEME1")
newdata <- MyData[varlist]


newdata$hs_grad_or_less <- as.numeric(as.character(newdata$hs_grad_or_less))
newdata$did_not_graduate_hs <- as.numeric(as.character(newdata$did_not_graduate_hs))
newdata$percent_with_ssi <- as.numeric(as.character(newdata$percent_with_ssi)) 
newdata$percent_with_pub_assist <- as.numeric(as.character(newdata$percent_with_pub_assist)) 
newdata$received_snap <- as.numeric(as.character(newdata$received_snap))
newdata$uninsured_rate <- as.numeric(as.character(newdata$uninsured_rate))

dataForScale<-newdata[,varlist_for_scale]

####This scales the variables
variables_scaled <- dataForScale %>% mutate_each_(funs(scale(.) %>% as.vector), 
                                             vars=varlist_for_scale)

names(variables_scaled ) <- paste0("scaled.", names(variables_scaled ))

finalDataPreLookUp<-cbind(variables_scaled, newdata)

lookup <- read.csv(file="census_tract_lookup.csv", header=TRUE, sep=",", colClasses=c("CensusTractString"="character", "stateCodeString"="character","countyCodeString"="character","censusTractLeadingZero"="character"))

postlookup <- merge(lookup,finalDataPreLookUp,by="CensusTract")

#1=0-.5 miles
#2=> 0.5 miles
#3=10-20 miles
#4 >20 miles


makegroup<-sqldf("select 
                 case
                 when LATracts_half=1 and LATracts1=0  then 1
                 when LATracts_half=1 and LATracts1=1  then 2
                 when LATracts10=1 and LATracts20=0  then 3
                 when LATracts10=1 and LATracts20=1  then 4
                 else 5
                 end groupingvar
                 from postlookup")

DataGrouping<-cbind(postlookup, makegroup)


columnnumber<- sqldf("select 
                     case when groupingvar=1 OR groupingvar=3 then 1
                     when groupingvar=2 OR groupingvar=4 then 2
                     else 3
                     end columnnumber
                     from DataGrouping"
)


finalData<-cbind(DataGrouping, columnnumber)

finalData$rownumber<-recode(finalData$Urban,"0=2")



write.csv(finalData, "final_data.csv", row.names = FALSE, na="")







#write.csv(test, "logic_test.csv", row.names = FALSE, na="")
