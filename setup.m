function p = setup(p)
% SETUP is the initial function called to run PLDAPS
%
% 2017-12-1  YB   wrote it. version 3.0 <yoonbai@utexas.edu>
%
% 2018-09-05  SMS  repurposed for psychophysical straightening study <smshields@utexas.edu>
%  

%DATA_FOLDER     = fullfile(TASK_FOLDER, 'Data', datestr(now, 'mm-dd-yyyy'));
DATA_FOLDER     = fullfile(NaturalStraightening.CONSTANTS.ROOT_FOLDER, 'data', p.trial.session.subject, '/');

if(isa(p, 'pldaps'))
    
    % Use PLDAPS' modular mode:
    % The 'runModularTrial' option needs be accompanied by
    p.trial.pldaps.useModularStateFunctions         = true;
    p.defaultParameters.pldaps.trialMasterFunction  = 'runModularTrial';
    
    % Trial function that will be called every frame
    p.defaultParameters.pldaps.trialFunction        = 'NaturalStraightening.trialFunction';
    
    % load trial matrix for this block
    p = NaturalStraightening.loadTrialMatrixToPLDAPS(p, DATA_FOLDER);
    
else
    
    error('Input parameter is not a PLDAPS object!\n');
    
end