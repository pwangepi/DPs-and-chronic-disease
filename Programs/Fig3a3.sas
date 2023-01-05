*--- Goal: Cox regression for major chronic diseases. Subgroup by race.
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
%indic3(vbl=race_new,    prefix=race_new,   min=2, max=5, reflev=1, usemiss=0);
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
  array newg2 {*} race2rcediha race2rcedipa race2caheia race2cameda race2cdasha race2chpdia race2cdrsa race2cwcrfa race2caheioa race2camedoa race2cwcrfoa race2rcedihoa race2rcedipoa;
  array newg3 {*} race3rcediha race3rcedipa race3caheia race3cameda race3cdasha race3chpdia race3cdrsa race3cwcrfa race3caheioa race3camedoa race3cwcrfoa race3rcedihoa race3rcedipoa;
  array newg4 {*} race4rcediha race4rcedipa race4caheia race4cameda race4cdasha race4chpdia race4cdrsa race4cwcrfa race4caheioa race4camedoa race4cwcrfoa race4rcedihoa race4rcedipoa;
  array newg5 {*} race5rcediha race5rcedipa race5caheia race5cameda race5cdasha race5chpdia race5cdrsa race5cwcrfa race5caheioa race5camedoa race5cwcrfoa race5rcedihoa race5rcedipoa;

  do i=1 to dim(orig);
      if race_new=2 then newg2{i}=orig{i};else newg2{i}=0;
      if race_new=3 then newg3{i}=orig{i};else newg3{i}=0;
      if race_new=4 then newg4{i}=orig{i};else newg4{i}=0;
      if race_new=5 then newg5{i}=orig{i};else newg5{i}=0;
  end;
run;


title '----- Subgroup: race -----';
%macro cox(exp=,where=,name=)/minoperator;
%if &exp in cdasha chpdia cdrsa rcedihoa rcedipoa caheioa camedoa cwcrfoa %then %do; 
  %let cov=&fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 &alcog_;
%end;
%else %do;
  %let cov=&fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4;
%end;

%mphreg9(data=pooled, dtdx=dt_chr, event=chrv, dtdth=dtdeath, cutoff=cutoff, tvar=periodnew, outdat=&name.&exp.,
qret=irt84 irt86 irt88 irt90 irt92 irt94 irt96 irt98 irt00 irt02 irt04 irt06 irt08 irt10 irt12 irt14, 
timevar=t84 t86 t88 t90 t92 t94 t96 t98 t00 t02 t04 t06 t08 t10 t12 t14,
id=id, agevar=agemo,strata=cohort agemo periodnew, where=&where,
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

%all_cox(where=race_new eq 1,name=caucasian);
%all_cox(where=race_new eq 2,name=asian);
%all_cox(where=race_new eq 3,name=hispanic);
%all_cox(where=race_new eq 4,name=african);
%all_cox(where=race_new eq 5,name=others);

data result;
set all_caucasian all_asian all_hispanic all_african all_others;
run;

ods csv file='./race_subgrp.csv';
proc print data=result noobs;run;
ods csv close;

title '----- Interaction: Pattern * race (category) -----';
%mphreg9(data=pooled, dtdx=dt_chr, event=chrv, dtdth=dtdeath, cutoff=cutoff, tvar=periodnew, outdat=race_cat,
qret=irt84 irt86 irt88 irt90 irt92 irt94 irt96 irt98 irt00 irt02 irt04 irt06 irt08 irt10 irt12 irt14, 
timevar=t84 t86 t88 t90 t92 t94 t96 t98 t00 t02 t04 t06 t08 t10 t12 t14,
id=id, agevar=agemo,strata=agemo periodnew cohort, 
model1=caheiaa  &race_new_  &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4,
model2=caheiaa  &race_new_  race2caheia race3caheia race4caheia race5caheia &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4,
model3=camedaa  &race_new_  &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4,
model4=camedaa  &race_new_  race2cameda race3cameda race4cameda race5cameda &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4,
model5=chpdiaa  &race_new_  &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 &alcog_,
model6=chpdiaa  &race_new_  race2chpdia race3chpdia race4chpdia race5chpdia &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 &alcog_,
model7=cdashaa  &race_new_  &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 &alcog_, 
model8=cdashaa  &race_new_  race2cdasha race3cdasha race4cdasha race5cdasha &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 &alcog_, 
model9=cdrsaa   &race_new_  &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 &alcog_,
model10=cdrsaa  &race_new_  race2cdrsa  race3cdrsa race4cdrsa race5cdrsa &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 &alcog_,
model11=cwcrfaa &race_new_  &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4,
model12=cwcrfaa &race_new_  race2cwcrfa race3cwcrfa race4cwcrfa race5cwcrfa &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4,
model13=rcedihaa &race_new_ &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4,
model14=rcedihaa &race_new_ race2rcediha race3rcediha race4rcediha race5rcediha &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4,
model15=rcedipaa &race_new_ &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4,
model16=rcedipaa &race_new_ race2rcedipa race3rcedipa race4rcedipa race5rcedipa &fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4
);


title '---------- case no. & person-yr ----------';
proc freq data=pooled;
tables race*chrv
       race_new*chrv
       ethnic*chrv/norow nocol nopercent missing;
run;

%pre_pm(data=pooled, out=pooled_py, 
        irt=irt84 irt86 irt88 irt90 irt92 irt94 irt96 irt98 irt00 irt02 irt04 irt06 irt08 irt10 irt12 irt14,
        timevar=periodnew, cutoff=cutoff, 
        dtdx=dt_chr, dtdth=dtdeath,case=chrv, 
        var=race_new);
%pm(data=pooled_py, case=chrv, 
    exposure=race_new);
