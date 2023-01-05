*--- Goal: Compute correlation 1) between patterns and 2) between patterns and foods.
;

%macro prep(datvar);
%if &datvar=nhs %then %do; %let basecal=1600;%end;
%else %if &datvar=nhs2 %then %do; %let basecal=1800;%end;
%else %if &datvar=hpfs %then %do; %let basecal=2000;%end;

%rmOutlier(datain=&datvar._data, dataout=&datvar._data, 
           vars=cedih cedip cahei camed cdash chpdi cdrs cwcrf ccalor 
                cediho cedipo caheio camedo cwcrfo
                procmv rmeatv ormeatv fishv poulv eggsv butterv margv lowdaiv hidaiv liqv winev beerv teav coffv fruitv frujv
		        cruvegv yelvegv tomav lfvegv leguv othvegv garlicv potv friesv wgrainv rgrainv pizzav snackv nutsv sugbevv lowbevv
		        saldrev crsoupv dessv condv alcoholv yogurtv,
           varsout=cedih cedip cahei camed cdash chpdi cdrs cwcrf ccalor 
                   cediho cedipo caheio camedo cwcrfo
                   procmv rmeatv ormeatv fishv poulv eggsv butterv margv lowdaiv hidaiv liqv winev beerv teav coffv fruitv frujv
		           cruvegv yelvegv tomav lfvegv leguv othvegv garlicv potv friesv wgrainv rgrainv pizzav snackv nutsv sugbevv lowbevv
		           saldrev crsoupv dessv condv alcoholv yogurtv, 
           pctl=0.5 99.5);
run;

%caladj(data=&datvar._data, outdat=&datvar._data, cal=ccalor, basecal=&basecal, logscale=F,
        var=cedih cedip cahei camed cdash chpdi cdrs cwcrf 
            cediho cedipo caheio camedo cwcrfo
            procmv rmeatv ormeatv fishv poulv eggsv butterv margv lowdaiv hidaiv liqv winev beerv teav coffv fruitv frujv
		    cruvegv yelvegv tomav lfvegv leguv othvegv garlicv potv friesv wgrainv rgrainv pizzav snackv nutsv sugbevv lowbevv
		    saldrev crsoupv dessv condv alcoholv yogurtv,
        adjvar=cediha cedipa caheia cameda cdasha chpdia cdrsa cwcrfa 
               cedihoa cedipoa caheioa camedoa cwcrfoa
               procmva rmeatva ormeatva fishva poulva eggsva butterva margva lowdaiva hidaiva liqva wineva beerva teava coffva fruitva frujva
		       cruvegva yelvegva tomava lfvegva leguva othvegva garlicva potva friesva wgrainva rgrainva pizzava snackva nutsva sugbevva lowbevva
		       saldreva crsoupva dessva condva alcoholva yogurtva);

%STD(datain=&datvar._data, dataout=&datvar._data, 
     vars=cediha cedipa caheia cameda cdasha chpdia cdrsa cwcrfa 
          cedihoa cedipoa caheioa camedoa cwcrfoa,
     varsout=cedihaa cedipaa caheiaa camedaa cdashaa chpdiaa cdrsaa cwcrfaa 
             cedihoaa cedipoaa caheioaa camedoaa cwcrfoaa, 
     pctl=10 90);

proc rank data=&datvar._data group=5 out=&datvar._data;
var   ccalor cediha cedipa caheia cameda cdasha chpdia cdrsa cwcrfa 
      cedihoa cedipoa caheioa camedoa cwcrfoa;
ranks ccalorq cedihaq cedipaq caheiaq camedaq cdashaq chpdiaq cdrsaq cwcrfaq 
      cedihoaq cedipoaq caheioaq camedoaq cwcrfoaq;
run;
%mend;

%prep(nhs);
%prep(nhs2);
%prep(hpfs);

data nhs_data;set nhs_data;id=id+1000000;periodnew=period;run;
data nhs2_data;set nhs2_data;id=id+2000000;periodnew=period+3;run;
data hpfs_data;set hpfs_data;id=id+3000000;periodnew=period+1;run;

* create indicators ;
data pooled;
set nhs_data nhs2_data hpfs_data;
* reverse the scores for unhealthy patterns *;
rcedihaa  = - cedihaa;
rcedih = - cedih;
rcediha = - cediha;

rcedipaa = - cedipaa;
rcedip = - cedip;
rcedipa = - cedipa;

rcedihoaa = - cedihoaa;
rcediho = - cediho;
rcedihoa = - cedihoa;

rcedipoaa = - cedipoaa;
rcedipo = - cedipo;
rcedipoa = - cedipoa;
run;

data period1;
set pooled;
if period=1;
run;

proc corr data=pooled(where=(cohort eq 1 and period eq 1)) nomiss spearman outs=nhsadj;
var caheia cameda chpdia cdasha cdrsa cwcrfa rcediha rcedipa 
    caheioa camedoa cwcrfoa rcedihoa rcedipoa;
run;
ods csv file='cor_nhs.csv';
proc print data=nhsadj noobs;
run;

ods csv close;
proc corr data=pooled(where=(cohort eq 2 and period eq 1)) nomiss spearman outs=nhs2adj;
var caheia cameda chpdia cdasha cdrsa cwcrfa rcediha rcedipa 
    caheioa camedoa cwcrfoa rcedihoa rcedipoa;
run;
ods csv file='cor_nhs2.csv';
proc print data=nhs2adj noobs;
run;
ods csv close;

proc corr data=pooled(where=(cohort eq 3 and period eq 1)) nomiss spearman outs=hpfsadj;
var caheia cameda chpdia cdasha cdrsa cwcrfa rcediha rcedipa 
    caheioa camedoa cwcrfoa rcedihoa rcedipoa;
run;
ods csv file='cor_hpfs.csv';
proc print data=hpfsadj noobs;
run;
ods csv close;

* Correlations of dietary patterns *;
proc corr data=pooled(where=(period eq 1)) nomiss spearman outs=pooledp;
var caheia cameda chpdia cdasha cdrsa cwcrfa rcediha rcedipa 
    caheioa camedoa cwcrfoa rcedihoa rcedipoa;
run;
ods csv file='cor_all.csv';
proc print data=pooledp noobs;
run;
ods csv close;

proc corr data=pooled(where=(period eq 1)) nomiss spearman outs=pooledp;
    var caheia cameda chpdia cdasha cdrsa cwcrfa rcediha rcedipa 
        caheioa camedoa cwcrfoa rcedihoa rcedipoa
        procmva rmeatva ormeatva fishva poulva eggsva butterva margva lowdaiva hidaiva liqva wineva beerva teava coffva fruitva frujva
        cruvegva yelvegva tomava lfvegva leguva othvegva garlicva potva friesva wgrainva rgrainva pizzava snackva nutsva sugbevva lowbevva
        saldreva crsoupva dessva condva alcoholva yogurtva
        ;
    run;
ods csv file='corfood_all.csv';
proc print data=pooledp noobs;
run;
ods csv close;