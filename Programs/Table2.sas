*--- Goal: Create Table 2: Age-standardized characteristics at baseline.
;


proc format;
value quintile
      1 = 'Q1'
      2 = 'Q2'
      3 = 'Q3'
      4 = 'Q4'
      5 = 'Q5';
value actgf
      1 = '<3'
      2 = '3-8'
      3 = '9-17'
      4 = '18-26'
      5 = '27-41'
      6 = '>=42';
value bmigf
      1 = '<24.0'
      2 = '24.0-25.9'
      3 = '26.0-27.4'
      4 = '27.5-29.9'
      5 = '>=30.0';
value alcof
      1 = '<5.0'
      2 = '5.0-14.9'
      3 = '>=15.0';
value ciggf
      1 = 'Never'
      2 = 'Former, Quitting >=10 y'
      3 = 'Former, Quitting <10 y'
      4 = 'Current';
value pkyrgf
      1 = '0'
      2 = '1-4'
      3 = '5-14'
      4 = '15-24'
      5 = '>=25';
run;

%macro prep(datvar);
%if &datvar=nhs %then %do; %let basecal=1600;%end;
%else %if &datvar=nhs2 %then %do; %let basecal=1800;%end;
%else %if &datvar=hpfs %then %do; %let basecal=2000;%end;

%rmOutlier(datain=&datvar._data, dataout=&datvar._data, 
           vars=cedih cedip cahei camed cdash chpdi cdrs cwcrf ccalor,
           varsout=cedih cedip cahei camed cdash chpdi cdrs cwcrf ccalor, 
           pctl=0.5 99.5);
run;

%caladj(data=&datvar._data, outdat=&datvar._data, cal=ccalor, basecal=&basecal, logscale=F,
        var=cedih cedip cahei camed cdash chpdi cdrs cwcrf,
        adjvar=cediha cedipa caheia cameda cdasha chpdia cdrsa cwcrfa);

%STD(datain=&datvar._data, dataout=&datvar._data, 
     vars=cediha cedipa caheia cameda cdasha chpdia cdrsa cwcrfa,
     varsout=cedihaa cedipaa caheiaa camedaa cdashaa chpdiaa cdrsaa cwcrfaa, 
     pctl=10 90);

proc rank data=&datvar._data group=5 out=&datvar._data;
var   ccalor cediha cedipa caheia cameda cdasha chpdia cdrsa cwcrfa;
ranks ccalorq cedihaq cedipaq caheiaq camedaq cdashaq chpdiaq cdrsaq cwcrfaq;
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
set nhs_data nhs2_data hpfs_data end=_end_;
array quintile {*} ccalorq cedihaq cedipaq caheiaq camedaq cdashaq chpdiaq cdrsaq cwcrfaq;
  do i=1 to dim(quintile);
    quintile{i} = quintile{i} + 1;
    if quintile{i} = . then quintile{i} = 3;
  end;

heightcm = heightm*100;
* reverse the scores for unhealthy patterns *;
if cedihaq=1 then rcedihaq=5;
else if cedihaq=2 then rcedihaq=4;
else if cedihaq=3 then rcedihaq=3;
else if cedihaq=4 then rcedihaq=2;
else if cedihaq=5 then rcedihaq=1;
rcedihaa  = - cedihaa;
rcediha = - cediha;
rcedih = - cedih;

if cedipaq=1 then rcedipaq=5;
else if cedipaq=2 then rcedipaq=4;
else if cedipaq=3 then rcedipaq=3;
else if cedipaq=4 then rcedipaq=2;
else if cedipaq=5 then rcedipaq=1;
rcedipaa = - cedipaa;
rcedipa = - cedipa;
rcedip = - cedip;

%indic3(vbl=ccalorq,     prefix=ccalorq,    min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=cedihaq,     prefix=cedihaq,    min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=cedipaq,     prefix=cedipaq,    min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=caheiaq,     prefix=caheiaq,    min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=camedaq,     prefix=camedaq,    min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=cdashaq,     prefix=cdashaq,    min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=chpdiaq,     prefix=chpdiaq,    min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=cdrsaq,      prefix=cdrsaq,     min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=cwcrfaq,     prefix=cwcrfaq,     min=2, max=5, reflev=1, missing=., usemiss=0);

%indic3(vbl=rcedihaq,     prefix=rcedihaq,    min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=rcedipaq,     prefix=rcedipaq,    min=2, max=5, reflev=1, missing=., usemiss=0);

%indic3(vbl=race,        prefix=race,       min=0, max=0, reflev=1, usemiss=0);
%indic3(vbl=fmdiab,      prefix=fmdiab,     min=1, max=1, reflev=0, usemiss=0);
%indic3(vbl=cafhx,       prefix=cafhx,      min=1, max=1, reflev=0, usemiss=0);
%indic3(vbl=fmcvd,       prefix=fmcvd,      min=1, max=1, reflev=0, usemiss=0);
%indic3(vbl=actg,        prefix=actg,       min=2, max=6, reflev=1, usemiss=0);
%indic3(vbl=alcog,       prefix=alcog,      min=2, max=3, reflev=1, usemiss=0);
%indic3(vbl=cigg,        prefix=cigg,       min=2, max=4, reflev=1, usemiss=0);
%indic3(vbl=pkyrg,       prefix=pkyrg,      min=2, max=5, reflev=1, usemiss=0);
%indic3(vbl=bmig,        prefix=bmig,       min=2, max=5, reflev=1, usemiss=0);
%indic3(vbl=mvyn,        prefix=mvyn,       min=1, max=1, reflev=0, usemiss=0);
%indic3(vbl=regasp,      prefix=regasp,     min=2, max=2, reflev=1, usemiss=0);
%indic3(vbl=regibui,     prefix=regibui,    min=2, max=2, reflev=1, usemiss=0);

* Code pmh for males;
  if cohort in (1,2) then sex=1;else sex=0; * 1 = women, 0 = men;
  if pmh=. then do;
     pmhsex2=0;
     pmhsex3=0;
     pmhsex4=0;
  end;
  else if pmh^=. then do;
     if pmh=2 then pmhsex2=1;else pmhsex2=0;
     if pmh=3 then pmhsex3=1;else pmhsex3=0;
     if pmh=4 then pmhsex4=1;else pmhsex4=0;
  end;

* for %table1 *;
if regasp = 2 then regaspbin = 1;else regaspbin = 0;
if regibui = 2 then regibuibin = 1;else regibuibin = 0;
if pmh = 4 then pmhcurrent = 1;else pmhcurrent = 0;
if cigg in (3,4,5) then currentsmk = 1;else currentsmk = 0;

label 
  rcedihaq		    = 'rEDIH'
  rcedipaq		    = 'rEDIP'
  caheiaq	        = 'AHEI-2010'
  camedaq		      = 'AMED'
  cdashaq		      = 'DASH'
  chpdiaq		      = 'hPDI'
  cdrsaq          = 'DRS'
  cwcrfaq         = 'WCRF'
  
  age	            = 'Age, year'
  heightcm        = 'Height, cm'
  fmdiab          = 'Family history of diabetes'
  cafhx           = 'Family history of cancer'
  fmcvd           = 'Family history of CVD'
  act             = 'Physical activity, MET-h/week'
  actg            = 'Physical activity'
  alco            = 'Alcohol consumption, g/day'
  alcog           = 'Alcohol consumption, g/day'
  bmi             = 'Body mass index, kg/m2'
  bmig            = 'Body mass index, kg/m2'
  cigg            = 'Cigarette smoking, status'
  pkyrg           = 'Cigarette smoking, packyears'
  regaspbin       = 'Regular aspirin use'
  regibuibin      = 'Regular NSAIDs use'
  mvyn            = 'Multivitamin use'
  ccalor          = 'Total energy intake, kcal/d'
  pmhcurrent      = 'Postmenopausal hormone use'
  currentsmk      = 'Current smoking'
  coffv           = 'Coffee, cup/d'
;
format  rcedihaq quintile. rcedipaq quintile.
		    caheiaq quintile. camedaq quintile. cdashaq quintile. chpdiaq quintile. cdrsaq quintile. cwcrfaq quintile.
        actg actgf. bmig bmigf. alcog alcof. cigg ciggf. pkyrg pkyrgf.;
run;


data period1;
set pooled;
if period=1;
run;

* Revised: add height *;
* EDIH *;
%table1(
data = pooled,
exposure = rcedihaq, dec=1, agegroup = ageg, ageadj = T, noadj=age, 
mdn = rcediha rcedih, landscape = T, multn = T, sep=PAR,
varlist = rcediha rcedih age heightcm cafhx fmdiab fmcvd act bmi alco currentsmk regaspbin regibuibin mvyn pmhcurrent coffv ccalor
          actg bmig alcog cigg pkyrg,
cat     = cafhx fmdiab fmcvd currentsmk regaspbin regibuibin mvyn pmhcurrent,
poly    = actg bmig alcog cigg pkyrg,
file = t1_redihnew,
rtftitle = Age standardized characteristics
);


* EDIP *;
%table1(
data = pooled,
exposure = rcedipaq, dec=1, agegroup = ageg, ageadj = T, noadj=age, 
mdn = rcedipa rcedip, landscape = T, multn = T, sep=PAR,
varlist = rcedipa rcedip age heightcm cafhx fmdiab fmcvd act bmi alco currentsmk regaspbin regibuibin mvyn pmhcurrent coffv ccalor
          actg bmig alcog cigg pkyrg,
cat     = cafhx fmdiab fmcvd currentsmk regaspbin regibuibin mvyn pmhcurrent,
poly    = actg bmig alcog cigg pkyrg,
file = t1_redipnew,
rtftitle = Age standardized characteristics
);

* AHEI2010 *;
%table1(
data = pooled,
exposure = caheiaq, dec=1, agegroup = ageg, ageadj = T, noadj=age, 
mdn = caheia cahei, landscape = T, multn = T, sep=PAR,
varlist = caheia cahei age heightcm cafhx fmdiab fmcvd act bmi alco currentsmk regaspbin regibuibin mvyn pmhcurrent coffv ccalor
          actg bmig alcog cigg pkyrg,
cat     = cafhx fmdiab fmcvd currentsmk regaspbin regibuibin mvyn pmhcurrent,
poly    = actg bmig alcog cigg pkyrg,
file = t1_aheinew,
rtftitle = Age standardized characteristics
);

* AMED *;
%table1(
data = pooled,
exposure = camedaq, dec=1, agegroup = ageg, ageadj = T, noadj=age, 
mdn = cameda camed, landscape = T, multn = T, sep=PAR,
varlist = cameda camed age heightcm cafhx fmdiab fmcvd act bmi alco currentsmk regaspbin regibuibin mvyn pmhcurrent coffv ccalor
          actg bmig alcog cigg pkyrg,
cat     = cafhx fmdiab fmcvd currentsmk regaspbin regibuibin mvyn pmhcurrent,
poly    = actg bmig alcog cigg pkyrg,
file = t1_amednew,
rtftitle = Age standardized characteristics
);

* DASH *;
%table1(
data = pooled,
exposure = cdashaq, dec=1, agegroup = ageg, ageadj = T, noadj=age, 
mdn = cdasha cdash, landscape = T, multn = T, sep=PAR,
varlist = cdasha cdash age heightcm cafhx fmdiab fmcvd act bmi alco currentsmk regaspbin regibuibin mvyn pmhcurrent coffv ccalor
          actg bmig alcog cigg pkyrg,
cat     = cafhx fmdiab fmcvd currentsmk regaspbin regibuibin mvyn pmhcurrent,
poly    = actg bmig alcog cigg pkyrg,
file = t1_dashnew,
rtftitle = Age standardized characteristics
);

* hPDI *;
%table1(
data = pooled,
exposure = chpdiaq, dec=1, agegroup = ageg, ageadj = T, noadj=age, 
mdn = chpdia chpdi, landscape = T, multn = T, sep=PAR,
varlist = chpdia chpdi age heightcm cafhx fmdiab fmcvd act bmi alco currentsmk regaspbin regibuibin mvyn pmhcurrent coffv ccalor
          actg bmig alcog cigg pkyrg,
cat     = cafhx fmdiab fmcvd currentsmk regaspbin regibuibin mvyn pmhcurrent,
poly    = actg bmig alcog cigg pkyrg,
file = t1_hpdinew,
rtftitle = Age standardized characteristics
);

* DRS *;
%table1(
data = pooled,
exposure = cdrsaq, dec=1, agegroup = ageg, ageadj = T, noadj=age, 
mdn = cdrsa cdrs, landscape = T, multn = T, sep=PAR,
varlist = cdrsa cdrs age heightcm cafhx fmdiab fmcvd act bmi alco currentsmk regaspbin regibuibin mvyn pmhcurrent coffv ccalor
          actg bmig alcog cigg pkyrg,
cat     = cafhx fmdiab fmcvd currentsmk regaspbin regibuibin mvyn pmhcurrent,
poly    = actg bmig alcog cigg pkyrg,
file = t1_drsnew,
rtftitle = Age standardized characteristics
);

* WCRF *;
%table1(
data = pooled,
exposure = cwcrfaq, dec=1, agegroup = ageg, ageadj = T, noadj=age, 
mdn = cwcrfa cwcrf, landscape = T, multn = T, sep=PAR,
varlist = cwcrfa cwcrf age heightcm cafhx fmdiab fmcvd act bmi alco currentsmk regaspbin regibuibin mvyn pmhcurrent coffv ccalor
          actg bmig alcog cigg pkyrg,
cat     = cafhx fmdiab fmcvd currentsmk regaspbin regibuibin mvyn pmhcurrent,
poly    = actg bmig alcog cigg pkyrg,
file = t1_wcrfnew,
rtftitle = Age standardized characteristics
);



