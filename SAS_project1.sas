proc import datafile = "/folders/myfolders/Weight-loss.xlsx" 
DBMS = xlsx out = WL0 replace ;  
run;

PROC PRINT DATA = WL0;                      
TITLE 'Input tabel';
RUN;

PROC MEANS data = WL0;  
var weight0	weight1 weight2 walk_steps;                                    
TITLE 'Input';
RUN;

data WL1;
set WL0;
ARRAY weights (3) weight0 weight1 weight2;    
   DO i = 1 TO 3;                       
      IF weights(i) = 9999 THEN weights(i) =.;   
   END;      
drop i;
wd1 = weight0 - weight1;
wd2 = weight0 - weight2;
wd12 = weight1 - weight2;
RUN;

PROC PRINT DATA = WL1;                      
TITLE 'WL1 tabel ';
RUN;

PROC MEANS data = WL1;                                      
   VAR wd2 walk_steps; 
   TITLE 'Quick check of WL1';
RUN;


DATA WL2;
set WL1;
length walk_steps_G loss_weight_G $20;
	If walk_steps < 5000 then walk_steps_G = 'less than 5000';
	else if walk_steps > 10000 then walk_steps_G = 'greater than 10000';
	else walk_steps_G = '5000-10000';
	
	If wd2 ne . and wd2 <= 0  then loss_weight_G = 'not losing weight';
	else if 0 < wd2 <= 5 then loss_weight_G = 'losing <= 5 lb';
	else if wd2 > 5 then loss_weight_G = 'losing > 5 lb';
	else loss_weight_G = 'missing data';
RUN;

PROC PRINT DATA = WL2;                      
   TITLE 'WL2';
RUN;

LIBNAME project "/folders/myfolders";

DATA project.weight_loss;
INPUT WL2;
RUN;


proc freq data = WL2; 
table walk_steps_G * loss_weight_G/norow nocol;
title "Cross table between walking steps and weightloss";
run;

