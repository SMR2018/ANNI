plot_measured_predicted_lm <- function(linear_model = lm1, data = result, alpha = 0.1){
    df_label <- data.frame(
        depth = labels1,
        eq_term = map_chr(
            linear_model, 
            ~as.character(as.expression(substitute(
                italic(y) == a + b %.% italic(x), 
                list(a = format(.x$coefficients[1], digits = 2),
                     b = format(.x$coefficients[2], digits = 2)))))),
        
        r2 = map_chr(
            linear_model, 
            ~as.character(as.expression(substitute(
                italic(R)^2~"="~r2, 
                list(r2 = format(.x$r.squared, digits = 3)))))),
        
        rmse = paste0("RMSE = ", rmse1)
    )
    #df_label
    
    ymax1 = 127
    delta1 <- 10
    min_nfk <- 60
    ggplot(data,
           aes(measured, predicted)) +
        geom_polygon(data = data.frame(x=c(0,0,100,100,0), 
                                       y=c(0,100,100,0,0)), 
                     aes(x,y), fill = "lightblue", alpha = 0.3) + 
        geom_polygon(data = data.frame(x=c(min_nfk,min_nfk,100,100,min_nfk), 
                                       y=c(min_nfk,100,100,min_nfk,min_nfk)), 
                     aes(x,y), fill = "lightblue", alpha = 0.5) + 
        scattermore::geom_scattermore(pointsize = 2, alpha = 0.1) + 
        geom_point(alpha = alpha) +
        geom_abline(slope = 1, intercept = 0, color = "black", linetype = 2) +
        facet_wrap(depth~.) +
        theme_bw() +
        theme(panel.grid = element_blank(), 
              aspect.ratio = 1) + 
        stat_smooth( method = "lm", formula = "y~x", ) +
        
        geom_text(data = df_label, aes(x = 0, y = ymax1, label = eq_term),
                  parse = T, hjust = 0, vjust= 0.5, color = "black", size = 3) +
        geom_text(data = df_label, aes(x = 0, y = ymax1 - delta1, label = r2),
                  parse = T, hjust = 0, vjust= 0.5, color = "black", size = 3) + 
        geom_text(data = df_label, aes(x = 0, y = ymax1 - 2*delta1, label = rmse),
                  parse = F, hjust = 0, vjust= 0.5, color = "black", size = 3)
}

# plot_measured_predicted_lm()