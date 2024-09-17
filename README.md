---
title: "Artificial Neural Net for Irrigation - ANNI"
author: "Samantha Rubo"
date: '2024-08-31'
draft: yes
---

## Background

Precise irrigation management in vegetable production is key for optimizing water use and ensuring crop productivity. This repository provides the implementation of two types of artificial neural networks (ANNs)— Multilayer Perceptrons (MLPs) and Long Short-Term Memory (LSTM) networks— for predicting available water capacity (AWC, in %) as the target parameter for irrigation scheduling.

The models are trained using data from a three-year field experiment with spinach across two sites in Germany. The experimental dataset includes soil texture, plant signals, developmental status derived from vegetation indices, and meteorological data such as air temperature, humidity, wind speed, and photothermal time.

Additionally, pretrained models using publicly available AWC data from 320 stations in Germany were fine-tuned with the experimental data, improving model accuracy and robustness. An ensemble model consolidates the outputs from all models, minimizing cumulative errors and providing robust predictions for various climatic conditions and soil textures.

The implementation of these ANNs is designed to be easily adaptable for other vegetable crops, though it requires expertise in both IT and agricultural management for proper deployment.

## Key Features

- **ANN Models:** Two types of ANN architectures: MLP and LSTM networks.
- **Input Data:** Soil texture, plant vegetation indices, meteorological variables (temperature, humidity, wind speed, etc.).
- **Fine-Tuning:** Models pretrained with AWC data from 320 stations and fine-tuned with experimental data.
- **Ensemble Model:** Combines MLP and LSTM outputs for more robust and accurate predictions.
- **Explainable AI:** Includes variable importance analysis and sensitivity analysis to highlight key drivers for irrigation scheduling.
- **High Accuracy:** Achieved R² > 0.98 and RMSE < 1.5% across soil depths (0-20 cm, 20-40 cm, 40-60 cm).


The correstpondig publication is currently under review. A preprint is available:
Rubo, Samantha and Zinkernagel, Jana, Enhancing the Prediction of Irrigation Demand for Open Field Vegetable Crops Through Neural Networks, Transfer Learning, and Ensemble Models. Available at SSRN: https://ssrn.com/abstract=4925253