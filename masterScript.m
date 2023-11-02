% MASTERSCRIPT runs a given experiment by calling the CREATETRIALMATRIX
% function and the SETUP function before running the created PLDAPS object
%
%   YB   wrote it. <yoonbai@utexas.edu>
%
% 2018-09-05  SMS  repurposed it for psychophysical straightening study. <smshields@utexas.edu>

sca; 
clear java;

% linearize CRT 
% load ~/Documents/Calib/2018/rig_1_20180808.mat;
% gammaStruct.display.forceLinearGamma    = true;
% gammaStruct.display.gamma.power         = gam.power; % this is for Rig 1
gammaStruct.display.forceLinearGamma    = true;
gammaStruct.display.gamma.power         = 0.5;

% trial conditions
%NaturalStraightening.createTrialMatrix('test', 'windowSize', 2, 'numRepetitions', 11); 
NaturalStraightening.createTrialMatrix('test_JX'); 

% make PLDAPS object
p   = pldaps(@NaturalStraightening.setup,'test_JX', gammaStruct);

% override BG luminance for this experiment only
p.trial.display.bgColor = [0.25, 0.25, 0.25];

p.run;