/*데이터 불러오기*/
proc import file = "C:\Users\jmjwj\Documents\UOS\2학년 2학기\회귀분석\market2021.csv"
dbms = csv out = work.market;
run;

/*데이터 표준화*/
proc standard data = market out = stdmarket mean = 0 std= 1;
run;

/* 모형선택 */

proc reg data = stdmarket;
model y = income pay subway busstop school  apart_count apart_price var10 working_pop   / vif collin;
run; quit;

/*별다른 다중공선성 발견되지 않음*/

/*backward selection - 프로그램에서는 모든 계수 p-value가 0.1보다 작으면 멈춘다.*/
proc reg data = stdmarket;
model y = income pay subway busstop school  apart_count apart_price var10 working_pop   / selection = backward;
run; quit;

/*cp 가 최소인 모델을 결정*/
proc reg data = stdmarket;
model y = pay busstop apart_price var10 working_pop;
run; quit;

/*모형 타당성 검증*/
proc reg data = stdmarket;
model y =  pay busstop apart_price var10 working_pop / partial;
plot rstudent. *(predicted. pay apart_price busstop var10 working_pop);
plot npp. *rstudent.;
run; quit;

/*box-cox 시도 : y가 양수여야지만 가능*/
proc transreg details data = market;
model boxcox(y) = identity(pay busstop apart_price var10 working_pop);
run; quit;
 

/* 정규성 위배. 평균은 0으로 보임. 등분산성은 애매함. 독립성 고려하지 않을거고 선형성은 있는 듯.*/
/* 등분산성 확인해보자*/

proc reg data = stdmarket;
model y = pay busstop apart_price var10 working_pop / r;
output out = res rstudent = r;
run; quit;

proc univariate data = res;
var y;
run;


data res2;
set res;
if y < -1 then ygroup = -1 ;else if y < -0.6 then ygroup = 0 ;
else if y < -0.4 then ygroup = 1; else if y < -0.2 then ygroup = 2;
else if y < 0 then ygroup = 3; else if y < 0.2 then ygroup = 4;
else if y < 0.4 then ygroup = 5; else if y < 0.6 then ygroup = 6;
else if y < 0.8 then ygroup = 7; else if y < 1 then ygroup = 8;
else if y < 1.2 then ygroup = 9; else if y < 1.4 then ygroup = 10;
else if y < 1.6 then ygroup = 11; else if y < 1.8 then ygroup = 12;
else if y < 2 then ygroup = 13; else if y < 2.2 then ygroup = 14;
else if y < 2.4 then ygroup = 15; else if y < 2.6 then group = 16;
else if y < 3 then ygroup = 17; else if y < 3.5 then ygroup = 18;
else if y < 4  then ygroup = 19; else ygroup = 20;
run;

proc means data = res2 mean std;
class ygroup;
var r;
output out = variance  std = s;
run;

proc sgplot data = variance;
scatter x = ygroup y = s;
run;

proc reg data = variance;
model s = ygroup;
run;


proc reg data = trans_data;
model y = pay busstop apart_price var10 working_pop;
weight weight;
plot npp. *rstudent.;
plot rstudent. *(predicted. pay busstop apart_price var10 working_pop);
run; quit;

/* 더 발전된 결과 */

/*box-cox */ 
data stdmarket;
set stdmarket;
y_plus = y + 1;
run;

proc transreg details data = stdmarket;
model boxcox(y_plus) = identity(pay busstop apart_price var10 working_pop);
run; quit;

data stdmarket;
set stdmarket;
y_plus_trans = y_plus**(-0.25)/ -0.25;
run;

proc reg data = stdmarket;
model y_plus_trans = pay busstop apart_price var10 working_pop;
plot npp. *rstudent.;
plot rstudent. *(predicted. pay busstop apart_price var10 working_pop);
run;quit;

proc univariate data = stdmarket;
var y_plus_trans ;
output out = work.dat pctlpre = p pctlpts= 0 to 100 by 10;
run;

/*가중회귀 */
proc reg data = stdmarket;
model y_plus_trans = pay busstop apart_price var10 working_pop;
output out = work.res rstudent = r;
run;quit;


data res;
set res;
if y_plus_trans < -5 then y_adj_group = 1; else if y_plus_trans < -4.7 then y_adj_group = 2;
else if y_plus_trans < -4.5 then y_adj_group = 3; else if y_plus_trans < -4.36 then y_adj_group = 4;
else if y_plus_trans < -4.2 then y_adj_group = 5; else if y_plus_trans < -4.1 then y_adj_group = 6;
else if y_plus_trans < -3.95 then y_adj_group = 7; else if y_plus_trans < -3.8 then y_adj_group = 8;
else if y_plus_trans < -3.57  then y_adj_group = 9; else y_adj_group = 10;
run;

proc means std;
class y_adj_group;
var r;
output out = res2 std = v;
run;

proc sort data = res;
by y_adj_group;
run;

data res3;
merge res res2;
by y_adj_group;
run;

data res3;
set res3;
w  = 1/v;
run;

proc reg data = res3;
model y_plus_trans = pay busstop apart_price var10 working_pop;
weight w;
run; quit;


/*회귀진단*/

proc reg data = res3;
model y_plus_trans = pay busstop apart_price var10 working_pop / r influence;
weight w;
output out=res4 dffits= dffits covratio = covratio h= leverage;
run; quit;

data res4;
set res4;
dffits_abs = abs(dffits);
run;

proc sort data = res4 ;
by descending dffits_abs leverage ;
run;


