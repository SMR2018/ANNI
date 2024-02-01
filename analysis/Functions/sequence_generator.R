to_sequence <- function(.data, spalte_y = "T0020_nFK", spalte_x = "T0", n_future = 1, n_past = 5){
    # n_future = 1   # Number of days we want to look into the future based on the past days.
    # n_past = 5  # Number of past days we want to use to predict the future.
    
    #Empty lists to be populated using formatted training data
    trainX <- matrix(ncol = length(spalte_x)) 
    trainY <- matrix(ncol = length(spalte_y)) 
    
    range1 <- range(n_past, nrow(.data) - n_future)
    seq1 <- seq(from=range1[1], to=range1[2])
    
    for (i in seq1){
        idx1 <- (1 + i - n_past):i
        trainX <- rbind(trainX, 
                        as.matrix(.data)[idx1, spalte_x, drop = FALSE]) 
        #n_past aufeinander folgende Werte
        trainY <- rbind(trainY, 
                        as.matrix(.data)[(i + n_future), spalte_y, drop = FALSE]) 
        #nur eine Zahl
    }
    trainX <- trainX[-1, ,  drop = FALSE] #ersten NA-Eintrag löschen
    trainY <- trainY[-1, ,  drop = FALSE]
    
    return(list(x = trainX, y=trainY))
}

# # #Beispiel: Funktion anwenden:
# .data <- training_df[training_df[,"id_all"] == 1, c(names_y, names_x), drop = FALSE]
# 
# t <- to_sequence(.data = .data,
#                  spalte_y = names_y,
#                  spalte_x = c(names_y, names_x[1:2]),
#                  n_future = 1,
#                  n_past = 5)$x