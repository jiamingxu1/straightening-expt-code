function [subjectList, dataTracking, trialMatrices] = trackData
% TRACKDATA loads the matrix information and detailed trial matrices for
% each subject, summarizes responses and outcomes, and for each movie-size
% pair, counts how many subjects have completed trials with the pair and
% how many they have completed.
%
% Function will output the list of subject IDs, information for keeping
% track of what data is being collected, and each subject's trial matrix,
% limited to completed experimental trials only.
%
% 2018-10-24  SMS  wrote it. <smshields@utexas.edu>

%% get list of subjects
inDataFolder = dir('./Data/');
dataSubFolders = inDataFolder([inDataFolder.isdir]);
subjectList = {dataSubFolders(3:end).name};
subjectList(strncmpi(subjectList,'PLDAPS',6)) = []; % remove PLDAPS folder from list
subjectList(strncmpi(subjectList,'test',4)) = [];   % remove test folder from list

%% load data, perform computations, and export trial matrices and matrix info
for s=1:size(subjectList,1)
    folder = ['./Data/', subjectList{s}, '/'];
    
    % load and store subject trial matrix information
    load([folder, 'matrixInfo_', subjectList{s}, '.mat']);
    dataTracking.(subjectList{s}) = matrixInfo;
    if s==1  % only load matrix constants once
        load([folder, 'matrixConstants_', subjectList{s}, '.mat']);
    end
    
    % load and store subject trial matrix (only with *completed* *expt* trials)
    load([folder, 'NaturalStraightening_', subjectList{s}, '.mat']);
    exptMatrix = S.trialMatrix( (matrixConstants.training.numTrials + 1):end , :);  % create array with only experimental portion of trial matrix
    trialMatrices.(subjectList{s}) = exptMatrix(~isnan(exptMatrix(:,8)));           % limited stored array to expt trials with a recorded subject response
    numComplete = size(trialMatrices.(subjectList{s}),1);
    
    % extract ordered list of movie-size pairs
    list = [];
    for r=1:size(matrixInfo.moviesAndSizes,1)
        list = [list; matrixInfo.moviesAndSizes{r}];
    end
    dataTracking.(subjectList{s}).moviesAndSizesList = list;
    clear r list
    
    % extract number of blocks completed per movie-size pair
    completedBlocks = matrixInfo.blockParameters(1:matrixInfo.latestBlock,:);
    [uniqueBlocks,~,uniqueBlIndexes] = unique(completedBlocks,'rows');
    completedBlocksCount = [uniqueBlocks, accumarray(uniqueBlIndexes,1)];
    
    dataTracking.(subjectList{s}).moviesAndSizesProgress = completedBlocksCount;
    
    clear completedBlocks uniqueBlocks uniqueBlIndexes completedBlocksCount
    
    % extract % responses X=A, X=B, none, break fixation, no engagement, and incomplete
    subjResponses = exptMatrix(:,8);
    
    count.XmA       = sum(subjResponses(:,1)==NaturalStraightening.CONSTANTS.RESPONSE_X_MATCHES_A);
    count.XmB       = sum(subjResponses(:,1)==NaturalStraightening.CONSTANTS.RESPONSE_X_MATCHES_B);
    count.noResp    = sum(subjResponses(:,1)==NaturalStraightening.CONSTANTS.RESPONSE_NO_RESPONSE);
    count.brFix     = sum(subjResponses(:,1)==NaturalStraightening.CONSTANTS.RESPONSE_BREAK_FIX);
    count.noEng     = sum(subjResponses(:,1)==NaturalStraightening.CONSTANTS.RESPONSE_NO_ENGAGEMENT);
    count.incomp    = sum(isnan(subjResponses(:,1)));
    
    dataTracking.(subjectList{s}).responses.note            = 'All percentages except percent incomplete are out of all completed experimental trials. Percent incomplete is out of all experimental trials.';
    dataTracking.(subjectList{s}).responses.X_matches_A     = [count.XmA;       (count.XmA / numComplete) * 100];
    dataTracking.(subjectList{s}).responses.X_matches_B     = [count.XmB;       (count.XmB / numComplete) * 100];
    dataTracking.(subjectList{s}).responses.noResponse      = [count.noResp;    (count.noResp / numComplete) * 100];
    dataTracking.(subjectList{s}).responses.breakFix        = [count.brFix;     (count.brFix / numComplete) * 100];
    dataTracking.(subjectList{s}).responses.noEngagement    = [count.noEng;     (count.noEng / numComplete) * 100];
    dataTracking.(subjectList{s}).responses.incomplete      = [count.incomp;    (count.incomp / size(exptMatrix,1)) * 100];
    
    clear subjResponses count
    
    % extract % trials correct, incorrect, aborted, without response, and incomplete
    feedback = exptMatrix(:,7);
    
    count.corr      = sum(feedback(:,1)==NaturalStraightening.CONSTANTS.OUTCOME_SUCCESS);
    count.incorr    = sum(feedback(:,1)==NaturalStraightening.CONSTANTS.OUTCOME_FAILURE);
    count.brFix     = sum(feedback(:,1)==NaturalStraightening.CONSTANTS.OUTCOME_BREAK_FIX);
    count.noResp    = sum(feedback(:,1)==NaturalStraightening.CONSTANTS.OUTCOME_NO_RESPONSE);
    count.incomp    = sum(isnan(feedback(:,1)));
    
    dataTracking.(subjectList{s}).outcomes.note             = 'All percentages except percent incomplete are out of all completed experimental trials. Percent incomplete is out of all experimental trials.';
    dataTracking.(subjectList{s}).outcomes.correct          = [count.corr;      (count.corr / numComplete) * 100];
    dataTracking.(subjectList{s}).outcomes.incorrect        = [count.incorr;    (count.incorr / numComplete) * 100];
    dataTracking.(subjectList{s}).outcomes.breakFix         = [count.brFix;     (count.brFix / numComplete) * 100];
    dataTracking.(subjectList{s}).outcomes.noResponse       = [count.noResp;    (count.noResp / numComplete) * 100];
    dataTracking.(subjectList{s}).outcomes.incomplete       = [count.incomp;    (count.incomp / size(exptMatrix,1)) * 100];
    
    clear feedback count
    
    % clean up workspace to ensure no interference when loading next subject's data
    clear matrixInfo S exptMatrix numComplete
end; clear s

%% calculate and store collective information about subjects' trail matrices

% initialize base array to be used to store:
% 1) how many blocks and trials of each possible movie-size pair a
% participant has successfully completed &
% 2) how many subjects have completed trials with each possible movie size
% pair and how many trials of that pair they have successfully completed
numMovieTypes       = NaturalStraightening.CONSTANTS.NUM_MOVIE_TYPES; % load constants
numMoviesPerType    = length(NaturalStraightening.CONSTANTS.STIMULUS_MOVIES);
numSizes            = size(NaturalStraightening.CONSTANTS.NUM_MOVIES_PER_SIZE,2);
trialCounts         = zeros(numMovieTypes * numMoviesPerType * numSizes,5); % start with array of zeros (so that addition can be used to build up counts in columns 4 and 5)

% fill in array columns 1-3: 1=movie type, 2=movie #, 3=stimulus size
startI = 1;
for typeNum = 1:numMovieTypes
    for movNum = 1:numMoviesPerType
        trialCounts(startI:(startI+numSizes-1),1) = typeNum - 1;
        trialCounts(startI:(startI+numSizes-1),2) = NaturalStraightening.CONSTANTS.STIMULUS_MOVIES(movNum);
        trialCounts(startI:(startI+numSizes-1),3) = 1:numSizes;
        startI = startI + numSizes;
    end; clear movNum
end; clear typeNum
emptyCounts = trialCounts; % store array to be used as base for subject-specific arrays

% calculate trial counts (subject-specific and global)
for s=1:size(subjectList,1)
    
    % subject-specific array columns 4-5: 4=# of blocks, 5=# of successful trials
    subjTrialCounts = emptyCounts;
    for pair = 1:size(trialCounts,1) % loop through all movie-size pairs
        % COMPLETED BLOCKS (i.e., blocks before the latest block)
        subjTrialCounts(pair,4) = sum(ismember(dataTracking.(subjectList{s}).matrixInfo.blockParameters(1:dataTracking.(subjectList{s}).matrixInfo.latestBlock,1:3),...
            subjTrialCounts(pair,1:3), 'rows')); % sum number of completed blocks that match current movie-size pair
        
        % SUCCESSFUL TRIALS (correct or incorrect only)
        correctTrials = trialMatrices.(subjectList{s})((trialMatrices.(subjectList{s})(:,7)==1),:);
        incorrectTrials = trialMatrices.(subjectList{s})((trialMatrices.(subjectList{s})(:,7)==0),:);
        successfulTrials = correctTrials + incorrectTrials;
        subjTrialCounts(pair,5) = sum(ismember(successfulTrials(:,1:3),...
            subjTrialCounts(pair,1:3), 'rows')); % sum number of successful trials for current movie-size pair
    end; clear pair
    
    dataTracking.(subjectList{s}).moviesAndSizesProgress = subjTrialCounts; % store array
    
    % global array columns 4-5: 4=# of subjects, 5=# of trials
    trialCounts(:,4) = trialCounts(:,4) + (subjTrialCounts(:,5) > 0);   % number of subjects
    trialCounts(:,5) = trialCounts(:,5) + subjTrialCounts(:,5);         % number of trials
end; clear s

dataTracking.globalTrialCounts = trialCounts; % store array

%% save results
save('./Data/trackData.mat','subjectList', 'dataTracking', 'trialMatrices');
end