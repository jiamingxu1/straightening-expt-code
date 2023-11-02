function session = startExptSession(subject_string)
% STARTEXPTSESSION runs a given experiment by loading the subject's trial
% matrix (either by running the CREATETRIALMATRIX function or loading the
% existing trial matrix) and the SETUP function before running the
% created PLDAPS object.
%
%   YB   wrote it as MASTERSCRIPT. <yoonbai@utexas.edu>
%
% 2018-09-05  SMS  repurposed it for psychophysical straightening study. <smshields@utexas.edu>
% 2018-10-25  SMS  converted it to a function.

%% set toolbox and current directory

toolbox = '+NaturalStraightening';
%cd(NaturalStraightening.CONSTANTS.ROOT_FOLDER);

%% create or load subject trial matrix

folder = [NaturalStraightening.CONSTANTS.ROOT_FOLDER, 'data/', subject_string, '/'];
mkdir(folder);

% check if files for (1) trial matrix and (2) session info already exists.
trialMatrix_filename    = sprintf('%s_%s.mat', toolbox(2:end), subject_string);
trialMatrix_filepath    = [folder, trialMatrix_filename];

sessionInfo_filename    = 'sessionInfo.mat';
sessionInfo_filepath    = [folder, sessionInfo_filename];

if(~exist(trialMatrix_filepath, 'file') && ~exist(sessionInfo_filepath, 'file'))
    % two customized subjects (4/5/2021)
    switch subject_string
        case 'subject_4'
            session = NaturalStraightening.createTrialMatrix_subject_4(subject_string);
        case 'corey_2'
            session = NaturalStraightening.createTrialMatrix_corey_2(subject_string);
        otherwise
            % new generic subject...
            session = NaturalStraightening.createTrialMatrix(subject_string);
    end
    
else
    % next block of trials will be automatically updated in
    % 'loadTrialMatrixToPLDAPS.m'
    load(sessionInfo_filepath, 'session');
    fprintf('Files (trial matrix & session info) for ''%s'' already exists. Starting experiment from where we left off. \n', subject_string);
    session.isOngoing       = true;
    session.endExperiment   = false;
    session.calibrate       = true;
    save(sessionInfo_filepath, 'session');
end

%% set up
Screen('Preference', 'SkipSyncTests', 1);


%% run experiment

% keep track of where I am in the trial matrix
trial_matrix_idx = nan;
while(~session.endExperiment)
    
    sca;
    
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
        goodbyeString = sprintf('You''ve already finished all of your trials, %s!',subject_string);
        DrawFormattedText(window_ptr, goodbyeString, 'center', 400, [0, 0, 0, 255]);
        Screen('Flip', window_ptr);
        WaitSecs(2);
        break;
        
    end
    
    % calibrate Eyelink (forces user to calibrate at the start of each 'day')
    if(session.calibrate)
        eyelinkCalibrate;
        %NaturalStraightening.customEyelinkCalibrate();
    end


    % run PLDAPS object or end session
    if(session.endExperiment)
        break;
    else
        
        % CRT gamma correction
        load('/Users/gorislab/Desktop/psychophysics/Calib/2018/humanRig20180612.mat')
        gammaStruct.display.forceLinearGamma    = true;
        gammaStruct.display.gamma.power         = gam.power;
        
        % make sure the CRT lookup table is precisely linear
        % ('plot(gammatable)' should give you a unity line)
        USE_PHYSICAL_DISPLAY = 1;
        [gammatable, dacbits, reallutsize] = Screen('ReadNormalizedGammaTable', max(Screen('Screens')), USE_PHYSICAL_DISPLAY);
        
        p = pldaps(@NaturalStraightening.setup, subject_string, gammaStruct);
        
        % lower bg intensity to prevent pixel clipping (in case this was
        % not set in 'createRigPref')
        p.trial.display.bgColor                 = [0.25, 0.25, 0.25];
        
        p.run;
    end
    
    %% REMEMBER!!!
    % for the real experiment, replace pilot settings to the real
    % experiment settings:
    % (1) CONSTANTS.m
    % (2) createTrialMatrix.m (lines 386, 398, 439, 479)
end