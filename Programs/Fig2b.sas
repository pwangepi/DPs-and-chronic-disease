*--- Goal: Cox regression of each food/beverage group with major chronic diseases.
;

%macro prep(datvar,basecal);
%rmOutlier(datain=&datvar._data, dataout=&datvar._data, 
           vars=cedih cedip cahei camed cdash chpdi cdrs cwcrf ccalor 
                cediho cedipo caheio camedo cwcrfo ses
                cedihc cedipc cdrsc
                procmv rmeatv ormeatv fishv poulv eggsv butterv margv lowdaiv hidaiv liqv winev beerv teav coffv fruitv frujv
		            cruvegv yelvegv tomav lfvegv leguv othvegv garlicv potv friesv wgrainv rgrainv pizzav snackv nutsv sugbevv lowbevv
		            saldrev crsoupv dessv condv alcoholv yogurtv chocov,
           varsout=cedih cedip cahei camed cdash chpdi cdrs cwcrf ccalor 
                   cediho cedipo caheio camedo cwcrfo ses
                   cedihc cedipc cdrsc
                   procmv rmeatv ormeatv fishv poulv eggsv butterv margv lowdaiv hidaiv liqv winev beerv teav coffv fruitv frujv
		               cruvegv yelvegv tomav lfvegv leguv othvegv garlicv potv friesv wgrainv rgrainv pizzav snackv nutsv sugbevv lowbevv
		               saldrev crsoupv dessv condv alcoholv yogurtv chocov, 
           pctl=0.5 99.5);
run;

%caladj(data=&datvar._data, outdat=&datvar._data, cal=ccalor, basecal=&basecal, logscale=F,
        var=cedih cedip cahei camed cdash chpdi cdrs cwcrf 
            cediho cedipo caheio camedo cwcrfo
            cedihc cedipc cdrsc
            procmv rmeatv ormeatv fishv poulv eggsv butterv margv lowdaiv hidaiv liqv winev beerv teav coffv fruitv frujv
		        cruvegv yelvegv tomav lfvegv leguv othvegv garlicv potv friesv wgrainv rgrainv pizzav snackv nutsv sugbevv lowbevv
		        saldrev crsoupv dessv condv alcoholv yogurtv chocov,
        adjvar=cediha cedipa caheia cameda cdasha chpdia cdrsa cwcrfa 
               cedihoa cedipoa caheioa camedoa cwcrfoa
               cedihca cedipca cdrsca
               procmva rmeatva ormeatva fishva poulva eggsva butterva margva lowdaiva hidaiva liqva wineva beerva teava coffva fruitva frujva
		           cruvegva yelvegva tomava lfvegva leguva othvegva garlicva potva friesva wgrainva rgrainva pizzava snackva nutsva sugbevva lowbevva
		           saldreva crsoupva dessva condva alcoholva yogurtva chocova);

%STD(datain=&datvar._data, dataout=&datvar._data, 
     vars=cediha cedipa caheia cameda cdasha chpdia cdrsa cwcrfa 
          cedihoa cedipoa caheioa camedoa cwcrfoa ses
          cedihca cedipca cdrsca
          procmva rmeatva ormeatva fishva poulva eggsva butterva margva lowdaiva hidaiva liqva wineva beerva teava coffva fruitva frujva
		      cruvegva yelvegva tomava lfvegva leguva othvegva garlicva potva friesva wgrainva rgrainva pizzava snackva nutsva sugbevva lowbevva
		      saldreva crsoupva dessva condva alcoholva yogurtva chocova,
     varsout=cedihaa cedipaa caheiaa camedaa cdashaa chpdiaa cdrsaa cwcrfaa 
             cedihoaa cedipoaa caheioaa camedoaa cwcrfoaa sesa
             cedihcaa cedipcaa cdrscaa
             procmvaa rmeatvaa ormeatvaa fishvaa poulvaa eggsvaa buttervaa margvaa lowdaivaa hidaivaa liqvaa winevaa beervaa teavaa coffvaa fruitvaa frujvaa
		         cruvegvaa yelvegvaa tomavaa lfvegvaa leguvaa othvegvaa garlicvaa potvaa friesvaa wgrainvaa rgrainvaa pizzavaa snackvaa nutsvaa sugbevvaa lowbevvaa
		         saldrevaa crsoupvaa dessvaa condvaa alcoholvaa yogurtvaa chocovaa, 
     pctl=10 90);

proc rank data=&datvar._data group=5 out=&datvar._data;
var   ccalor cediha cedipa caheia cameda cdasha chpdia cdrsa cwcrfa 
      cedihoa cedipoa caheioa camedoa cwcrfoa ses
      cedihca cedipca cdrsca dessva;
ranks qccalor qcediha qcedipa qcaheia qcameda qcdasha qchpdia qcdrsa qcwcrfa 
      qcedihoa qcedipoa qcaheioa qcamedoa qcwcrfoa qses
      qcedihca qcedipca qcdrsca qdessva;
run;

data &datvar._data;
set &datvar._data;
array quintile {*} qccalor qcediha qcedipa qcaheia qcameda qcdasha qchpdia qcdrsa qcwcrfa 
                   qcedihoa qcedipoa qcaheioa qcamedoa qcwcrfoa qses
                   qcedihca qcedipca qcdrsca qdessva;
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

if wtchg=. then wtchg_miss=1;else wtchg_miss=0;
if wtchg=. then wtchg=0;

%indic3(vbl=qdessva,     prefix=qdessva,    min=2, max=5, reflev=1, missing=., usemiss=0);
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
%indic3(vbl=qcdrsca,     prefix=qcdrsca,     min=2, max=5, reflev=1, missing=., usemiss=0);

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

%let cov=&fmdiab_ &cafhx_ &fmcvd_ &actg_ &cigg_ &pkyrg_ &mvyn_ &regasp_ &regibui_ &qccalor_ pmhsex2 pmhsex3 pmhsex4 &alcog_;

%let _timer_start = %sysfunc(datetime());
**** Cox proportional hazard regressions ****;
title '---------- Pooled: main analysis ----------';
%mphreg9(data=pooled, dtdx=dt_chr, event=chrv, dtdth=dtdeath, cutoff=cutoff, tvar=periodnew, outdat=est1,
qret=irt84 irt86 irt88 irt90 irt92 irt94 irt96 irt98 irt00 irt02 irt04 irt06 irt08 irt10 irt12 irt14, 
timevar=t84 t86 t88 t90 t92 t94 t96 t98 t00 t02 t04 t06 t08 t10 t12 t14,
id=id, agevar=agemo,strata=agemo periodnew cohort, 
model1=&cov procmvaa,
model2=&cov rmeatvaa,
model3=&cov ormeatvaa,
model4=&cov fishvaa,
model5=&cov poulvaa,
model6=&cov eggsvaa,
model7=&cov buttervaa,
model8=&cov margvaa,
model9=&cov lowdaivaa,
model10=&cov hidaivaa,
model11=&cov liqvaa,
model12=&cov winevaa,
model13=&cov beervaa,
model14=&cov teavaa,
model15=&cov coffvaa,
model16=&cov fruitvaa,
model17=&cov frujvaa,
model18=&cov cruvegvaa,
model19=&cov yelvegvaa,
model20=&cov tomavaa
);
run;
data est1;
length variable $200.;
set est1;
if index(variable,'vaa');
HR=put(HazardRatio,4.2)|| ' (' ||put(lcl,4.2)|| ', ' ||put(ucl,4.2)|| ')';
if ProbChiSq<.0001 then p='<0.0001';
else if ProbChiSq<.001 then p=round(ProbChiSq,0.0001);
else if 0.001<=ProbChiSq<0.01 then p=round(ProbChiSq,0.001);
else if 0.01<=ProbChiSq<1 then p=round(ProbChiSq,0.01);
keep modelno variable Estimate stderr HazardRatio lcl ucl ProbChiSq HR p;
run;

%mphreg9(data=pooled, dtdx=dt_chr, event=chrv, dtdth=dtdeath, cutoff=cutoff, tvar=periodnew, outdat=est2,
qret=irt84 irt86 irt88 irt90 irt92 irt94 irt96 irt98 irt00 irt02 irt04 irt06 irt08 irt10 irt12 irt14, 
timevar=t84 t86 t88 t90 t92 t94 t96 t98 t00 t02 t04 t06 t08 t10 t12 t14,
id=id, agevar=agemo,strata=agemo periodnew cohort, 
model1=&cov lfvegvaa,
model2=&cov leguvaa,
model3=&cov othvegvaa,
model4=&cov garlicvaa,
model5=&cov potvaa,
model6=&cov friesvaa,
model7=&cov wgrainvaa,
model8=&cov rgrainvaa,
model9=&cov pizzavaa,
model10=&cov snackvaa,
model11=&cov nutsvaa,
model12=&cov sugbevvaa,
model13=&cov lowbevvaa,
model14=&cov saldrevaa,
model15=&cov crsoupvaa,
model16=&cov dessvaa,
model17=&cov condvaa,
model18=&cov alcoholvaa,
model19=&cov yogurtvaa,
model20=&cov chocovaa
);
run;
data est2;
length variable $200.;
set est2;
if index(variable,'vaa');
HR=put(HazardRatio,4.2)|| ' (' ||put(lcl,4.2)|| ', ' ||put(ucl,4.2)|| ')';
if ProbChiSq<.0001 then p='<0.0001';
else if ProbChiSq<.001 then p=round(ProbChiSq,0.0001);
else if 0.001<=ProbChiSq<0.01 then p=round(ProbChiSq,0.001);
else if 0.01<=ProbChiSq<1 then p=round(ProbChiSq,0.01);
keep modelno variable Estimate stderr HazardRatio lcl ucl ProbChiSq HR p;
run;

data all;
length variable $200.;
set est1 est2;
run;

ods csv file='./food_chr.csv';
proc print data=all noobs;run;
ods csv close;
