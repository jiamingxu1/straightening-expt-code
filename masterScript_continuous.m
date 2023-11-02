% MASTERSCRIPT runs a given experiment by calling the CREATETRIALMATRIX
% function and the SETUP function before running the created PLDAPS object
%
%   YB   wrote it. <yoonbai@utexas.edu>
%
% 2018-09-05  SMS  repurposed it for psychophysical straightening study. <smshields@utexas.edu>

sca;
clear java;

% linearize CRT
load('/Users/gorislab/Desktop/psychophysics/Calib/2018/humanRig20180612.mat')
gammaStruct.display.forceLinearGamma    = true;
gammaStruct.display.gamma.power         = gam.power;

subject_string  = 'test';

% trial conditions (will not overwrite existing file)
session         = NaturalStraightening.createTrialMatrix(subject_string);


% keep track of where I am in the trial matrix
trial_matrix_idx     = nan;
while(~session.endExperiment)
    
    % check if there are updates from 'sessionInfo.mat'
    load(session.sessionFilePath, 'session');
    
    % In terms of the massive trial matrix, how far am I?
    load(session.trialMatrixFile, 'S');
    trialResp         = S.trialMatrix(:,end);
    unvisitedTrials   = find(isnan(trialResp));
    if(~isempty(unvisitedTrials))
        trial_matrix_idx = unvisitedTrials(1);
    else
        session.endExperiment = true;
        session.isFinalBlock  = true;
        save(session.sessionFilePath, 'session');
        
        % farewell
        window_ptr = Screen('OpenWindow', max(Screen('Screens')), 225);
        Screen('TextSize',window_ptr, 40);
        goodbyeString = sprintf('You''ve already finished all of your trials, %s!',subjectName);
        DrawFormattedText(window_ptr, goodbyeString, 'center', 400, [0, 0, 0, 255]);
        Screen('Flip', window_ptr);
        WaitSecs(2);
        break;
        
    end
    
    if(session.endExperiment)
        break;
    else
        p = pldaps(@NaturalStraightening.setup, subject_string, gammaStruct);
        
        % lower bg intensity to prevent pixel clipping
        p.trial.display.bgColor = [0.25, 0.25, 0.25];
        
        p.run;
    end
end