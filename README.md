# Forecasting Monthly Cardiovascular Prescriptions in Australia — A SARIMA Time Series Approach

## Overview
This project forecasts the monthly number of cardiovascular prescription scripts dispensed under Australia's Pharmaceutical Benefits Scheme (PBS) Co-payments (Concessional) scheme. Using 204 months of historical data (July 1991 – June 2008), a Seasonal ARIMA (SARIMA) model was built to forecast the following 10 months (July 2008 – April 2009).

This was completed as the final project for RMIT University's MATH1318 Time Series Analysis course.

## Objective
Identify an appropriate SARIMA model and use it to forecast monthly cardiovascular prescription volumes, supporting use cases like pharmaceutical supply planning and health policy budgeting.

## Methodology
- **Exploratory analysis:** trend, seasonality, and variance inspection via time plots, decomposition, and seasonal plots
- **Stationarity testing:** ADF and KPSS tests, `ndiffs()`/`nsdiffs()`
- **Transformation:** log transformation to stabilize variance; seasonal + regular differencing
- **Model identification:** EACF table and BIC table (`armasubsets`)
- **Model fitting & selection:** three candidate SARIMA models compared via AIC, AICc, BIC, RMSE, MAE, MAPE, MASE; verified independently with `auto.arima()`
- **Diagnostics:** residual analysis, Ljung-Box test, Shapiro-Wilk normality test
- **Forecasting:** 10-month forecast with 80%/95% prediction intervals, back-transformed to the original scale

## Final Model
**ARIMA(3,0,0)(0,1,2)₁₂ with drift** — selected based on lowest AIC/AICc/BIC and strongest in-sample accuracy (MAPE = 0.30%, MASE = 0.58), independently confirmed by `auto.arima()`.

## Key Results
- Forecast shows continuation of the historical seasonal pattern: trough around December 2008 (~2.16M scripts), rising to a peak in April 2009 (~4.56M scripts)
- Forecast peak exceeds the highest historical value on record, consistent with the model's positive estimated drift

## Files
- `Cardiovascular_Prescriptions_ARIMA_Forecast_Report.pdf` — full report with methodology, diagnostics, results, and discussion
- `cardiovascular_arima_analysis.R` — complete R code for the analysis

## Tools
R, `forecast`, `tseries`, `TSA`, `tsibbledata`, `dplyr`, `ggplot2`

## Data Source
`tsibbledata` R package (PBS dispensing data)
