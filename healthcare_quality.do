clear 

use "http://caucasusbarometer.org/downloads/NDI_2019_July_04.08.19_Public.dta" 
set more off

////recodes 
recode SETTYPE - SUBSTRATUM (-3=.) (-7=.) (-9=.) 
/// weights
svyset PSU [pweight=WTIND], strata(SUBSTRATUM) fpc(NPSUSS)singleunit(certainty) || ID, fpc(NHHPSU) || _n, fpc(NADHH)

////recodes 
recode SATHESYS (1=0) (2=0) (3=1) (4=1), gen (SATHESYSrec)

label define SATHESYSrec 0 "Disatisfied", modify
label define SATHESYSrec 1 "Satisfied", modify

label values SATHESYSrec SATHESYSrec 


recode ASSUNHEPR (1=0) (2=0) (3=2) (4=2), gen (ASSUNHEPRrec)

label define ASSUNHEPRrec 0 "Negatively", modify
label define ASSUNHEPRrec 2 "Positively", modify

label values ASSUNHEPRrec ASSUNHEPRrec


recode TRUDIAGN (1=0) (2=0) (3=1) (4=1), gen (TRUDIAGNrec)
label define TRUDIAGNrec 0 "Distrust", modify
label define TRUDIAGNrec 1 "Trust", modify

label values TRUDIAGNrec TRUDIAGNrec 

recode SURGEABR (1=1) (2=0), gen (SURGEABRrec)
label define SURGEABRrec 1 "In Georgia", modify
label define SURGEABRrec 0 "Abroad", modify
label values SURGEABRrec SURGEABRrec

///main issue
recode HESYSISS (1=9) (2=9) (3=1) (4=2) (5=3) (6=9) (7=9) (8=9) (9=9), gen (HESYSISSrec)

label define HESYSISSrec 1 "lack of professionalism of doctors and medical personnel", modify
label define HESYSISSrec 2 "Cost of medical care/doctors visits", modify
label define HESYSISSrec 3 "Cost of medicine", modify
label define HESYSISSrec 9 "Other", modify
label values HESYSISSrec HESYSISSrec

// NewSettype

recode SUBSTRATUM (10=1) (21/26=2) (31/34=2) (51=2) (61=2)  (41/44=3) (52=3) (62=3) , gen(NEW_SETTYPE)
label var NEW_SETTYPE "Settlement type"

label define NEW_SETTYPE 1 "Capital", modify
label define NEW_SETTYPE 2 "Urban", modify
label define NEW_SETTYPE 3 "Rural", modify

label value NEW_SETTYPE NEW_SETTYPE

///education
recode RESPEDU (1=1) (2=1) (3=1) (4=2) (5=3) (6=3) (-3=-3) (-7=-7) (-9=-9) , gen(RESPEDUrec)

label define RESPEDUrec 1 "Secondary or lower", modify
label define RESPEDUrec 2 "Vocational/technical degree", modify
label define RESPEDUrec 3 "Higher than secondary", modify

label values RESPEDUrec RESPEDUrec

//Children in family
gen Child=0
replace Child=1 if HHSIZE>HHASIZE
label var Child "child in hh"
label define Child 1 "Yes", modify
label define Child 0 "No", modify
label value Child Child



//ownership

foreach var of varlist OWNFRDG-OWNCHTG {
recode `var'(1=1) (0 -1 -2=0), gen(`var'_r)
}
foreach var of varlist OWNFRDG_r-OWNCHTG_r {
recode `var' (-3 -7 -9=.)
}
gen OWN=OWNFRDG_r + OWNCOTV_r + OWNSPHN_r + OWNTBLT_r + OWNCARS_r + OWNAIRC_r + OWNWASH_r + OWNCOMP_r + OWNHWT_r + OWNCHTG_r



///Regression 	1 	

recode AGEGROUP SATHESYSrec NEW_SETTYPE RESPEDUrec OWN Child TRUDIAGNrec  UNNEMED ASSUNHEPRrec ETHNOCODE SURGEABRrec (-1=.) (-2=.)


logit SATHESYSrec i.NEW_SETTYPE i.RESPEDUrec OWN  b01.Child b01.TRUDIAGNrec  i.UNNEMED i.ASSUNHEPRrec i.ETHNOCODE i.SURGEABRrec  b01.AGEGROUP


svy: logistic  SATHESYSrec i.NEW_SETTYPE b01.RESPEDUrec OWN b01.Child b01.TRUDIAGNrec  i.UNNEMED i.ASSUNHEPRrec i.ETHNOCODE i.SURGEABRrec    b01.AGEGROUP 
margins, dydx(*) atmeans post
marginsplot

///Regression 2

recode AGEGROUP SATHESYSrec NEW_SETTYPE RESPEDUrec OWN Child TRUDIAGNrec  UNNEMED ASSUNHEPRrec USEUNHEPR ETHNOCODE SURGEABRrec USEUNHEPR (-1=.) (-2=.)

logit SURGEABRrec i.NEW_SETTYPE b01.RESPEDUrec OWN  b01.Child b01.TRUDIAGNrec  i.UNNEMED i.ETHNOCODE  b01.AGEGROUP i.SATHESYSrec 
svy: logistic SURGEABRrec   i.NEW_SETTYPE b01.RESPEDUrec OWN  b01.Child b01.TRUDIAGNrec  i.UNNEMED i.ETHNOCODE  b01.AGEGROUP i.SATHESYSrec 
margins, dydx(*) atmeans post
marginsplot


