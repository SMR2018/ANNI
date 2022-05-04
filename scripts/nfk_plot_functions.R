#Plots:
### nFK plotten

nfk_interpolation <- function(.data, .gruppen=gruppen){
    a <- .data %>% ungroup 
    # Schichtmittelpunkte gewählt, statt 20cm-Schichtdicke
    B0cm <- a %>% filter(Bodentiefe == 10) %>% mutate(Bodentiefe = 0)
    B60cm <- a %>% filter(Bodentiefe == 50) %>% mutate(Bodentiefe = 60)
    
    #damit Fehlende Werte nur in den vorgesehenen Zeit- und Tiefenslots fehlen: 
    #ausfuellen mit tatsächlichen Werten
    a <- a %>% 
        pivot_wider(id_cols = .gruppen, names_from = "Bodentiefe", 
                    values_from ="nFK_prozent", names_prefix = "T" ) %>%
        mutate(T20 = ifelse(is.na(T10), T30,NA),
               T40 = ifelse(is.na(T50), T30,NA)) %>% 
        pivot_longer(cols = c("T10", "T20", "T30", "T40", "T50"),
                     names_to = "Bodentiefe", values_to = "nFK_prozent")%>% 
        filter(!is.na(nFK_prozent)|Bodentiefe %in% c(20,40)) %>%    
        mutate_at("Bodentiefe", ~substr(., 2,3) %>% as.numeric) %>%
        bind_rows(B0cm, B60cm)
    
    
    gruppen2 <- c(.gruppen[!grepl(x = .gruppen,  #fuer zweite interpolation (x-Achse) gruppieren
                                  pattern = c("zeit_messung|tage_seit_aussaat"))], #ohne diese
                  "Bodentiefe") #mit dieser Variable
    
    # a_interpoliert <- 
    a %>% arrange(Bodentiefe) %>% 
        group_by_at(.gruppen) %>%
        do(approx(x = .$Bodentiefe,
                  y = .$nFK_prozent, 
                  rule = 1, 
                  xout = seq(0,60,by=1), #pro 1 cm
        ) %>% as.data.frame) %>%
        rename(Bodentiefe = x, nFK_prozent = y) %>%
        group_by_at(gruppen2) %>% 
        do(approx(x = .$tage_seit_aussaat,
                  y = .$nFK_prozent, 
                  rule = 1, 
                  xout = seq(min(.$tage_seit_aussaat, na.rm = TRUE),
                             max(.$tage_seit_aussaat, na.rm = TRUE),by=0.1) #10 Punkte pro Tag
        ) %>% as.data.frame) %>%
        rename(tage_seit_aussaat = x, nFK_prozent = y) %>%
        ungroup
    
    #return(a_interpoliert)
}


###zunaechst Daten vorbereiten:

# plot erstellen: #minus-Bodentiefe, da der Wert die "bis"-Bodentiefe beschreibt
daten_plot_nfk <- function(satz_nr=satz_nr, wdh = FALSE, variante = NULL, grafik = NULL) {
    #Konflikte mit Daten im Workspace vermeiden:
    tensio_melted2 <- tensio_melted %>% filter(satz_id == satz_nr & !is.na(nFK_prozent)) %>%
        mutate_at("Bodentiefe", ~.-10)
    wasser_gesamt2 <- wasser_gesamt %>% filter(satz_id == satz_nr) 
    saetze_ausaat2 <- saetze_ausaat %>% filter(satz_id == satz_nr)    
    
    #Plothoehe des Wassereintrages auf min 25 setzen. In X-Achsenskala ausblenden.
    add_for_plot_heigth <-  wasser_gesamt2 %>% 
        group_by(variante_H2O, wiederholung) %>% 
        slice(., 1) %>% 
        mutate(zeit_messung = as_date("1900-01-01"), 
               tage_seit_aussaat = -100, 
               value_stacked = 25)
    wasser_gesamt2 <- wasser_gesamt2 %>% bind_rows(add_for_plot_heigth)
    
    
    
    #Pro Variante oder einzeln fuer Wiederholung:
    if(isFALSE(wdh)) { #== Mittelwert aller Wiederholungen einer Variante
        gruppen <- c("kategorie", "satz_id", "variante_H2O",
                     "zeit_messung", "tage_seit_aussaat")
        
        tensio_melted2 <- tensio_melted2 %>% 
            group_by(kategorie, satz_id, variante_H2O, Bodentiefe, 
                     zeit_messung, tage_seit_aussaat) %>%
            summarise(nFK_prozent = mean(nFK_prozent, na.rm = TRUE)) %>%
            ungroup();
        
        wasser_gesamt2 <- wasser_gesamt2 %>% 
            group_by(kategorie, variable, satz_id, variante_H2O, 
                     zeit_messung, tage_seit_aussaat) %>%
            summarise(value = mean(value, na.rm = TRUE)) %>%
            ungroup() %>%
            stacked_bars_plot(gruppen = gruppen);    
        
        
    } else { #== Wiederholungen einer Variante vergleichen
        gruppen <- c("kategorie", "satz_id", "variante_H2O",
                     "wiederholung", "zeit_messung", "tage_seit_aussaat")
        tensio_melted2 <- tensio_melted2 %>% filter(variante_H2O == variante);
        wasser_gesamt2 <- wasser_gesamt2 %>% filter(variante_H2O == variante);
        
        #SD-Daten
        wasser_gesamt_sd2 <- wasser_gesamt_sd %>%  
            filter(satz_id == satz_nr & variante_H2O == variante) %>%
            mutate(wiederholung = "Stabw")
        
        tensio_sd2 <- tensio_sd %>%  
            filter(satz_id == satz_nr & variante_H2O == variante) %>%
            mutate(wiederholung = "Stabw") %>%
            mutate_at("Bodentiefe", ~.-10)
        
        #Farben des SD-Plots (Grau-Skala)
        my_breaks_sd <- c(seq(from = 0, to = 30, by = 5), Inf);
        my_colors_sd <- grey.colors(7, start = 0.1, end = 0.8, rev = TRUE);
        my_labels_sd <- levels(cut(tensio_sd2$nfK_sd, breaks = my_breaks_sd))
        
        tensio_sd2 <- tensio_sd2 %>% mutate_at("nfK_sd", ~cut(., my_breaks_sd))
        
        wdh_list <- list(
            wasser_gesamt_sd2 = wasser_gesamt_sd2,
            tensio_sd2=tensio_sd2,
            my_breaks_sd=my_breaks_sd,
            my_colors_sd=my_colors_sd,
            my_labels_sd=my_labels_sd)
    }
    
    
    
    ##Tabelle fuer Interpolation definieren:
    if (is.null(grafik)){
        tensio_melted2 <- tensio_melted2} else if(grafik == "smooth"){
            tensio_melted2 <- tensio_melted2 %>% nfk_interpolation(.gruppen = gruppen)
        } 
    
    
    #Farbspektrum definieren für nFK:
    my_breaks <- c(seq(from = 0, to = 120, by = 10), Inf)
    my_colors <- c(
        colorRampPalette(c("brown", "#fac83c"))(6),
        colorRampPalette(c("lightgreen", "forestgreen"))(3),
        colorRampPalette(c("#32c8fa", "darkblue"))(4)
    )
    my_labels <- levels(cut(tensio_melted$nFK_prozent, breaks = my_breaks))
    
    basic_list <- list(tensio_melted2=tensio_melted2,
                       wasser_gesamt2=wasser_gesamt2,
                       saetze_ausaat2=saetze_ausaat2,
                       my_breaks=my_breaks,
                       my_colors=my_colors,
                       my_labels=my_labels)
    
    list_output <- if(isTRUE(wdh)){c(basic_list, wdh_list)} else {basic_list}
    
    return(list_output)
    
}



plot_smooth <- function(data = list1, grafik = NULL){
    if(is.null(grafik)){
        geom_tile(data = data$tensio_melted2,
                  aes(x = tage_seit_aussaat, y = -(Bodentiefe), fill = nFK_prozent,
                      width = 1, height = 20), na.rm = TRUE) 
    } else if(grafik=="smooth"){
        geom_raster(data = data$tensio_melted2, 
                    aes(x=tage_seit_aussaat, y=-Bodentiefe, fill=nFK_prozent))
    } 
    
}




plot_nfk <- function(satz_nr, subtitle, wdh = FALSE, variante = NULL, grafik=NULL) {
    
    #Daten von oben als Liste erhalten:
    list1 <- daten_plot_nfk(satz_nr = satz_nr, wdh = wdh, variante = variante, grafik = grafik)
    attach(list1) #damit auf die Tabellen per Name zugegriffen werden kann.
    
    
    #gg-Plot-Funktion:
    p <- ggplot() +
        plot_smooth(data = list1, grafik = grafik) + 
        
        
        scale_fill_gradientn("Bodenfeuchte (% nFK)",
                             colours = c(my_colors, "black"), 
                             values = scales::rescale(c(1:(length(my_colors)+1)), 
                                                      to=c(0,1)),
                             limits = c(0,150)
        ) +
        
        
        # Regen und Bewässerung anfügen:
        geom_segment(data=wasser_gesamt2,
                     aes(x = tage_seit_aussaat, y =value_min,
                         xend = tage_seit_aussaat, yend = value_stacked,
                         color = variable), size=1.5) +
        scale_color_manual("Wassereintrag (mm)",
                           values = c("niederschlag_mm" = "gray70",
                                      "bewaesserung_mm" = "gray10"),
                           labels = c("niederschlag_mm" = "Regen",
                                      "bewaesserung_mm" = "GS")
        ) +
        
        #Titel:
        labs(title = "Bodenfeuchte und Wassereintrag Spinat-Versuch",
             subtitle = paste0(subtitle, 
                               " (Kulturdauer: ", 
                               saetze_ausaat2$datum_aussaat, " bis ", 
                               saetze_ausaat2$datum_ernte, ")"), 
             x = "Tage seit Aussaat", y = ""
        ) +
        
        #X-Achse skalieren:
        coord_cartesian(xlim=c(sort(tensio_melted2$tage_seit_aussaat)[2], NA))
    #erster Wert ist -100 als Platzhalter. Daher hier den 2. Wert nehmen.
    
    
    # Standardabweichung anfügen:
    p <-    if(isTRUE(wdh)){ 
        p+  ggnewscale::new_scale("fill")+ # zweite fill-scale für SD-Plot
            geom_tile(
                data = tensio_sd2,
                aes(x = tage_seit_aussaat, y = -(Bodentiefe), fill = nfK_sd,
                    width = 1, height = 20)
            ) +
            scale_fill_manual("Stabw Bodenfeuchte (% nFK)",
                              values = my_colors_sd,
                              labels = my_labels_sd,
                              drop = FALSE
            )+
            
            geom_segment(data=wasser_gesamt_sd2,
                         aes(x = tage_seit_aussaat, y =0,
                             xend = tage_seit_aussaat, yend = wasser_sd,
                             color = variable), size=1)
    } else {p}
    
    
    # Facets anfügen:
    p<- p+
        facet_grid(kategorie ~ if(isFALSE(wdh)){variante_H2O} else {wiederholung},
                   scales = "free_y", switch = "y", space = "free_y",
                   labeller = labeller(
                       .rows = as_labeller(
                           c(nFK = "Bodentiefe (cm)",
                             wasserinput = "Wassereintrag (mm)")),
                       .cols = label_value),
                   drop = FALSE # damit Wfull_plus in Satz1 dargestellt wird (ohne Daten)
        ) + 
        theme_bw() +
        theme(
            panel.grid = element_blank(),
            strip.placement = "outside",
            strip.background.y = element_blank(),
            panel.spacing = unit(0, "lines"),
            legend.key.size = unit(12, units = "pt"),
            legend.key.width = unit(12, units = "pt")
        ) +
        guides(col = guide_legend(order = 1))# +
    
    detach(list1) #Namentliche Nennung wieder aufheben.
    
    # Ausgabe des Plots
    p
}
