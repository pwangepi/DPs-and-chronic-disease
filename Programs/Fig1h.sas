*--- Goal: Cox regression for total cancer.

;

%macro prep(datvar,basecal);
%rmOutlier(datain=&datvar._data, dataout=&datvar._data, 
           vars=cedih cedip cahei camed cdash chpdi cdrs cwcrf ccalor 
                cediho cedipo caheio camedo cwcrfo ses
                cedihc cedipc cdrsc,
           varsout=cedih cedip cahei camed cdash chpdi cdrs cwcrf ccalor 
                   cediho cedipo caheio camedo cwcrfo ses
                   cedihc cedipc cdrsc, 
           pctl=0.5 99.5);
run;

%caladj(data=&datvar._data, outdat=&datvar._data, cal=ccalor, basecal=&basecal, logscale=F,
        var=cedih cedip cahei camed cdash chpdi cdrs cwcrf 
            cediho cedipo caheio camedo cwcrfo
            cedihc cedipc cdrsc,
        adjvar=cediha cedipa caheia cameda cdasha chpdia cdrsa cwcrfa 
               cedihoa cedipoa caheioa camedoa cwcrfoa
               cedihca cedipca cdrsca);

%STD(datain=&datvar._data, dataout=&datvar._data, 
     vars=cediha cedipa caheia cameda cdasha chpdia cdrsa cwcrfa 
          cedihoa cedipoa caheioa camedoa cwcrfoa ses
          cedihca cedipca cdrsca,
     varsout=cedihaa cedipaa caheiaa camedaa cdashaa chpdiaa cdrsaa cwcrfaa 
             cedihoaa cedipoaa caheioaa camedoaa cwcrfoaa sesa
             cedihcaa cedipcaa cdrscaa, 
     pctl=10 90);

proc rank data=&datvar._data group=5 out=&datvar._data;
var   ccalor cediha cedipa caheia cameda cdasha chpdia cdrsa cwcrfa 
      cedihoa cedipoa caheioa camedoa cwcrfoa ses
      cedihca cedipca cdrsca;
ranks qccalor qcediha qcedipa qcaheia qcameda qcdasha qchpdia qcdrsa qcwcrfa 
      qcedihoa qcedipoa qcaheioa qcamedoa qcwcrfoa qses
      qcedihca qcedipca qcdrsca;
run;

data &datvar._data;
set &datvar._data;
array quintile {*} qccalor qcediha qcedipa qcaheia qcameda qcdasha qchpdia qcdrsa qcwcrfa 
                   qcedihoa qcedipoa qcaheioa qcamedoa qcwcrfoa qses
                   qcedihca qcedipca qcdrsca;
  do i=1 to dim(quintile);
    quintile{i} = quintile{i} + 1;
    if quintile{i} = . then quintile{i} = 3;
  end;
* reverse the scores for unhealthy patterns *;
array rev {*} qcediha qcedipa qcedihoa qcedipoa qcedihca qcedipca
              cediha cedihaa cedipa cedipaa
              cedihoa cedihoaa cedipoa cedipoaa
              cedihca cedipca cedihcaa cedipcaa
              ;
array rrev {*} qrcediha qrcedipa qrcedihoa qrcedipoa qrcedihca qrcedipca
               rcediha rcedihaa rcedipa rcedipaa
               rcedihoa rcedihoaa rcedipoa rcedipoaa
               rcedihca rcedipca rcedihcaa rcedipcaa;
  do i=1 to 6;
    if rev{i}=1 then rrev{i}=5;
    if rev{i}=2 then rrev{i}=4;
    if rev{i}=3 then rrev{i}=3;
    if rev{i}=4 then rrev{i}=2;
    if rev{i}=5 then rrev{i}=1;
  end;
  do i=7 to 18;
    rrev{i}=-rev{i};
  end;
run;

%get_med_many(data = &datvar._data,
 contvar   = rcediha rcedipa caheia cameda cdasha chpdia cdrsa cwcrfa 
             rcedihoa rcedipoa caheioa camedoa cwcrfoa
             rcedihca rcedipca cdrsca,
 quintvar  = qrcediha qrcedipa qcaheia qcameda qcdasha qchpdia qcdrsa qcwcrfa 
             qrcedihoa qrcedipoa qcaheioa qcamedoa qcwcrfoa
             qrcedihca qrcedipca qcdrsca,
 quintcont = medqrcediha medqrcedipa medqcaheia medqcameda medqcdasha medqchpdia medqcdrsa medqcwcrfa 
             medqrcedihoa medqrcedipoa medqcaheioa medqcamedoa medqcwcrfoa
             medqrcedihca medqrcedipca medqcdrsca);
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
%indic3(vbl=qrcedihca,   prefix=qrcedihca,   min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=qrcedipca,   prefix=qrcedipca,   min=2, max=5, reflev=1, missing=., usemiss=0);
%indic3(vbl=qcdrsca,      prefix=qcdrsca,     min=2, max=5, reflev=1, missing=., usemiss=0);

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

  array orig {*}  rcedihaa rcedipaa caheiaa camedaa cdashaa chpdiaa cdrsaa cwcrfaa caheioaa camedoaa cwcrfoaa rcedihoaa rcedipoaa;
  array newgg {*} agercediha agercedipa agecaheia agecameda agecdasha agechpdia agecdrsa agecwcrfa agecaheioa agecamedoa agecwcrfoa agercedihoa agercedipoa;

  do i=1 to dim(orig);
      newgg{i}=orig{i}*(age-40)/10;
  end;
  
run;


**** Cox proportional hazard regressions ****;
title '---------- Pooled: main analysis ----------';
%macro cox(exp=)/minoperator;
%if &exp in cdasha chpdia cdrsa rcedihoa rcedipoa caheioa camedoa cwcrfoa cdrsca %then %do; 
  %let cov=&cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 &alcog_ heightm;
%end;
%else %do;
  %let cov=&cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 heightm;
%end;

%mphreg9(data=pooled, dtdx=dt_totcancer, event=tot_cancerv, dtdth=dtdeath, cutoff=cutoff, tvar=periodnew, outdat=est_&exp.,
qret=irt84 irt86 irt88 irt90 irt92 irt94 irt96 irt98 irt00 irt02 irt04 irt06 irt08 irt10 irt12 irt14, 
timevar=t84 t86 t88 t90 t92 t94 t96 t98 t00 t02 t04 t06 t08 t10 t12 t14,
id=id, agevar=agemo,strata=agemo periodnew cohort, 
model1=&exp.a, 
model2=&exp.a sesa,
model3=&exp.a &qses_, 
model4=&exp.a &cov,
model5=&exp.a &cov sesa,
model6=&exp.a &cov &qses_,
model7=q&exp.2 q&exp.3 q&exp.4 q&exp.5,
model8=q&exp.2 q&exp.3 q&exp.4 q&exp.5 sesa,
model9=q&exp.2 q&exp.3 q&exp.4 q&exp.5 &qses_,
model10=q&exp.2 q&exp.3 q&exp.4 q&exp.5 &cov,
model11=q&exp.2 q&exp.3 q&exp.4 q&exp.5 &cov sesa,
model12=q&exp.2 q&exp.3 q&exp.4 q&exp.5 &cov &qses_,
model13=medq&exp.,
model14=medq&exp. sesa,
model15=medq&exp. &qses_,
model16=medq&exp. &cov,
model17=medq&exp. &cov sesa,
model18=medq&exp. &cov &qses_);
run;
data est_&exp.;
set est_&exp.;
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

%cox(exp=caheia);
%cox(exp=cameda);
%cox(exp=chpdia);
%cox(exp=cdasha);
%cox(exp=cdrsa);
%cox(exp=cwcrfa);
%cox(exp=rcediha);
%cox(exp=rcedipa);

%cox(exp=caheioa);
%cox(exp=camedoa);
%cox(exp=cwcrfoa);
%cox(exp=rcedihoa);
%cox(exp=rcedipoa);

%cox(exp=cdrsca);
%cox(exp=rcedihca);
%cox(exp=rcedipca);

data all;
set est_caheia est_cameda est_chpdia est_cdasha
    est_cdrsa est_cwcrfa est_rcediha est_rcedipa
    est_caheioa est_camedoa est_cwcrfoa est_rcedihoa est_rcedipoa
	est_cdrsca est_rcedihca est_rcedipca;
run;

ods csv file='./est_totcanew.csv';
proc print data=all noobs;run;
ods csv close;

title '----- PH assumption -----';
    %mphreg9(data=pooled, dtdx=dt_totcancer, event=tot_cancerv, dtdth=dtdeath, cutoff=cutoff, tvar=periodnew, outdat=pooled_ph1,
    qret=irt84 irt86 irt88 irt90 irt92 irt94 irt96 irt98 irt00 irt02 irt04 irt06 irt08 irt10 irt12 irt14, 
    timevar=t84 t86 t88 t90 t92 t94 t96 t98 t00 t02 t04 t06 t08 t10 t12 t14,
    id=id, agevar=agemo,strata=agemo periodnew cohort, 
    model1=caheiaa  	agecaheia  	&cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 heightm,
    model2=camedaa  	agecameda  	&cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 heightm,
    model3=chpdiaa  	agechpdia  	&cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 &alcog_ heightm,
    model4=cdashaa  	agecdasha  	&cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 &alcog_ heightm, 
    model5=cdrsaa   	agecdrsa   	&cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 &alcog_ heightm,
    model6=cwcrfaa  	agecwcrfa  	&cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 heightm,
	model7=rcedihaa 	agercediha 	&cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 heightm,
    model8=rcedipaa 	agercedipa 	&cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 heightm,
	model9=caheioaa  	agecaheioa  &cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 &alcog_ heightm,
    model10=camedoaa 	agecamedoa  &cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 &alcog_ heightm, 
    model11=cwcrfoaa   	agecwcrfoa  &cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 &alcog_ heightm,
	model12=rcedihoaa  	agercedihoa &cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 &alcog_ heightm, 
    model13=rcedipoaa   agercedipoa &cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 &alcog_ heightm);
data pooled_ph1;
set pooled_ph1;
if index(variable,'age');
HR=put(HazardRatio,4.2)|| ' (' ||put(lcl,4.2)|| ', ' ||put(ucl,4.2)|| ')';
if ProbChiSq<.0001 then p='<0.0001';
else if ProbChiSq<.001 then p=round(ProbChiSq,0.0001);
else if 0.001<=ProbChiSq<0.01 then p=round(ProbChiSq,0.001);
else if 0.01<=ProbChiSq<1 then p=round(ProbChiSq,0.01);
keep variable HazardRatio lcl ucl ProbChiSq HR p;
run;

ods csv file='./ph_totcanew.csv';
proc print data=pooled_ph1 noobs;run;
ods csv close;

title '----- BMI, coffee -----';
    %mphreg9(data=pooled, dtdx=dt_totcancer, event=tot_cancerv, dtdth=dtdeath, cutoff=cutoff, tvar=periodnew, outdat=sens,
    qret=irt84 irt86 irt88 irt90 irt92 irt94 irt96 irt98 irt00 irt02 irt04 irt06 irt08 irt10 irt12 irt14, 
    timevar=t84 t86 t88 t90 t92 t94 t96 t98 t00 t02 t04 t06 t08 t10 t12 t14,
    id=id, agevar=agemo,strata=agemo periodnew cohort, 
    model1=caheiaa  	bmi  	&cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 heightm,
    model2=camedaa  	bmi  	&cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 heightm,
    model3=chpdiaa  	bmi  	&cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 &alcog_ heightm,
    model4=cdashaa  	bmi  	&cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 &alcog_ heightm, 
    model5=cdrsaa   	bmi   	&cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 &alcog_ heightm,
    model6=cwcrfaa  	bmi  	&cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 heightm,
	model7=rcedihaa 	bmi 	&cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 heightm,
    model8=rcedipaa 	bmi 	&cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 heightm,
	model9=caheiaa  	coffv  	&cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 heightm,
    model10=camedaa  	coffv  	&cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 heightm,
    model11=chpdiaa  	coffv  	&cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 &alcog_ heightm,
    model12=cdashaa  	coffv  	&cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 &alcog_ heightm, 
    model13=cdrsaa   	coffv   &cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 &alcog_ heightm,
    model14=cwcrfaa  	coffv  	&cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 heightm,
	model15=rcedihaa 	coffv 	&cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 heightm,
    model16=rcedipaa 	coffv 	&cafhx_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 heightm);
data sens;
set sens;
if index(variable,'edih') | index(variable,'edip') | index(variable,'bmi') |index(variable,'coff') |
   index(variable,'ahei') | index(variable,'amed') | index(variable,'dash') | 
   index(variable,'hpdi') | index(variable,'drs') | index(variable,'wcrf');
HR=put(HazardRatio,4.2)|| ' (' ||put(lcl,4.2)|| ', ' ||put(ucl,4.2)|| ')';
if ProbChiSq<.0001 then p='<0.0001';
else if ProbChiSq<.001 then p=round(ProbChiSq,0.0001);
else if 0.001<=ProbChiSq<0.01 then p=round(ProbChiSq,0.001);
else if 0.01<=ProbChiSq<1 then p=round(ProbChiSq,0.01);
keep variable HazardRatio lcl ucl ProbChiSq HR p;
run;

ods csv file='./bmicoff_totcanew.csv';
proc print data=sens noobs;run;
ods csv close;

title '---------- case no. & person-yr ----------';
proc freq data=pooled;
tables (qcaheia qcameda qchpdia qcdasha qcdrsa qcwcrfa qrcediha qrcedipa 
        qcaheioa qcamedoa qcwcrfoa qrcedihoa qrcedipoa)*tot_cancerv/norow nocol nopercent missing;
run;

%pre_pm(data=pooled, out=pooled_py, 
        irt=irt84 irt86 irt88 irt90 irt92 irt94 irt96 irt98 irt00 irt02 irt04 irt06 irt08 irt10 irt12 irt14,
        timevar=periodnew, cutoff=cutoff, 
        dtdx=dt_totcancer, dtdth=dtdeath,case=tot_cancerv, 
        var=qcaheia qcameda qchpdia qcdasha qcdrsa qcwcrfa qrcediha qrcedipa 
            qcaheioa qcamedoa qcwcrfoa qrcedihoa qrcedipoa);
%pm(data=pooled_py, case=tot_cancerv, 
    exposure=qcaheia qcameda qchpdia qcdasha qcdrsa qcwcrfa qrcediha qrcedipa 
             qcaheioa qcamedoa qcwcrfoa qrcedihoa qrcedipoa);
