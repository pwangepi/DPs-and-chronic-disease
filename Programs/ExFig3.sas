*--- Goal: Test for nonlinearity.
;

%macro prep(datvar);
%if &datvar=nhs %then %do; %let basecal=1600;%end;
%else %if &datvar=nhs2 %then %do; %let basecal=1800;%end;
%else %if &datvar=hpfs %then %do; %let basecal=2000;%end;

%rmOutlier(datain=&datvar._data, dataout=&datvar._data, 
           vars=cedih cedip cahei camed cdash chpdi cdrs cwcrf ccalor 
                cediho cedipo caheio camedo cwcrfo,
           varsout=cedih cedip cahei camed cdash chpdi cdrs cwcrf ccalor 
                   cediho cedipo caheio camedo cwcrfo, 
           pctl=0.5 99.5);
run;

%caladj(data=&datvar._data, outdat=&datvar._data, cal=ccalor, basecal=&basecal, logscale=F,
        var=cedih cedip cahei camed cdash chpdi cdrs cwcrf 
            cediho cedipo caheio camedo cwcrfo,
        adjvar=cediha cedipa caheia cameda cdasha chpdia cdrsa cwcrfa 
               cedihoa cedipoa caheioa camedoa cwcrfoa);

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

%prep(hpfs);
%prep(nhs);
%prep(nhs2);

data nhs_data;set nhs_data;id=id+1000000;periodnew=period;run;
data nhs2_data;set nhs2_data;id=id+2000000;periodnew=period+3;run;
data hpfs_data;set hpfs_data;id=id+3000000;periodnew=period+1;run;

data pooled;
set nhs_data nhs2_data hpfs_data end=_end_;
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

array quintile {*} ccalorq cedihaq cedipaq caheiaq camedaq cdashaq chpdiaq cdrsaq cwcrfaq
                   cedihoaq cedipoaq caheioaq camedoaq cwcrfoaq;
  do i=1 to dim(quintile);
    quintile{i} = quintile{i} + 1;
    if quintile{i} = . then quintile{i} = 3;
  end;

* reverse the scores for unhealthy patterns *;
array rev {*} cedihaq cedipaq cedihoaq cedipoaq
              cediha cedihaa cedipa cedipaa
              cedihoa cedihoaa cedipoa cedipoaa;
array rrev {*} rcedihaq rcedipaq rcedihoaq rcedipoaq
               rcediha rcedihaa rcedipa rcedipaa
               rcedihoa rcedihoaa rcedipoa rcedipoaa;
  do i=1 to 4;
    if rev{i}=1 then rrev{i}=5;
    if rev{i}=2 then rrev{i}=4;
    if rev{i}=3 then rrev{i}=3;
    if rev{i}=4 then rrev{i}=2;
    if rev{i}=5 then rrev{i}=1;
  end;
  do i=5 to 12;
    rrev{i}=-rev{i};
  end;

%indic3(vbl=ccalorq,     prefix=ccalorq,    min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=rcedihaq,    prefix=rcedihaq,   min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=rcedipaq,    prefix=rcedipaq,   min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=caheiaq,     prefix=caheiaq,    min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=camedaq,     prefix=camedaq,    min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=cdashaq,     prefix=cdashaq,    min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=chpdiaq,     prefix=chpdiaq,    min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=cdrsaq,      prefix=cdrsaq,     min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=cwcrfaq,     prefix=cwcrfaq,    min=2, max=5, reflev=1, missing=., usemiss=0);

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
run;

**** Cox proportional hazard regressions ****;
%macro spline(exp=,title=)/minoperator;
%if &exp in cdasha chpdia cdrsa rcedihoa rcedipoa caheioa camedoa cwcrfoa %then %do; 
  %let cov=&fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &ccalorq_ pmhsex2 pmhsex3 pmhsex4 &alcog_;
%end;
%else %do;
  %let cov=&fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &ccalorq_ pmhsex2 pmhsex3 pmhsex4;
%end;

%lgtphcurv9(
  data=pooled, time=pt_chr, strata=agemo periodnew cohort, model=cox,
  exposure=&exp, case=chrv, adj=&cov,
  plot=2, pictname=spline_&exp..JPEG, outplot=JPEG, 
  FOOTER=NONE, 
  /* Plot parameters */
  select=3, NK=3, lpct=5, hpct=95, DISPLAYX=T, axordv=0 to 1.4 by 0.2, refval=min, 
  hlabel=&title., 
  vlabel=%quote(HR), CI=1,
  header1=&title.,
  /* Test info*/
  testrep=short);
%mend;

%spline(exp=rcediha,title=rEDIH);
%spline(exp=rcedipa,title=rEDIP);
%spline(exp=caheia,title=AHEI-2010);
%spline(exp=cameda,title=AMED);
%spline(exp=cdasha,title=DASH);
%spline(exp=chpdia,title=hPDI);
%spline(exp=cdrsa,title=DRRD);
%spline(exp=cwcrfa,title=WCRF/AICR);
%spline(exp=rcedihoa,title=rEDIH without alcohol);
%spline(exp=rcedipoa,title=rEDIP without alcohol);
%spline(exp=caheioa,title=AHEI-2010 without alcohol);
%spline(exp=camedoa,title=AMED without alcohol);
%spline(exp=cwcrfoa,title=WCRF/AICR without alcohol);
