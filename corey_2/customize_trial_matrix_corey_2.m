%% Customize subject test conditions

subject             = 'corey_2';

trialMatrix_file    = ['NaturalStraightening_', subject, '.mat'];
mConstants_file     = ['matrixConstants_',      subject, '.mat'];
mInfo_file          = ['matrixInfo_',           subject, '.mat'];

% 1. natural    -   movie #6    -   parafovea


% update matrix info struct
% load(mInfo_file)
% mInfo.moviesAndSizes{1} = [0 6 2];
% % mInfo.moviesAndSizes{1} = [1 60 2 ; 1 40 3];
% % mInfo.moviesAndSizes{2} = [0  5 1 ; 0  4 3];
% save(mInfo_file, 'mInfo');

% remove following movies from the original full-scale trial matrix
nat_remove          = [5, 7];
syn_remove          = [50 60 70];

%% S.trialMatrix
load(trialMatrix_file);

tmp                 = S.trialMatrix;

% total no. of training trials
nTrainingTrials     = S.naturalstraightening.matrixConstants.training.numTrials;

% no. of blocks for single movie
nBlocksPerMovie     = S.naturalstraightening.matrixConstants.expt.numBlocksPerMovie;

% no. of trials per block
num_trials_per_block= NaturalStraightening.CONSTANTS.NUM_TRIALS_PER_BLOCK;

% remove pre-selected natural movies
for i = 1:numel(nat_remove)
    tmp(tmp(:,2)==nat_remove(i),:)  = [];
end

% remove pre-selected synthetic movies
for i = 1:numel(syn_remove)
    tmp(tmp(:,2)==syn_remove(i),:) = [];
end

% total trials: 2400, blocks: 60 (=2400/40)
S.trialMatrix       = tmp;
S.blockSize         = size(tmp, 1);


%% S.naturalstraightening.matrixConstants
%%% pseudorandomly assign sizes to movies
% assign in groups, ensuring that each participant will view each size at
% least once if they view a small number of movies
S.naturalstraightening.matrixConstants.expt.numBlocks   = (S.blockSize - nTrainingTrials)/num_trials_per_block;
S.naturalstraightening.matrixConstants.exptGroupEnds    = [60;120];%[num_trials_per_block: num_trials_per_block : S.naturalstraightening.matrixConstants.expt.numBlocks];
S.naturalstraightening.matrixConstants.groupEnds        = [0;60;120] + 7;
S.naturalstraightening.matrixConstants.numSizes         = unique(S.trialMatrix(:,3));


%% S.naturalstraightening.matrixInfo
% natural types
nat_matrixInfo = S.naturalstraightening.matrixInfo.moviesAndSizes{1};
nat_matrixInfo(nat_matrixInfo(:,2) == nat_remove(1), :) = [];
S.naturalstraightening.matrixInfo.moviesAndSizes{1}     = nat_matrixInfo;

% synthetic types
syn_matrixInfo = S.naturalstraightening.matrixInfo.moviesAndSizes{2};
syn_matrixInfo(syn_matrixInfo(:,2) == syn_remove(1), :) = [];
S.naturalstraightening.matrixInfo.moviesAndSizes{2}     = syn_matrixInfo;


%% S.naturalstraightening.matrixInfo.blockParameters
blockParams     = S.naturalstraightening.matrixInfo.blockParameters;
blockParams(blockParams(:,2) == nat_remove(1), :)     	= [];
blockParams(blockParams(:,2) == syn_remove(1), :)       = [];
S.naturalstraightening.matrixInfo.blockParameters       = blockParams;

save(trialMatrix_file, 'S');

fprintf('\n Successfully customized subject 1''s trial matrix! \n');
