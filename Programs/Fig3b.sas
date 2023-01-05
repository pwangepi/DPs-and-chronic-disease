*--- Goal: LRT for race/ethnicity and smoking status
;

title "* --------- PH LRT: continuous exposure x categorical race --------- *";
data pooled_lrt;
input lrt1 lrt2 df pattern $;
datalines;
438385.44 438356.81 4 ahei
438477.67 438410.29 4 amed
438003.36 437850.23 4 hpdi
437965.82 437920.89 4 dash
437633.44 437577.13 4 drs
438785.25 438774.68 4 wcrf
436927.72 436832.96 4 edih
437160.20 437042.22 4 edip
;
run; 

data pooled_lrt;
set pooled_lrt;
lrt=abs(lrt1-lrt2); 
Pvalue=round(1-probchi(lrt,df),0.00001); 
run;

proc print data=pooled_lrt;run;



title "* --------- PH LRT: continuous exposure x categorical smoke --------- *";
data pooled_lrt;
input lrt1 lrt2 df pattern $;
datalines;
439521.39 439420.01 2 ahei
439631.65 439531.03 2 amed
439145.11 439017.61 2 hpdi
439073.15 438951.08 2 dash
438736.11 438616.61 2 drs
439977.65 439852.89 2 wcrf
437998.37 437946.84 2 edih
438257.76 438150.47 2 edip
;
run; 

data pooled_lrt;
set pooled_lrt;
lrt=abs(lrt1-lrt2); 
Pvalue=round(1-probchi(lrt,df),0.00001); 
proc print data=pooled_lrt;run;
run;