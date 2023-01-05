*--- Goal: Cox regression for major chronic diseases. Subgroup by alcohol.
;

%macro prep(datvar,basecal);
%rmOutlier(datain=&datvar._data, dataout=&datvar._data, 
           vars=cedih cedip cahei camed cdash chpdi cdrs cwcrf ccalor 
                cediho cedipo caheio camedo cwcrfo ses,
           varsout=cedih cedip cahei camed cdash chpdi cdrs cwcrf ccalor 
                   cediho cedipo caheio camedo cwcrfo ses, 
           pctl=0.5 99.5);
run;

%caladj(data=&datvar._data, outdat=&datvar._data, cal=ccalor, basecal=&basecal, logscale=F,
        var=cedih cedip cahei camed cdash chpdi cdrs cwcrf 
            cediho cedipo caheio camedo cwcrfo,
        adjvar=cediha cedipa caheia cameda cdasha chpdia cdrsa cwcrfa 
               cedihoa cedipoa caheioa camedoa cwcrfoa);

%STD(datain=&datvar._data, dataout=&datvar._data, 
     vars=cediha cedipa caheia cameda cdasha chpdia cdrsa cwcrfa 
          cedihoa cedipoa caheioa camedoa cwcrfoa ses,
     varsout=cedihaa cedipaa caheiaa camedaa cdashaa chpdiaa cdrsaa cwcrfaa 
             cedihoaa cedipoaa caheioaa camedoaa cwcrfoaa sesa, 
     pctl=10 90);

proc rank data=&datvar._data group=5 out=&datvar._data;
var   ccalor cediha cedipa caheia cameda cdasha chpdia cdrsa cwcrfa 
      cedihoa cedipoa caheioa camedoa cwcrfoa ses;
ranks qccalor qcediha qcedipa qcaheia qcameda qcdasha qchpdia qcdrsa qcwcrfa 
      qcedihoa qcedipoa qcaheioa qcamedoa qcwcrfoa qses;
run;

data &datvar._data;
set &datvar._data;
array quintile {*} qccalor qcediha qcedipa qcaheia qcameda qcdasha qchpdia qcdrsa qcwcrfa 
                   qcedihoa qcedipoa qcaheioa qcamedoa qcwcrfoa qses;
  do i=1 to dim(quintile);
    quintile{i} = quintile{i} + 1;
    if quintile{i} = . then quintile{i} = 3;
  end;
* reverse the scores for unhealthy patterns *;
array rev {*} qcediha qcedipa qcedihoa qcedipoa
              cediha cedihaa cedipa cedipaa
              cedihoa cedihoaa cedipoa cedipoaa;
array rrev {*} qrcediha qrcedipa qrcedihoa qrcedipoa
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
run;

%get_med_many(data = &datvar._data,
 contvar   = rcediha rcedipa caheia cameda cdasha chpdia cdrsa cwcrfa 
             rcedihoa rcedipoa caheioa camedoa cwcrfoa,
 quintvar  = qrcediha qrcedipa qcaheia qcameda qcdasha qchpdia qcdrsa qcwcrfa 
             qrcedihoa qrcedipoa qcaheioa qcamedoa qcwcrfoa,
 quintcont = medqrcediha medqrcedipa medqcaheia medqcameda medqcdasha medqchpdia medqcdrsa medqcwcrfa 
             medqrcedihoa medqrcedipoa medqcaheioa medqcamedoa medqcwcrfoa);
run;
%mend;

%prep(datvar=nhs,basecal=1600);
%prep(datvar=nhs2,basecal=1800);
%prep(datvar=hpfs,basecal=2000);

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

%indic3(vbl=qccalor,     prefix=qccalor,    min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=qrcediha,    prefix=qrcediha,   min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=qrcedipa,    prefix=qrcedipa,   min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=qcaheia,     prefix=qcaheia,    min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=qcameda,     prefix=qcameda,    min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=qcdasha,     prefix=qcdasha,    min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=qchpdia,     prefix=qchpdia,    min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=qcdrsa,      prefix=qcdrsa,     min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=qcwcrfa,     prefix=qcwcrfa,    min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=qrcedihoa,   prefix=qrcedihoa,   min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=qrcedipoa,   prefix=qrcedipoa,   min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=qcaheioa,    prefix=qcaheioa,    min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=qcamedoa,    prefix=qcamedoa,    min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=qcwcrfoa,    prefix=qcwcrfoa,    min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=qses,        prefix=qses,        min=2, max=5, reflev=1, missing=., usemiss=0);

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

  array orig {*} rcedihaa rcedipaa caheiaa camedaa cdashaa chpdiaa cdrsaa cwcrfaa caheioaa camedoaa cwcrfoaa rcedihoaa rcedipoaa;
  array newgg {*} alcorcediha alcorcedipa alcocaheia alcocameda alcocdasha alcochpdia alcocdrsa alcocwcrfa alcocaheioa alcocamedoa alcocwcrfoa alcorcedihoa alcorcedipoa;

  do i=1 to dim(orig);
      if alco<=14 then newgg{i}=orig{i};
      else if alco>14 then newgg{i}=0;
  end;

  if alco<=14 then lowalco=1;
  else lowalco=0;
run;


title '----- Interaction: Pattern * Alcohol (binary) -----';
%mphreg9(data=pooled, dtdx=dt_chr, event=chrv, dtdth=dtdeath, cutoff=cutoff, tvar=periodnew, outdat=outdata1,
qret=irt84 irt86 irt88 irt90 irt92 irt94 irt96 irt98 irt00 irt02 irt04 irt06 irt08 irt10 irt12 irt14, 
timevar=t84 t86 t88 t90 t92 t94 t96 t98 t00 t02 t04 t06 t08 t10 t12 t14,
id=id, agevar=agemo,strata=agemo periodnew cohort, 
model1=caheiaa    alcocaheia   &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 lowalco,
model2=camedaa    alcocameda   &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 lowalco,
model3=chpdiaa    alcochpdia   &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 lowalco,
model4=cdashaa    alcocdasha   &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 lowalco, 
model5=cdrsaa     alcocdrsa    &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 lowalco,
model6=cwcrfaa    alcocwcrfa   &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 lowalco,
model7=rcedihaa   alcorcediha  &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 lowalco,
model8=rcedipaa   alcorcedipa  &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 lowalco,
model9=caheioaa   alcocaheioa  &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 lowalco,
model10=camedoaa  alcocamedoa  &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 lowalco, 
model11=cwcrfoaa  alcocwcrfoa  &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 lowalco,
model12=rcedihoaa alcorcedihoa &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 lowalco, 
model13=rcedipoaa alcorcedipoa &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 lowalco
);
data outdata1;
set outdata1;
if index(variable,'alco');
HR=put(HazardRatio,4.2)|| ' (' ||put(lcl,4.2)|| ', ' ||put(ucl,4.2)|| ')';
if ProbChiSq<.0001 then p='<0.0001';
else if ProbChiSq<.001 then p=round(ProbChiSq,0.0001);
else if 0.001<=ProbChiSq<0.01 then p=round(ProbChiSq,0.001);
else if 0.01<=ProbChiSq<1 then p=round(ProbChiSq,0.01);
keep modelno variable Estimate stderr HazardRatio lcl ucl ProbChiSq HR p;
run;

ods csv file='./alco_Waldpvalues.csv';
proc print data=outdata1 noobs;run;
ods csv close;

title '----- Mediation: Alcohol (continuous) -----';
%mphreg9(data=pooled, dtdx=dt_chr, event=chrv, dtdth=dtdeath, cutoff=cutoff, tvar=periodnew, outdat=outdata2,
qret=irt84 irt86 irt88 irt90 irt92 irt94 irt96 irt98 irt00 irt02 irt04 irt06 irt08 irt10 irt12 irt14, 
timevar=t84 t86 t88 t90 t92 t94 t96 t98 t00 t02 t04 t06 t08 t10 t12 t14,
id=id, agevar=agemo,strata=agemo periodnew cohort, 
model1=caheiaa    alco   &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4,
model2=camedaa    alco   &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4,
model3=chpdiaa    alco   &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4,
model4=cdashaa    alco   &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4, 
model5=cdrsaa     alco   &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4,
model6=cwcrfaa    alco   &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4,
model7=rcedihaa   alco   &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4,
model8=rcedipaa   alco   &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4,
model9=caheioaa   alco   &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4,
model10=camedoaa  alco   &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4, 
model11=cwcrfoaa  alco   &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4,
model12=rcedihoaa alco   &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4, 
model13=rcedipoaa alco   &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4);
data outdata2;
set outdata2;
if index(variable,'edih') | index(variable,'edip') |
   index(variable,'ahei') | index(variable,'amed') | index(variable,'dash') | 
   index(variable,'hpdi') | index(variable,'drs') | index(variable,'wcrf') | 
   index(variable,'alco');
HR=put(HazardRatio,4.2)|| ' (' ||put(lcl,4.2)|| ', ' ||put(ucl,4.2)|| ')';
if ProbChiSq<.0001 then p='<0.0001';
else if ProbChiSq<.001 then p=round(ProbChiSq,0.0001);
else if 0.001<=ProbChiSq<0.01 then p=round(ProbChiSq,0.001);
else if 0.01<=ProbChiSq<1 then p=round(ProbChiSq,0.01);
keep modelno variable Estimate stderr HazardRatio lcl ucl ProbChiSq HR p;
run;

ods csv file='./alco_est.csv';
proc print data=outdata2 noobs;run;
ods csv close;

title '----- Subgroup: Alcohol -----';
%macro cox(exp=,where=,name=)/minoperator;
%if &exp in cdasha chpdia cdrsa rcedihoa rcedipoa caheioa camedoa cwcrfoa  %then %do; 
  %let cov=&fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 alco;
%end;
%else %do;
  %let cov=&fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4;
%end;

%mphreg9(data=pooled, dtdx=dt_chr, event=chrv, dtdth=dtdeath, cutoff=cutoff, tvar=periodnew, outdat=&name.&exp.,
qret=irt84 irt86 irt88 irt90 irt92 irt94 irt96 irt98 irt00 irt02 irt04 irt06 irt08 irt10 irt12 irt14, 
timevar=t84 t86 t88 t90 t92 t94 t96 t98 t00 t02 t04 t06 t08 t10 t12 t14,
id=id, agevar=agemo,strata=agemo periodnew cohort, where=&where,
model1=&exp.a, 
model2=&exp.a sesa,
model3=&exp.a &qses_, 
model4=&exp.a &cov,
model5=&exp.a &cov sesa,
model6=&exp.a &cov &qses_);
run;

data &name.&exp.;
set &name.&exp.;
if index(variable,'edih') | index(variable,'edip') | index(variable,'ses') |
   index(variable,'ahei') | index(variable,'amed') | index(variable,'dash') | 
   index(variable,'hpdi') | index(variable,'drs') | index(variable,'wcrf');
HR=put(HazardRatio,4.2)|| ' (' ||put(lcl,4.2)|| ', ' ||put(ucl,4.2)|| ')';
if ProbChiSq<.0001 then p='<0.0001';
else if ProbChiSq<.001 then p=round(ProbChiSq,0.0001);
else if 0.001<=ProbChiSq<0.01 then p=round(ProbChiSq,0.001);
else if 0.01<=ProbChiSq<1 then p=round(ProbChiSq,0.01);
keep modelno variable Estimate stderr HazardRatio lcl ucl ProbChiSq HR p;
run;
%mend;

%macro all_cox(where=,name=);
%cox(exp=rcediha,where=&where,name=&name);
%cox(exp=rcedipa,where=&where,name=&name);
%cox(exp=caheia,where=&where,name=&name);
%cox(exp=cameda,where=&where,name=&name);
%cox(exp=cdasha,where=&where,name=&name);
%cox(exp=chpdia,where=&where,name=&name);
%cox(exp=cdrsa,where=&where,name=&name);
%cox(exp=cwcrfa,where=&where,name=&name);

%cox(exp=caheioa,where=&where,name=&name);
%cox(exp=camedoa,where=&where,name=&name);
%cox(exp=cwcrfoa,where=&where,name=&name);
%cox(exp=rcedihoa,where=&where,name=&name);
%cox(exp=rcedipoa,where=&where,name=&name);

data all_&name;
length subgroup $20.;
set &name.caheia &name.cameda &name.chpdia &name.cdasha
    &name.cdrsa &name.cwcrfa &name.rcediha &name.rcedipa
    &name.caheioa &name.camedoa &name.cwcrfoa &name.rcedihoa &name.rcedipoa;
subgroup="&name.";
run;
%mend;

%all_cox(where=alco le 14,name=lowalco);
%all_cox(where=alco gt 14,name=highalco);

data result;
set all_lowalco all_highalco;
run;

ods csv file='./alco_subgrp.csv';
proc print data=result noobs;run;
ods csv close;

title '---------- case no. & person-yr ----------';
proc freq data=pooled;
tables lowalco*chrv/norow nocol nopercent missing;
run;

%pre_pm(data=pooled, out=pooled_py, 
        irt=irt84 irt86 irt88 irt90 irt92 irt94 irt96 irt98 irt00 irt02 irt04 irt06 irt08 irt10 irt12 irt14,
        timevar=periodnew, cutoff=cutoff, 
        dtdx=dt_chr, dtdth=dtdeath,case=chrv, 
        var=lowalco);
%pm(data=pooled_py, case=chrv, 
    exposure=lowalco);
