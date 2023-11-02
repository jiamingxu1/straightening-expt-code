function analyzeTraining(subject_string, trialMatrix)
% ANALYZETRAINING loads subject ID and trial matrix, extracts subject
% responses and trial outcomes for all training trials, and calculates
% relative percentages of each possible response and outcome. Relevant
% performance information is displayed for experimenter convenience, and
% all calculated performance information is saved to a MAT file.
%
% 2018-10-30  SMS  wrote it. <smshields@utexas.edu>

numTrainingTrials = NaturalStraightening.CONSTANTS.NUM_TRAINING_TRIALS;

%% extract % responses X=A, X=B, none, break fixation, no engagement, and incomplete
subjResponses = trialMatrix(1:numTrainingTrials,8);

count.XmA       = sum(subjResponses(:,1)==NaturalStraightening.CONSTANTS.RESPONSE_X_MATCHES_A);
count.XmB       = sum(subjResponses(:,1)==NaturalStraightening.CONSTANTS.RESPONSE_X_MATCHES_B);
count.noResp    = sum(subjResponses(:,1)==NaturalStraightening.CONSTANTS.RESPONSE_NO_RESPONSE);
count.brFix     = sum(subjResponses(:,1)==NaturalStraightening.CONSTANTS.RESPONSE_BREAK_FIX);
count.noEng     = sum(subjResponses(:,1)==NaturalStraightening.CONSTANTS.RESPONSE_NO_ENGAGEMENT);
count.incomp    = sum(isnan(subjResponses(:,1)));

training.responses.X_matches_A     = [count.XmA;        (count.XmA / numTrainingTrials) * 100];
training.responses.X_matches_B     = [count.XmB;        (count.XmB / numTrainingTrials) * 100];
training.responses.noResponse      = [count.noResp;     (count.noResp / numTrainingTrials) * 100];
training.responses.breakFix        = [count.brFix;      (count.brFix / numTrainingTrials) * 100];
training.responses.noEngagement    = [count.noEng;      (count.noEng / numTrainingTrials) * 100];
training.responses.incomplete      = [count.incomp;     (count.incomp / numTrainingTrials) * 100];

clear count

%% extract % trials correct, incorrect, aborted, without response, and incomplete
feedback = trialMatrix(1:numTrainingTrials,7);

numEngagedTrials= sum(trialMatrix(1:numTrainingTrials,end) >= 0);

count.corr      = sum(feedback(:,1)==NaturalStraightening.CONSTANTS.OUTCOME_SUCCESS);
count.incorr    = sum(feedback(:,1)==NaturalStraightening.CONSTANTS.OUTCOME_FAILURE);
count.brFix     = sum(feedback(:,1)==NaturalStraightening.CONSTANTS.OUTCOME_BREAK_FIX);
count.noResp    = sum(feedback(:,1)==NaturalStraightening.CONSTANTS.OUTCOME_NO_RESPONSE);
count.incomp    = sum(isnan(feedback(:,1)));

training.outcomes.correct          = [count.corr;       (count.corr   / numEngagedTrials) * 100];
training.outcomes.incorrect        = [count.incorr;     (count.incorr / numEngagedTrials) * 100];
training.outcomes.breakFix         = [count.brFix;      (count.brFix  / numTrainingTrials) * 100];
training.outcomes.noResponse       = [count.noResp;     (count.noResp / numTrainingTrials) * 100];
training.outcomes.incomplete       = [count.incomp;     (count.incomp / numTrainingTrials) * 100];

clear count

%% display performance

disp(['Break fixation: ', num2str(training.outcomes.breakFix(2)), '%'])
disp(['X==A: ', num2str(training.responses.X_matches_A(2)), '%', ' / X==B: ', num2str(training.responses.X_matches_B(2)), '%'])
disp(['Correct: ', num2str(training.outcomes.correct(2)), '%'])


%% save
subject_data_folder     = fullfile(NaturalStraightening.CONSTANTS.ROOT_FOLDER, 'data', subject_string, '/');
save(fullfile(subject_data_folder, ['trainingPerformance_',subject_string,'.mat']), 'training');
end