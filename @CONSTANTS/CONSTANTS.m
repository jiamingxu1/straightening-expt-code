classdef CONSTANTS
    % Convention: use upper case for constants.
    
    % Reference in code via syntax 'NaturalStraightening.CONSTANTS.[VARIABLE_NAME]'
    
    properties (Constant = true)
        %%  where am i
        % ROOT_FOLDER indicates where '+NaturalSequences' exists.
        % This location will change with your environment.

        ROOT_FOLDER             = '/Users/gorislab/Desktop/psychophysics/experiments/+NaturalStraightening/';
        STIMULUS_FOLDER         = '/Users/gorislab/Desktop/psychophysics/experiments/+NaturalStraightening/stimulus/stimSelected-zoom1x/';
        MASK_FILE               = '/Users/gorislab/Desktop/psychophysics/experiments/+NaturalStraightening/stimulus/mask/Flattop8.tif';
        
        %% movie folders
        MOVIE_FOLDERS           = { 'movie01-chironomus', ...
                                    'movie02-bees', ...
                                    'movie03-dogville', ...
                                    'movie04-egomotion', ...
                                    'movie05-prairie1', ...
                                    'movie06-carnegie-dam', ...
                                    'movie07-walking', ...
                                    'movie08-smile', ...
                                    'movie09-water', ...
                                    'movie10-leaves-wind' };
                                
        %% frame filenames
        FRAME_INDEX_PER_MOVIE   = 1:11;
        RAW_IMAGE_SIZE_PIXELS   = 512;
        
        %__ NATURAL ____%
        NATURAL_FRAMES          = { 'natural01.png', ...
                                    'natural02.png', ...
                                    'natural03.png', ...
                                    'natural04.png', ...
                                    'natural05.png', ...
                                    'natural06.png', ...
                                    'natural07.png', ...
                                    'natural08.png', ...
                                    'natural09.png', ...
                                    'natural10.png', ...
                                    'natural11.png' };
                                   
        %__ SYNTHETIC ____%
        SYNTHETIC_FRAMES        = { 'natural01.png', ...
                                    'synthetic02.png', ...
                                    'synthetic03.png', ...
                                    'synthetic04.png', ...
                                    'synthetic05.png', ...
                                    'synthetic06.png', ...
                                    'synthetic07.png', ...
                                    'synthetic08.png', ...
                                    'synthetic09.png', ...
                                    'synthetic10.png', ...
                                    'natural11.png' };
                                   
        
        %__ CONTRAST ____%
        % Not for now (10/4/10)
        
        %% chosen movies
        % real experiment (April 2019, start with three)
        STIMULUS_MOVIES         = [4   5   6];
        % ...add more if necessary
        %STIMULUS_MOVIES         = [1 3 4 5 6];
        TRAINING_MOVIES         = [1   3   9];
        INDEX_DIFFERENCE        = 10; % multiply movie numbers by this number to differentiate movie types
        
        %% movie types
        % NOTE: changing these numbers will mean createTrialMatrix.m will need to be edited
        NUM_MOVIE_TYPES         = 2;
        NATURAL_TYPE            = 0;
        SYNTHETIC_TYPE          = 1;
        
        %% session dimensions
        % real experiment
        NUM_REPETITIONS         = 11;
        NUM_TRIALS_PER_BLOCK    = 40;  %4; %40;
        % % Use the following line for naive subjects 
        % NUM_TRAINING_TRIALS     = 280; % NOTE: 7 blocks are predefined in createTrialMatrix.m
        % Use the following line for Goris lab subjects 
        NUM_TRAINING_TRIALS     = 80; % NOTE: 7 blocks are predefined in createTrialMatrix.m

        %% image sizes 
        % real experiment
        IMG_OUTER_DIAMETERS_DEG = [6,    24,   36];
        IMG_INNER_DIAMETERS_DEG = [1,    4,    6];
        NUM_MOVIES_PER_SIZE     = [1,    1,    1];
       
        %% fixation boundary
        WINDOW_SIZE             = 1.5; % radius
        PRE_STIM_RADIUS_DEG     = 3.0; 
        
        %% rig specs   
        % real experiment
        CRT_DISTANCE_CM         = 47;               % cm
        
        CRT_RESOLUTION          = '1280x1024';      % pixels
        CRT_HEIGHT              = '';
        CRT_WIDTH               = '';
        PIXEL_BIT_DEPTH         = 8; % 8 bits = 256 grayscales
        
        %% possible subject responses
        RESPONSE_X_MATCHES_A    = 0;
        RESPONSE_X_MATCHES_B    = 1;
        RESPONSE_NO_RESPONSE    = -1;
        RESPONSE_BREAK_FIX      = -2;
        RESPONSE_NO_ENGAGEMENT  = -3;
        
        %% possible trial outcomes
        OUTCOME_SUCCESS         =  1;
        OUTCOME_FAILURE         =  0;
        OUTCOME_BREAK_FIX       = -1;
        OUTCOME_NO_RESPONSE     = -2;
                                    
        %% debugging parameters
        DEBUG_MODE              = false;
        SLOW_DOWN_FACTOR        = 1;
        % REMINDER: turn fixation monitoring on/off via isFixating.m
    end
   
end