function p = loadTrialMatrixToPLDAPS(p, dataFolder)
% LOADTRIALMATRIXTOPLDAPS reads the experiment session information
% from two files: (1) sessionInfo.mat, and (2) +Fixation_(subject).mat. 
% (1) Session information is updated and save in 'sessionInfo.mat'. When 
%    the block is finished, this file will be updated again. 
% (2) Subject is identified from the session info, and the corresponding
%    experiment trial-matrix is imported. A certain number of trials for
%    this block is extracted and returned in a struct, trialMatrix. 
%    'trialMatrix' contains all of the variables and parameters for
%    this task.
%
% After loading the two MAT files, this function passes on all 
% task-relevant variables and parameters to PLDAPS, under the the 
% struct field 'p.trial', where users are allowed to put custom fields. 
% To translate fields from 'trialMatrix' to PLDAPS in a seamless 
% manner, we have assigned fields in 'createTrialMatrix.m' under our 
% pre-defined modular name, 'modName'. This function assumes you have 
% followed the convention of putting all of your task-related fields under
% 'modName'.
%
% The task for this function is to assign your trial matrix to PLDAPS by
% assiging a cell array to 'p.condition'. 
%
% 2017-11-20  YB   wrote it. <yoonbai@utexas.edu>
%

% currentPath         = taskFolder;
% sessionInfoFolder   = dataFolder;
%cd(sessionInfoFolder);

%subject             = session.subject;
% if(~session.isOngoing)
%     
%     if(p.trial.eyelink.use)
%         eyelinkCalibrate();
%     end
% end

% For practical purposes we'll keep this to false in case of crashes.
% isOngoing will only be true when at the end of the block the observer decides to:
% 1. continue to next block
% 2. continue to eye calibration
% session.isOngoing       = false;
% session.endExperiment   = false;
% save('sessionInfo.mat', 'session');
% 

sessionFilePath             = fullfile(dataFolder, 'sessionInfo.mat');
load(sessionFilePath, 'session');

% Load master trial matrix
%'S' is the struct that contains the trial matrix 
load(session.trialMatrixFile, 'S'); 
trial_results               = S.trialMatrix(:, S.trialMatrix_index.RESPONSE);


% discard previous session's trial matrix & update session trial matrix
assert(strcmp(sessionFilePath, session.sessionFilePath), ...
    sprintf('\n LOADED WRONG SESSION INFO FILE! \n'));

unvisited_trial_index       = find(isnan(trial_results));
if(~isempty(unvisited_trial_index))
    session_trial_index         = unvisited_trial_index(1) : unvisited_trial_index(1) + NaturalStraightening.CONSTANTS.NUM_TRIALS_PER_BLOCK - 1;
    session.sessionTrialMatrix  = S.trialMatrix(session_trial_index,:);
    session.sessionTrials       = session_trial_index;
    session.sessionTrialIndex   = 1;
    session.isOngoing           = false;
    session.endExperiment       = false;
else
    
    session.sessionTrialMatrix  = nan;
    session.sessionTrials       = nan;
    session.isOngoing           = false;
    session.endExperiment       = false;
    session.isFinalBlock        = true;
end
save(sessionFilePath, 'session');

% sanity checks (single movie category/name/stimulus size for each block)
session_movie_type  = unique(session.sessionTrialMatrix(:,session.sessionTrialMatrix_fields.MOVIE_TYPE));
assert(length(session_movie_type) == 1, sprintf('\n ERROR: MORE THAN ONE MOVIE TYPE FOR THIS BLOCK!\n'));
session_movie_index = unique(session.sessionTrialMatrix(:,session.sessionTrialMatrix_fields.MOVIE_NUM));
assert(length(session_movie_index) == 1, sprintf('\n ERROR: MORE THAN ONE MOVIE FOR THIS BLOCK!\n'));
stim_size_index     = unique(session.sessionTrialMatrix(:,session.sessionTrialMatrix_fields.STIM_SIZE));
assert(length(stim_size_index) == 1, sprintf('\n ERROR: MORE THAN ONE STIM_SIZE FOR THIS BLOCK!\n'));

% assign module name
modName             = S.modName;
if(~isfield(p.trial, 'modName'))
    p.trial.modName = modName; % save string for struct field
end

% assign parameters under the struct field name
p.trial.(modName)                   = S.(modName);


% iterate thru this session's trial matrix 
numSessionTrials        = size(session.sessionTrialMatrix,1);
fieldStrings            = fieldnames(S.trialMatrix_index);
structArray             = cell(numSessionTrials, 1);
for i = 1:numSessionTrials
    
    iStruct         = struct;
    for j = 1:length(fieldStrings)
        iStruct.(modName).(fieldStrings{j}) = session.sessionTrialMatrix(i,j);
    end
    structArray{i} = iStruct;
end
p.conditions                        = structArray;

% pass this onto PLDAPS
p.trial.DATA_FOLDER                 = dataFolder;
p.trial.TRIAL_MATRIX_FILEPATH       = session.trialMatrixFile;
p.trial.SESSION_INFO_FILEPATH       = sessionFilePath;
p.trial.sessionTrialMatrix          = session.sessionTrialMatrix;


p.trial.sessionTrialMatrix_fields    = session.sessionTrialMatrix_fields;
p.defaultParameters.pldaps.finish   = length(p.conditions);

% start from first trial of the block. If the block was not finished, 
% restart from trial 1. 
p.trial.(modName).sessionTrialIndex  = session.sessionTrialIndex;


 