---
title: "ANNI – Parametrisierung, Version 1"
author: "Samantha Rubo"
date: '2021-12-08'
draft: yes
---

Anhand der Daten aus den Projektjahren 2020 und 2021 auf den Versuchsflächen in Schifferstadt (insgesamt X Anbausätze Spinat) und an der HGU (insgesamt 5 Anbausätze) soll eine erste Version des **Bewässerungsmodells ANNI** parametrisiert werden. 

Dafür werden zunächst zwei unabhängige Modelle erstellt. Grund dafür ist die unterschiedliche zeitliche Auflösung: Ein Modell wird anhand der Tensiometerwerte (stündlich) und korrespondierender Wetterdaten erstellt (stündlich oder täglich).


### Parameter ANN_Umwelt

* **Input-Parameter**
  * Start-nFK bzw. Output-nFK der letzten Modellierung 
  * Tage seit Kulturbeginn
  * Temperatur
  * Globalstrahlung
  * rel. Luftfeuchte
  * Windgeschwindigkeit
  * Niederschlag
  * Bewässerungsmenge
  * (Kultur)
  * (Boden)
* **Output-Parameter**
  * Bodenmatrixpotential (oder umgerechnet in %nfK, aus Tensiometer) in drei Bodentiefen (20, 40, 60cm)
  

Die Input-Parameter des neuronalen Netzes sind identisch mit denen der FAO56, um die Grasreferenzverdunstung zu berechnen, welche wiederum die Berechnungsgrundlage der Geisenheimer Steuerung (GS) ist. Der Outputparameter ist die Änderung im Bodenmatrixpotential (oder %nFK). Dies hat den Sinn, dass Schwellenwerte der nFK definiert werden können, bei denen bewässert werden soll. Dies erübrigt einen kc-Wert, allerdings muss für eine Übertragbarkeit des Modells neue Daten für verschiedene Böden und Kulturen einfließen.

Theoretisch kann dieses parametrisierte Modell auch für eine **Prognose** genutzt werden. Abgerufene Wetter-Prognosen (Temp, Niederschlag, ggf. Mittelwerte (aktuelle Woche oder Monat, oder Referenzwerte aus den letzten Jahren)) können einem zukünftige Kulturzeitraum (Parameter "Tage seit Kulturbeginn") eingefügt werden. 
  
### Ergänzung um "Spinatdaten"

Im nächsten Schritt wird das Modell erweitert um:

* **Input-Parameter Vegetationsindices** des ISARIA-Sensors
  * IBI
  * IRMI

Es wird untersucht, wie stark die zusätzlichen Vegetationsindizes das Ergebnis (Ausgabe nFK) beeinflussen, bzw. ob dadurch eine bessere Genauigkeit der Bewässerungsempfehlung möglich ist.


### Vergleich ANNI & GS
Die Performance der GS wird evaluiert auf Grundlage der Bodenfeuchtedaten des Tensiometers. Die Genauigkeit der beiden Modelle, ANNI und GS, wird anschließend verglichen.


## Abfolge in diesem R-Projekt
1. Tensiometerdaten (hPa) in %nFK umrechnen
2. Tages-Mittelwerte der nFK berechnen
3. Tabelle erstellen für einen gewählten Satz Spinat
    - Wetterdaten zusammentragen
    - applizierte Wassermengen 
    - Tage seit Kulturbeginn
    - IBI und IRMI
4. ANNI_0 erstellen (in R)
5. Parameter mit dem größten Einfluss identifizieren
6. Güte des Modells ANNI_0 darstellen
7. ANNI_0 erweitern (in Input-Tabelle) durch IBI und IRMI
8. Vergleich der Leistung ANNI_0 und ANNI_VI
9. Regression Änderung Tensiometer (delta %nFK) ~ Geisenheimer Steuerung (KWB)
10. Vergleich der Güte GS (Regression aus Punkt 9) und ANNI_0 bzw. ANNI_VI



  
