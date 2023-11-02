function session = createTrialMatrix_subject_3(initials, varargin)
% createTrialMatrix defines variables & parameters in constructing the task
% and provides a trial matrix that can be run across multiple sessions for
% a single subject. Trial matrix and session information are saved in the
% './Data' folder.
% 
% -------COMPONENTS--------- 
% * Full list of parameters under 'S.(S.modName)'
%   - each category is specified under a subfield:
%       ex) S.fixation.stimulus, S.fixation.response
%
% * Trial matrix:
%   - matrix of the entire experiment (trials x fields)
%   
% * Trial matrix description
%   - description of each field (column)
%
% 2017-11-16  YB   wrote it. <yoonbai@utexas.edu>
%
% 2018-09-05  SMS  repurposed it for psychophysical straightening study. <smshields@utexas.edu>
% 

%% Initiate S, a structure that summarizes all variables and will be filled 
% with registered responses
S                   = struct;

%% Hardcoded stuff
%-------------------------------------------------------------------------%
% Specify module for this experiment
S.toolbox           = '+NaturalStraightening';

% Define modular name, a custom field name that puts all of our variables  
% under the field for custom variables, 'p.trial'
% * IMPORTANT: We will transfer all of our variables under 'S.modName' to
%              PLDAPS. Therefore, variables that will be used with PLDAPS 
%              are defined here. 
%S.modName           = lower(erase(S.toolbox,'+'));
S.modName           = lower(S.toolbox(2:end)); % using a hack, since 'erase()' is only available from 2017a and up

% Experiment description for future generations
S.comment           = strvcat({...
    'AXB task for natural image sequences',
    'add comments... ',
    '...'
    });

%% Input parser
%-------------------------------------------------------------------------%
% Required input    : subject initials
% Optional inputs   : 'windowSize', 'movie', 'numRepetitions'
% Save subject initials
S.subject                   = initials;

parser                      = inputParser;

default_stim_center_x       = 0;
default_stim_center_y       = 0;

% defaultColor = 'RGB';
% validColors = {'RGB','CMYK'};
% checkColor = @(x) any(validatestring(x,validColors));
parser.addRequired('initials', @ischar);
parser.addParameter('stim_center_x',        default_stim_center_x,       @isnumeric);
parser.addParameter('stim_center_y',        default_stim_center_y,       @isnumeric);

parse(parser,initials,varargin{:})


% Trial constants
%-------------------------------------------------------------------------%
% ITI
S.(S.modName).ITI                   = 0.1;


% % Current trial index (w.r.t. the trial matrix)
% %-------------------------------------------------------------------------%
% S.(S.modName).trialMatrixIndex      = 1;


% State-related variables
%-------------------------------------------------------------------------%
states                              = struct;
slowDownFactor                      = NaturalStraightening.CONSTANTS.SLOW_DOWN_FACTOR; %  slow down for debugging 


% Define task states
i = 0;
states.START                        =  i;    i = i + 1;
states.FP_ON                        =  i;    i = i + 1;
states.FP_HOLD                      =  i;    i = i + 1;
states.A_ON                         =  i;    i = i + 1;
states.A_OFF                        =  i;    i = i + 1;
states.X_ON                         =  i;    i = i + 1;
states.X_OFF                        =  i;    i = i + 1;
states.B_ON                         =  i;    i = i + 1;
states.B_OFF                        =  i;    i = i + 1;
states.REPORT                       =  i;    i = i + 1;
states.TRIAL_COMPLETE               =  i;    
states.BREAK_FIX                    = -1;

% State durations (in units of seconds)
states.duration.START               = 0.1; % allocate time for audible cue
states.duration.FP_ON               = 0.1; % 0.5
states.duration.FP_HOLD             = 0.2; % 0.25 
states.duration.A_ON                = 0.2;
states.duration.A_OFF               = 0.5;
states.duration.X_ON                = 0.2;
states.duration.X_OFF               = 0.5;
states.duration.B_ON                = 0.2;
states.duration.B_OFF               = 0.1;
states.duration.REPORT_MAX          = 3;
states.duration.TRIAL_COMPLETE      = 0.1;

% timestamps: when did the subject reach each state?
states.timestamps.START             = nan;
states.timestamps.FP_ON             = nan;
states.timestamps.FP_HOLD           = nan;
states.timestamps.A_ON              = nan;
states.timestamps.A_OFF             = nan;
states.timestamps.X_ON              = nan;
states.timestamps.X_OFF             = nan;
states.timestamps.B_ON              = nan;
states.timestamps.B_OFF             = nan;
states.timestamps.REPORT            = nan;
states.timestamps.KEY_PRESS         = nan;
states.timestamps.TRIAL_COMPLETE    = nan;

% Variables to track subject's state within a single trial
states.current_state                = states.START;
states.previous_state               = nan;
states.current_img_index            = 1;

% Maximum duration for FP_ON, across all states
states.duration.MAX_FP_ON_DURATION  = 5; % seconds

% slowDownFactor
durationFields = fieldnames(states.duration);
for i = 1:length(durationFields)
    states.duration.(durationFields{i}) = states.duration.(durationFields{i}) * slowDownFactor;
end

% put state-related parameters in the main struct, S
S.(S.modName).states                = states;           



%% Stimulus-related variables
%-------------------------------------------------------------------------%
% Constants within a block         : FP size, shape, color, duration
% Varying parameters within block  : FP location

stimulus                            = struct;

% Fixation Point ---------------------
% FP shapes
stimulus.fp.shape.CIRCLE                = 1;
stimulus.fp.shape.SQUARE                = 0;
stimulus.fp.shape.current               = stimulus.fp.shape.CIRCLE;

% FP location(s)
stimulus.fp.location.X_DEG              = parser.Results.stim_center_x;
stimulus.fp.location.Y_DEG              = parser.Results.stim_center_y;

% FP diameter in visual degrees
stimulus.fp.size.DIAMETER_DEG           = 0.2; %[1, 5, 10];
stimulus.fp.size.PRE_STIM_DIAMETER_DEG  = 0.2; %[1, 5, 10];

stimulus.fp.size.curr_diameter_deg      = stimulus.fp.size.PRE_STIM_DIAMETER_DEG; %[1, 5, 10];



% FP color (index for monkey CLUT)
% Monkey CLUT indices are: WHITE: 8, RED:7, BLUE: 11, GREEN: 12, BLACK: 10
stimulus.fp.color.COLOR_INDEX           = 8; %[8, 7, 12, 10];  

% % FP presentation duration in seconds
% stimulus.fp.duration.DURATION_SEC      = 0.25; %[0.25, 0.5, 1];

% Image stimulus ---------------------
% stimulus.image.on_duration_sec          = 0.2; % seconds
% stimulus.image.off_duration_sec         = 0.1; % seconds
%stimulus.image.index_list               = 1:S.(S.modName).TOTAL_NUM_IMAGES; % TODO: need to keep track of presented images 
%stimulus.image.size.DIAMETER_DEG        = nan; % this will be determined by each block
stimulus.image.location.X_DEG           = parser.Results.stim_center_x;
stimulus.image.location.Y_DEG           = parser.Results.stim_center_y;
stimulus.image.pixelBitDepth            = 8; % 8 bits

% Vignette (need to resize when generating actual image stimulus)
%flattop8                                = im2double(imread('Flattop8.tif'));
%flattop8                                = squeeze(flattop8(:,:,end));
%stimulus.image.vinette                  = flattop8;

S.(S.modName).stimulus                  = stimulus;



% Gaze
%-------------------------------------------------------------------------%
gaze                                = struct;

% fixation boundary 
gaze.RADIUS_DEG                     = NaturalStraightening.CONSTANTS.WINDOW_SIZE; % fixation window size
gaze.PRE_STIM_RADIUS_DEG            = NaturalStraightening.CONSTANTS.PRE_STIM_RADIUS_DEG;

% current gaze window radius (this changes thoughout the task)
gaze.curr_window_radius_deg         = gaze.PRE_STIM_RADIUS_DEG;

% custom eye calibration
gaze.gain_step_size                 = 0.1;
gaze.offset_step_size               = 0.1;
gaze.x_gain                         = 1; % arbitrary units
gaze.x_offset                       = 0; % in visual degrees
gaze.y_gain                         = 1;
gaze.y_offset                       = 0;

% eye tracing (history)
gaze.trace_dot_width                = 5; % size of dots for tracing
gaze.trace_history_sec              = 0.5;% length of tracing history, in seconds

S.(S.modName).gaze                  = gaze;



% Response
%-------------------------------------------------------------------------%
response                            = struct;

% possible responses for this task
response.X_MATCHES_A                = NaturalStraightening.CONSTANTS.RESPONSE_X_MATCHES_A;
response.X_MATCHES_B                = NaturalStraightening.CONSTANTS.RESPONSE_X_MATCHES_B;
response.NO_RESPONSE                = NaturalStraightening.CONSTANTS.RESPONSE_NO_RESPONSE;
response.BREAK_FIX                  = NaturalStraightening.CONSTANTS.RESPONSE_BREAK_FIX;
response.NO_ENGAGEMENT              = NaturalStraightening.CONSTANTS.RESPONSE_NO_ENGAGEMENT;

% placeholder for subject's response
response.subjectResponse            = NaN;

S.(S.modName).response              = response;



% Outcome
%-------------------------------------------------------------------------%
outcome                             = struct;

% possible outcomes for this task
outcome.SUCCESS                     = NaturalStraightening.CONSTANTS.OUTCOME_SUCCESS;
outcome.FAILURE                     = NaturalStraightening.CONSTANTS.OUTCOME_FAILURE;
outcome.BREAK_FIX                   = NaturalStraightening.CONSTANTS.OUTCOME_BREAK_FIX;
outcome.NO_RESPONSE                 = NaturalStraightening.CONSTANTS.OUTCOME_NO_RESPONSE;

% placeholder for trial outcome
outcome.trialOutcome                = NaN;

S.(S.modName).outcome               = outcome;



% Audible feedback (PLDAPS expects a particular value for each sound. to be continued...)
%-------------------------------------------------------------------------%
sound                               = struct;
sound.CUE                           = 1;
sound.SUCCESS                       = 2;
sound.FAILURE                       = 3;
sound.BREAK_FIX                     = 7;
S.(S.modName).sound                 = sound;



%% TRIAL MATRIX

% Trial matrix index for each field (column)
%-------------------------------------------------------------------------%
index_num = 1;
S.trialMatrix_index.MOVIE_TYPE      = index_num; index_num = index_num + 1;
S.trialMatrix_index.MOVIE_NUM       = index_num; index_num = index_num + 1;
S.trialMatrix_index.STIM_SIZE       = index_num; index_num = index_num + 1;
S.trialMatrix_index.A_FRAMES        = index_num; index_num = index_num + 1;
S.trialMatrix_index.X_FRAMES        = index_num; index_num = index_num + 1;
S.trialMatrix_index.B_FRAMES        = index_num; index_num = index_num + 1;
S.trialMatrix_index.FEEDBACK        = index_num; index_num = index_num + 1;
S.trialMatrix_index.RESPONSE        = index_num; %index_num = index_num + 1;



% Trial matrix descriptions for each field (column)
%-------------------------------------------------------------------------%
S.trialmatrix_description{S.trialMatrix_index.MOVIE_TYPE}   = ...
    sprintf('column %s, Type of movie used for trial stimuli (0: natural, 1: synthetic)', ...
        num2str(S.trialMatrix_index.MOVIE_TYPE));

S.trialmatrix_description{S.trialMatrix_index.MOVIE_NUM}   = ...
    sprintf('column %s, Number of the movie used for trial stimuli', ...
        num2str(S.trialMatrix_index.MOVIE_NUM));
    
S.trialmatrix_description{S.trialMatrix_index.STIM_SIZE}   = ...
    sprintf('column %s, Size of trial stimuli', ...
        num2str(S.trialMatrix_index.STIM_SIZE));

S.trialmatrix_description{S.trialMatrix_index.A_FRAMES}    = ...
    sprintf('column %s, Frame used as A stimulus', ...
        num2str(S.trialMatrix_index.A_FRAMES));
    
S.trialmatrix_description{S.trialMatrix_index.X_FRAMES}    = ...
    sprintf('column %s, Frame used as X stimulus', ...
        num2str(S.trialMatrix_index.X_FRAMES));

S.trialmatrix_description{S.trialMatrix_index.B_FRAMES}    = ...
    sprintf('column %s, Frame used as B stimulus', ...
        num2str(S.trialMatrix_index.B_FRAMES));
    
S.trialmatrix_description{S.trialMatrix_index.FEEDBACK} = ...
    sprintf('column %s, feedback received by observer (%s)', ...
        num2str(S.trialMatrix_index.FEEDBACK), ...
        '0: FAILURE/INCORRECT, 1: SUCCESS/CORRECT, -1: BREAK FIXATION, -2: NO_RESPONSE, NaN: no feedback');

% Let's use NaN to indicate that this trial was not visited 
S.trialmatrix_description{S.trialMatrix_index.RESPONSE}        = ...
    sprintf('column %s, observer response (0: A, 1: B, -1: BREAK FIXATION, -2: NO_RESPONSE)', ...
        num2str(S.trialMatrix_index.RESPONSE));
    

% Trial matrix dimensions
%-------------------------------------------------------------------------%
numMoviesPerType    = length(NaturalStraightening.CONSTANTS.STIMULUS_MOVIES);
numMovieTypes       = NaturalStraightening.CONSTANTS.NUM_MOVIE_TYPES; % current: natural, synthetic
numMovies           = numMoviesPerType * numMovieTypes;
numFramesPerMovie   = length(NaturalStraightening.CONSTANTS.FRAME_INDEX_PER_MOVIE);

% create matrix with all possible A/B frame number permutations
combinations = nchoosek(1:numFramesPerMovie,2);         % order doesn't matter - C(n,k)=n!?(k!(n?k)!)
permutations = [combinations; combinations(:,[2,1])];   % order does matter - P(n,k)=n!?(n?k)!
numPerm = size(permutations,1);                         % store number of permutations

numRepetitions      = NaturalStraightening.CONSTANTS.NUM_REPETITIONS;
numTrialsPerBlock   = NaturalStraightening.CONSTANTS.NUM_TRIALS_PER_BLOCK;
numBlocksPerMovie   = fix((numPerm * numRepetitions)/numTrialsPerBlock);
numTrialsPerMovie   = numTrialsPerBlock * numBlocksPerMovie;
numBlocks           = numBlocksPerMovie * numMovies;
numTrials           = numBlocks * numTrialsPerBlock;

trainingNumTrials   = NaturalStraightening.CONSTANTS.NUM_TRAINING_TRIALS;
trainingNumBlocks   = trainingNumTrials / numTrialsPerBlock;

% define size of trial matrix -- PLDAPS will need this information
S.blockSize     = numTrials + trainingNumTrials;     % number of trials the collection of blocks (N)


% Define stimulus properties
%-------------------------------------------------------------------------%

% image annulus dimensions (sizes: 1='Fovea',  2='Repica',  3='Periphery')
imgOuterDiameters   = NaturalStraightening.CONSTANTS.IMG_OUTER_DIAMETERS_DEG;
imgInnerDiameters   = NaturalStraightening.CONSTANTS.IMG_INNER_DIAMETERS_DEG;
numMoviesPerSize    = NaturalStraightening.CONSTANTS.NUM_MOVIES_PER_SIZE;
numSizes            = size(numMoviesPerSize,2);
numSizeReps         = sort(numMoviesPerSize);   % sort for later calculations

% movie identification numbers
naturalIDs          = NaturalStraightening.CONSTANTS.STIMULUS_MOVIES;                   % type 0
syntheticIDs        = naturalIDs * NaturalStraightening.CONSTANTS.INDEX_DIFFERENCE;     % type 1
movieIDs            = [naturalIDs syntheticIDs];

trainingNatIDs      = NaturalStraightening.CONSTANTS.TRAINING_MOVIES;
trainingSynthIDs    = trainingNatIDs * NaturalStraightening.CONSTANTS.INDEX_DIFFERENCE;


% Create pseudorandomly ordered array of movies and respective stimulus sizes
%-------------------------------------------------------------------------%
% output: moviesAndSizes - cell array with cells containing randomly ordered
% movie-size pairs (array columns: 1=movie type, 2=movie num, 3=stimulus size)

% steps:
% 1) randomly order movies
% 2) assign sizes to movies in a pseudorandom manner
% 3) pseudorandomly merge natural and sythetic movie-size pairs

% NOTE: written specifically for using natural and synthetic movies


%%% randomly order movies
% real experiment
%movieOrder          = randperm(numMoviesPerType);
naturalMovies       = [6,5,4];%naturalIDs(movieOrder)';
syntheticMovies     = [50,60,40];%syntheticIDs(movieOrder)';

natSizes            = [1,2,3];
synSizes            = [1,2,3];
%%% pseudorandomly assign sizes to movies
% assign in groups, ensuring that each participant will view each size at
% least once if they view just three movies
natMoviesAndSizes = cell(max(numMoviesPerSize));    % initialize
synthMoviesAndSizes = cell(max(numMoviesPerSize));
groupNum = 1; movI = 1;

% check the SMALLEST number of repetitions per size
for i=1:numSizeReps(1) % for the smallest number of size repetitions...
    % real experiment
    natMoviesAndSizes{groupNum}(1:numSizes,1) = 0;                                          % ...add movie type
    natMoviesAndSizes{groupNum}(1:numSizes,2) = naturalMovies(movI:movI+numSizes-1);        % ...add movie number
    natMoviesAndSizes{groupNum}(1:numSizes,3) = natSizes';                        % ...add size
    
    synthMoviesAndSizes{groupNum}(1:numSizes,1) = 1;                                        % ...add movie type
    synthMoviesAndSizes{groupNum}(1:numSizes,2) = syntheticMovies(movI:movI+numSizes-1);    % ...add movie number
    synthMoviesAndSizes{groupNum}(1:numSizes,3) = synSizes';                      % ...add size
    
    groupNum = groupNum + 1; movI = movI + numSizes;    % update counters
end
groupTypesHere = [zeros(1,numSizeReps(1)), ones(1,numSizeReps(1))];     % collect number of nat and synthetic block groups defined in this loop
groupTypes = groupTypesHere(randperm(size(groupTypesHere,2)));          % randomize order of group type and add it to array
clear i groupTypesHere      % clean up workspace

% check the MEDIUM number of repetitions per size
if numSizeReps(2)>numSizeReps(1)                        % if numSizeReps are not equal...
    nSzRepsLeft = numMoviesPerSize - numSizeReps(1);    % ...calculate remaining repetitions per size
    nRepsHere = numSizeReps(2) - numSizeReps(1);        % ...calculate num rep's to do now
    sizesToRep = find(nSzRepsLeft)';                    % ...find which sizes need to be repeated
    nSzToRep = size(sizesToRep,1);                      % ...store number of sizes that need to be repeated
    for i=1:nRepsHere                                   % ...randomize sizes to be repeated and assign to movies...
        % real experiment
        natMoviesAndSizes{groupNum}(1:nSzToRep,1) = 0;                                          % ...add movie type
        natMoviesAndSizes{groupNum}(1:nSzToRep,2) = naturalMovies(movI:movI+nSzToRep-1);        % ...add movie number
        natMoviesAndSizes{groupNum}(1:nSzToRep,3) = sizesToRep(randperm(nSzToRep));             % ...add size
        
        synthMoviesAndSizes{groupNum}(1:nSzToRep,1) = 1;                                        % ...add movie type
        synthMoviesAndSizes{groupNum}(1:nSzToRep,2) = syntheticMovies(movI:movI+nSzToRep-1);    % ...add movie number
        synthMoviesAndSizes{groupNum}(1:nSzToRep,3) = sizesToRep(randperm(nSzToRep));           % ...add size
        
        groupNum = groupNum + 1; movI = movI + nSzToRep;    % update counter
    end
    groupTypesHere = [zeros(1,nRepsHere), ones(1,nRepsHere)];                       % collect number of nat and synthetic block groups defined in this loop
    groupTypes = [groupTypes, groupTypesHere(randperm(size(groupTypesHere,2)))];    % randomize order of group type and add it to existing array of group types
    clear i nSzRepsLeft nRepsHere sizesToRep nSzToRep groupTypesHere    % clean up workspace
end

% check the LARGEST number of repetitions per size
if numSizeReps(3)>numSizeReps(2)                    % if there are still size repeats to be included...
    nSzRepsLeft = numMoviesPerSize - numSizeReps(1) - numSizeReps(2);   % ...calculate remaining repetitions per size
    nRepsHere = numSizeReps(3) - numSizeReps(2);        % ...calculate num rep's to do now
    sizesToRep = find(nSzRepsLeft)';                    % ...find which sizes need to be repeated
    nSzToRep = size(sizesToRep,1);                      % ...store number of sizes that need to be repeated
    for i=1:nRepsHere                                   % ...randomize sizes to be repeated and assign to movies...
        natMoviesAndSizes{groupNum}(1:nSzToRep,1) = 0;                                          % ...add movie type
        natMoviesAndSizes{groupNum}(1:nSzToRep,2) = naturalMovies(movI:movI+nSzToRep-1);        % ...add movie number
        natMoviesAndSizes{groupNum}(1:nSzToRep,3) = sizesToRep(randperm(nSzToRep));             % ...add size
        
        synthMoviesAndSizes{groupNum}(1:nSzToRep,1) = 1;                                        % ...add movie type
        synthMoviesAndSizes{groupNum}(1:nSzToRep,2) = syntheticMovies(movI:movI+nSzToRep-1);    % ...add movie number
        synthMoviesAndSizes{groupNum}(1:nSzToRep,3) = sizesToRep(randperm(nSzToRep));           % ...add size
        
        groupNum = groupNum + 1; movI = movI + nSzToRep;    % update counter
    end
    groupTypesHere = [zeros(1,nRepsHere), ones(1,nRepsHere)];                       % collect number of nat and synthetic block groups defined in this loop
    groupTypes = [groupTypes, groupTypesHere(randperm(size(groupTypesHere,2)))];    % randomize order of group type and add it to existing array of group types
    clear i nSzRepsLeft nRepsHere sizesToRep nSzToRep groupTypesHere    % clean up workspace
end


%% randomly interweave groups of natural and synthetic movies
% real experiment
moviesAndSizes = cell(groupNum,1);   % initialize combined array
natCounter = 1; synthCounter = 1;    % initialize counters
for i = 1:size(groupTypes,2)                            % for each group...
    if ~groupTypes(i)                                       % ...if type is natural...
        moviesAndSizes(i) = natMoviesAndSizes(natCounter);      % ...add next nat movie-size pair to array
        natCounter = natCounter + 1;                            % ...update counter
    else                                                    % ...if type is synthetic...
        moviesAndSizes(i) = synthMoviesAndSizes(synthCounter);  % ...add next synth movie-size pair to array
        synthCounter = synthCounter + 1;                        % ...update counter
    end
end
clear i



% Create lists of permutations with repetitions
%-------------------------------------------------------------------------%
% create randomized lists of permutations for each movie
frames = cell(numMovies,1);     % initialize cell array for storage of A/B frame numbers for all movies
for mov=1:numMovies
    % for each repetition of each movie, randomize permutation order
    frameArray = [];            % initialize array for frame numbers
    for rep=1:numRepetitions
        % randomize order of frame number combinations
        randomMask = randperm(numPerm)';                        % create random mask
        randomPermutations = permutations(randomMask,:);        % apply random mask
        
        % store frame numbers in separate arrays
        frameArray = [frameArray; randomPermutations(:,:)];
        clear randomMask randomPermutations     % clean up workspace
    end
    frames{mov} = frameArray;   % store the randomized frame order for this movie
    clear rep                                   % clean up workspace
end
clear mov


% Repeat blocks in block groups and randomize block order
%-------------------------------------------------------------------------%
blockParameters = nan(numBlocks,3);     % initialize array for storage of block info
startI = 1;                             % initialize counter
for i = 1:size(moviesAndSizes,1)                                            % for all groups of blocks...
    blockOrder = repmat(moviesAndSizes{i}(:,1:3),numBlocksPerMovie,1);      % ...repeat block types appropriate number of times
    randomMask = randperm(size(blockOrder,1))';                             % ...create random mask
    blockOrder = blockOrder(randomMask,:);                                  % ...apply random mask
    blockParameters(startI:startI+size(blockOrder,1)-1,1:3) = blockOrder;   % ...add to array
    startI = startI+size(blockOrder,1);                                     % ...update counter
    clear i blockOrder                                                      % ...clean up workspace
end
clear startI


% Allot trials from frame arrays to randomly ordered blocks
%-------------------------------------------------------------------------%
exptFrameInfo = nan(numTrials,5); % initialize array for storage of all A/B frame info
% (columns: 1=movie type, 2=movie num, 3=stim size, 4=A frames, 5=B frames)
framesBackup = frames;  % temporarily store backup in case of an error

for i = 1:size(blockParameters,1) % for each pre-defined block...
    % ...for all trials in block, input block parameters into frame info array
    exptFrameInfo((i-1)*numTrialsPerBlock+1:i*numTrialsPerBlock,1:3) = repmat(blockParameters(i,:),numTrialsPerBlock,1);
    % ...add pre-randomized frames into block
    exptFrameInfo((i-1)*numTrialsPerBlock+1:i*numTrialsPerBlock,4:5) = frames{movieIDs==blockParameters(i,2)}(1:numTrialsPerBlock,1:2);
    % ...eliminate added frames from array of pre-randomized frames
    frames{movieIDs==blockParameters(i,2)}(1:numTrialsPerBlock,:) = [];
end
clear i naturalMovies syntheticMovies movI natCounter synthCounter...    % clean up workspace
    natMoviesAndSizes synthMoviesAndSizes combinations frames framesBackup


% Set up training trials
%-------------------------------------------------------------------------%
% ALL PREVIOUS RANDOMIZATION CODE FOR ACTUAL EXPT
% ONLY ~NOW~ DETERMINING PARAMETERS FOR TRAINING TRIALS
% reminder - array columns: 1=movie type, 2=movie num, 3=stimulus size
trainingBlockParameters = ...
    [0, trainingNatIDs(1),   1; ...
     0, trainingNatIDs(2),   2; ...
     0, trainingNatIDs(3),   3; ...
     0, trainingNatIDs(1),   1; ...
     1, trainingSynthIDs(1), 2; ...
     1, trainingSynthIDs(2), 3; ...
     1, trainingSynthIDs(3), 1; ...
     0, trainingNatIDs(1),   1; ...
     0, trainingNatIDs(2),   2; ...
     0, trainingNatIDs(3),   3; ...
     1, trainingSynthIDs(1), 1; ...
     1, trainingSynthIDs(2), 2; ...
     1, trainingSynthIDs(3), 3; ...
     1, trainingSynthIDs(1), 1 ];


numRepMat = fix(trainingNumTrials/numPerm) + 1;
trainingFrameOptions = repmat(permutations,numRepMat,1); clear numRepMat;
trainingFrames = trainingFrameOptions(randperm(trainingNumTrials),:);

trainingFrameInfo = nan(trainingNumTrials,5); % initialize array for storage of all A/B frame info
% (columns: 1=movie type, 2=movie num, 3=stim size, 4=A frames, 5=B frames)
for i = 1:trainingNumBlocks % for each block needed to reach defined number of trials...
    % ...for all trials in block, input block parameters into frame info array
    trainingFrameInfo((i-1)*numTrialsPerBlock+1:i*numTrialsPerBlock,1:3) = repmat(trainingBlockParameters(i,:),numTrialsPerBlock,1);
end
trainingFrameInfo(:,4:5) = trainingFrames;

allFrameInfo = [trainingFrameInfo; exptFrameInfo];


% Determine X frames
%-------------------------------------------------------------------------%
% randomize whether X will match A or B (0: A; 1: B)
xMatch = [zeros((S.blockSize/2),1); ones((S.blockSize/2),1)];   % create an array that is half 0 and half 1
xMatch = xMatch(randperm(S.blockSize));                         % create and apply random mask

% create X frame list
xFrames = nan(S.blockSize,1);
for i=1:S.blockSize
    if ~xMatch(i) % if match value is 0, make X match A
        xFrames(i,1) = allFrameInfo(i,4);
    elseif xMatch(i)==1 % if match value is 1, make X match B
        xFrames(i,1) = allFrameInfo(i,5);
    else
        fprintf('Error in row %u\n', i)
    end
end
clear i


% Trial matrix  
%-------------------------------------------------------------------------%
% assign conditions values to a temporary matrix
tempMat                                         = NaN(S.blockSize, index_num);

tempMat(:,S.trialMatrix_index.MOVIE_TYPE)       = allFrameInfo(:,1);
tempMat(:,S.trialMatrix_index.MOVIE_NUM)        = allFrameInfo(:,2);

tempMat(:,S.trialMatrix_index.STIM_SIZE)        = allFrameInfo(:,3);

tempMat(:,S.trialMatrix_index.A_FRAMES)         = allFrameInfo(:,4);
tempMat(:,S.trialMatrix_index.X_FRAMES)         = xFrames;
tempMat(:,S.trialMatrix_index.B_FRAMES)         = allFrameInfo(:,5);

tempMat(:,S.trialMatrix_index.FEEDBACK)         = NaN;
tempMat(:,S.trialMatrix_index.RESPONSE)         = NaN;

% transfer temporary matrix to trial matrix variable
S.trialMatrix                                   = tempMat;


%% Export values for later use
% S.(S.modName) will be exported to p.trial.(modName) via loadTrialMatrixToPLDAPS.m

%%% calculate the last block number in each group of blocks
% will be used to help subjects track their progress
exptGroupEnds = nan(size(moviesAndSizes,1),1); endPoint = 0; % initialize
for i=1:size(moviesAndSizes,1)
    endPoint = endPoint + (size(moviesAndSizes{i},1) * numBlocksPerMovie);
    exptGroupEnds(i) = endPoint;
end; clear i
groupEnds = [trainingNumBlocks; exptGroupEnds + trainingNumBlocks];
S.(S.modName).matrixConstants.exptGroupEnds = exptGroupEnds;
S.(S.modName).matrixConstants.groupEnds = groupEnds;


%%% subject-specific parameters
S.(S.modName).matrixInfo.subjectID          = initials;
S.(S.modName).matrixInfo.groupTypes         = groupTypes;
S.(S.modName).matrixInfo.moviesAndSizes     = moviesAndSizes;
S.(S.modName).matrixInfo.blockParameters    = blockParameters;


%%% calculated constants to be saved for later reference
% general constants
S.(S.modName).matrixConstants.numSizes = numSizes;
S.(S.modName).matrixConstants.permutations = permutations;

% constants for actual experimental stimuli
S.(S.modName).matrixConstants.expt.numBlocksPerMovie = numBlocksPerMovie;
S.(S.modName).matrixConstants.expt.numTrialsPerMovie = numTrialsPerMovie;
S.(S.modName).matrixConstants.expt.numBlocks = numBlocks;

% training constants
S.(S.modName).matrixConstants.training.numTrials = trainingNumTrials;
S.(S.modName).matrixConstants.training.numBlocks = trainingNumBlocks;
S.(S.modName).matrixConstants.training.blockParameters = trainingBlockParameters;


%% Save out files that contain the trial matrix and session info
%-------------------------------------------------------------------------%
%folder      = ['./data/', datestr(now, 'mm-dd-yyyy'), '/'];
folder      = [NaturalStraightening.CONSTANTS.ROOT_FOLDER, 'data/', S.subject, '/'];
mkdir(folder);

% check if files for (1) trial matrix and (2) session info already exists. 
% Warn user if this is the case. 
trialMatrix_filename    = sprintf('%s_%s.mat', S.toolbox(2:end), initials);
trialMatrix_filepath    = [folder, trialMatrix_filename];

sessionInfo_filename    = 'sessionInfo.mat';
sessionInfo_filepath    = [folder, sessionInfo_filename];

if(~exist(trialMatrix_filepath, 'file') && ~exist(sessionInfo_filepath, 'file'))
    
    % New subject 
    save(trialMatrix_filepath, 'S');
    fprintf('New data matrix was created for ''%s'' \n', initials);
    
    %%%% maks new sessionInfo file
    session                             = struct;
    session.subject                     = initials;
    
    % location of trial matrix
    session.trialMatrixFile             = trialMatrix_filepath; 
    
    % location of session info
    session.sessionFilePath             = sessionInfo_filepath;
    
    % session trial matrix: keep a separate copy of trials for this session only. Once this session
    % is complete, copy this back to the original trial matrix
    session.sessionTrials               = 1:numTrialsPerBlock;  % first block from trial matrix
    session.sessionTrialMatrix          = S.trialMatrix(session.sessionTrials, :);
    session.sessionTrialMatrix_fields   = S.trialMatrix_index;
    
    % sessionTrialIndex: trial index for PLDAPS (incremented after each trial)
    session.sessionTrialIndex           = 1;
    
    % the following flags are used to determine whether to continue another
    % block. These are updated in 'trialFunction.m', at the end of a block
    % (swith-case p.trial.pldaps.trialStates.experimentCleanUp)
    session.isOngoing                   = false;
    session.endExperiment               = false;
    session.isFinalBlock                = false;
    session.calibrate                   = true;
    
    save(session.sessionFilePath, 'session');
    % maybe we should print contents of 'session'? just a thought
    
else
    % next block of trials will be automatically updated in
    % 'loadTrialMatrixToPLDAPS.m'
    load(sessionInfo_filepath, 'session');
    fprintf('Files (trial matrix & session info) for ''%s'' already exists. Starting experiment from where we left off. \n', initials);
    session.isOngoing       = true;
    session.endExperiment   = false;
end


