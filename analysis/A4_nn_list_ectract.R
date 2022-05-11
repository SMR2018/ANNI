nn_list_extract <- function(nn_list,target_y){
#Chose best repetition
#nn_list <- nn4060
errors1 <- map_dbl(nn_list, ~.x$result.matrix[1,])
best_rep <-  which.min(errors1 )
cat("Best Repetition ist: #", best_rep)
nn <- nn_list[[best_rep]]


### Modell mit Test-Daten evaluieren
Predict <- compute(nn,test)


### MSE berechnen:
#target_y <- "T0020_mm"
#target_y <- "T2040_mm"
#target_y <- "T4060_mm"

y_raw <- input_df %>% pull(target_y)
maxy <-max(y_raw)
miny <-min(y_raw)
Predict_ <- Predict$net.result*(maxy-miny)+miny
test.r <- (test %>% pull(target_y))*(maxy-miny)+ miny
MSE.nn <- sum((test.r - Predict_)^2, na.rm = TRUE)/nrow(test)
MSE.nn


#Predicted values ~ actual values
predict_all <- compute(nn, input_df.scaled)
predict_all_net <- predict_all$net.result*(maxy-miny)+miny
df1 <- as.data.table(data.frame(actual_value = y_raw, 
                                predicted_value = predict_all_net,
                                input = "alle_Daten")) %>% bind_cols(idx_saetze)

R2 <- summary(lm(predicted_value ~actual_value, data = df1))$adj.r.squared



list(nn=nn, MSE.nn=MSE.nn, R2=R2, df1 = df1)
}