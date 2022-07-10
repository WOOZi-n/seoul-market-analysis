# -*- coding: utf-8 -*-
"""
Created on Sat May 21 01:07:45 2022

@author: jmjwj
"""
import pandas as pd
import os

files = os.listdir(r"C:\Users\jmjwj\Documents\UOS\2학년 2학기\회귀분석\상권분석")
dat = []
for file in files:
    table = pd.read_csv(r"C:\Users\jmjwj\Documents\UOS\2학년 2학기\회귀분석\상권분석\{}".format(file), header = 0, encoding = 'cp949')
    dat.append(table)
files

predsell = dat[0]
livingpop = dat[1]
income_pay = dat[2]
apart = dat[3]
workingpop = dat[4]
facility = dat[5]

income = income_pay.pivot_table(values = ['지출_총금액', '월_평균_소득_금액'], 
                       index = ['기준 년 코드'], columns = '상권_코드_명').loc[2021]['월_평균_소득_금액']
pay =  income_pay.pivot_table(values = ['지출_총금액', '월_평균_소득_금액'], 
                       index = ['기준 년 코드'], columns = '상권_코드_명').loc[2021]['지출_총금액']


facility = facility.groupby(['기준_년_코드','상권_코드_명']).mean().loc[2021]
import numpy as np
facility.replace({np.nan : 0}, inplace = True)
subway = pd.Series(facility.지하철_역_수 ,index = facility.index)
#new variable
busstop = pd.Series(facility.버스_정거장_수 ,index = facility.index)
school = pd.Series(facility.초등학교_수 ,index = facility.index) + pd.Series(facility.중학교_수 ,index = facility.index) + pd.Series(facility.고등학교_수 ,index = facility.index)
station = pd.Series(facility.버스_터미널_수, index = facility.index) + pd.Series(facility.철도_역_수, index = facility.index)  
       
apartcount = apart.groupby('상권_코드_명').mean()['아파트_단지_수']
apartprice = apart.groupby('상권_코드_명').mean()['아파트_평균_시가']


livingpop_tot = livingpop.groupby('상권_코드_명').총_생활인구_수.mean()                                       
livingpop_10s = livingpop.groupby('상권_코드_명').연령대_10_생활인구_수.mean()                                       
livingpop_20s = livingpop.groupby('상권_코드_명').연령대_20_생활인구_수.mean()                                       
livingpop_30s = livingpop.groupby('상권_코드_명').연령대_30_생활인구_수.mean()                                       
livingpop_40s = livingpop.groupby('상권_코드_명').연령대_40_생활인구_수.mean()                                       
livingpop_50s = livingpop.groupby('상권_코드_명').연령대_50_생활인구_수.mean()                                       
livingpop_60s = livingpop.groupby('상권_코드_명').연령대_60_이상_생활인구_수.mean()                                       

workingpop = workingpop.groupby(['기준_년_코드','상권_코드_명']).총_직장_인구_수.mean()[2021]     

                                  
predsell = predsell.groupby('상권_코드_명').분기당_매출_금액.mean()
income.name = 'income'
pay.name = 'pay'
livingpop.name = 'floating_pop'
subway.name = 'subway'
busstop.name = 'busstop'
school.name = 'school'
station.name = 'station'
apartcount.name = 'apart_count'
apartprice.name = 'apart_price'
workingpop.name = 'working_pop'
predsell.name = 'Y'





datas = [income, pay, subway,busstop, school, station, apartcount, apartprice, livingpop_tot, livingpop_10s, livingpop_20s,
         livingpop_30s, livingpop_40s, livingpop_50s, livingpop_60s, workingpop, predsell]

analy = pd.concat(datas, axis = 1)
analy = analy.loc[analy.notnull().all(axis = 1)]
analy.to_csv(r"C:\Users\jmjwj\Documents\UOS\2학년 2학기\회귀분석\market2021.csv")
