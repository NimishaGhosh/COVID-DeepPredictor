clc
clear all

warning off
% This program loads both COVIDdeepPredictor() and COVIDdeepPredictorLoad().
% If users want to have their own training model and also get the result on a test data, they need
% to use only COVIDdeepPredictor() and disable COVIDdeepPredictorLoad(). Else, if they want to use a pre-trained model, they
% can disable COVIDdeepPredictor() and run only COVIDdeepPredictorLoad().
[net,labelsNew]=COVIDdeepPredictor();
[labelNew]=COVIDdeepPredictorLoad();