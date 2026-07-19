library(tsibbledata)
library(dplyr)
library(forecast)
library(tseries)
library(ggplot2)
library(TSA)

# Data Loading
my_data <- PBS %>%
  filter(ATC1 == "C",           # Cardiovascular system
         Type == "Co-payments",
         Concession == "Concessional") %>%
  group_by(Month) %>%
  summarise(Scripts = sum(Scripts)) %>%
  ungroup()

# To View it
View(my_data)

# Quick plot
plot(my_data$Scripts, type = "l", 
     main = "Monthly Cardiovascular Prescriptions in Australia",
     xlab = "Month", ylab = "Number of Scripts")

# Convert to ts object
cardio_ts <- ts(my_data$Scripts, 
                start = c(1991, 7), 
                frequency = 12)

# time plot
autoplot(cardio_ts) +
  labs(title = "Monthly Cardiovascular Prescriptions in Australia",
       subtitle = "PBS Medicare Data: July 1991 - June 2008",
       x = "Year", 
       y = "Number of Scripts") +
  theme_minimal()

# DESCRIPTIVE STATISTICS

# Summary statistics
summary(cardio_ts)

cat("Mean:", mean(cardio_ts), "\n")
cat("Std Dev:", sd(cardio_ts), "\n")
cat("Min:", min(cardio_ts), "\n")
cat("Max:", max(cardio_ts), "\n")

# Decomposition

# Multiplicative decomposition (because variance increases over time)
cardio_decomp <- decompose(cardio_ts, type = "multiplicative")
plot(cardio_decomp)

# Seasonal plot
ggseasonplot(cardio_ts,
             year.labels = TRUE,
             main = "Seasonal Plot: Cardiovascular Scripts") +
  theme_minimal()

# ACF AND PACF

par(mfrow = c(1, 2))
acf(cardio_ts,  lag.max = 48, 
    main = "ACF - Cardiovascular Scripts")
pacf(cardio_ts, lag.max = 48, 
     main = "PACF - Cardiovascular Scripts")

# STATIONARITY TESTS

# ADF Test
adf.test(cardio_ts)

# KPSS Test
kpss.test(cardio_ts)

# HOW MANY DIFFERENCES NEEDED
ndiffs(cardio_ts)
nsdiffs(cardio_ts)

# TRANSFORMATION & DIFFERENCING

# Log transformation
cardio_ts_log <- log(cardio_ts)

autoplot(cardio_ts_log) +
  labs(title = "Log Transformed Cardiovascular Scripts",
       x = "Year", y = "Log Scripts") +
  theme_minimal()

# Seasonal differencing 
cardio_diff <- diff(cardio_ts_log, lag = 12)

# Regular differencing
cardio_diff2 <- diff(cardio_diff, differences = 1)

# Plot differenced series
autoplot(cardio_diff2) +
  labs(title = "Differenced Series (Seasonal + Regular)",
       x = "Year", y = "Differenced Scripts") +
  theme_minimal()

# ACF/PACF after differencing
par(mfrow = c(1, 2))
acf(cardio_diff2, lag.max = 48, 
    main = "ACF After Differencing")
pacf(cardio_diff2, lag.max = 48, 
     main = "PACF After Differencing")

# Stationarity after differencing
adf.test(cardio_diff2)
kpss.test(cardio_diff2)

# EACF Table
eacf(cardio_diff2)

# BIC Table
res = armasubsets(y = cardio_diff2, nar = 7, nma = 7, 
                  y.name = 'p', ar.method = 'ml')
plot(res)

# Candidate model
model1 <- Arima(cardio_ts_log, order = c(3,0,0), 
                seasonal = list(order = c(0,1,2), period = 12),
                 include.drift = TRUE)
summary(model1)
checkresiduals(model1)
model2 <- Arima(cardio_ts_log, order = c(1,0,0), 
                seasonal = list(order = c(0,1,1), period = 12),
                include.drift = TRUE)
summary(model2)

model3 <- Arima(cardio_ts_log, order = c(2,0,0), 
                seasonal = list(order = c(0,1,1), period = 12),
                include.drift = TRUE)
summary(model3)

# Model comparison

AIC(model1, model2, model3)
BIC(model1, model2, model3)

accuracy(model1)
accuracy(model2)
accuracy(model3)

# MODEL FITTING
auto_model <- auto.arima(cardio_ts_log, 
                           stepwise = FALSE,
                           approximation = FALSE,
                           trace = TRUE)
summary(auto_model)

# selecting final model 
best_model <- model1   
  
# Residual diagnostics
checkresiduals(best_model)

# Ljung-Box test
Box.test(best_model$residuals, lag = 24, type = "Ljung-Box")

# Normality test of residuals
shapiro.test(best_model$residuals)

# Residual ACF
par(mfrow = c(1,1))
acf(best_model$residuals, main = "ACF of Residuals")

# ACCURACY
accuracy(best_model)

# FORECASTING
forecast_log <- forecast(best_model, h = 10, level = c(80, 95))

print(forecast_log)

# Back-transform to original scale
forecast_final <- forecast_log
forecast_final$mean  <- exp(forecast_log$mean)
forecast_final$lower <- exp(forecast_log$lower)
forecast_final$upper <- exp(forecast_log$upper)
forecast_final$x     <- exp(forecast_log$x)

#Forecast table
forecast_table <- data.frame(
  Month = c("Jul 2008","Aug 2008","Sep 2008",
            "Oct 2008","Nov 2008","Dec 2008",
            "Jan 2009","Feb 2009","Mar 2009","Apr 2009"),
  Point_Forecast = round(as.numeric(forecast_final$mean)),
  Lo_80 = round(as.numeric(forecast_final$lower[,1])),
  Hi_80 = round(as.numeric(forecast_final$upper[,1])),
  Lo_95 = round(as.numeric(forecast_final$lower[,2])),
  Hi_95 = round(as.numeric(forecast_final$upper[,2]))
)
print(forecast_table)

# Final forecast plot
autoplot(forecast_final) +
  labs(title = "10-Month Forecast: Cardiovascular Prescriptions in Australia",
       subtitle = "Final Selected SARIMA Model with Log Transformation",
       x = "Year",
       y = "Number of Scripts",
       caption = "Shaded regions: 80% and 95% prediction intervals") +
  theme_minimal()