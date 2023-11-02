function p = trialFunction(p, state)
% TRIALFUNCTION is a function to link your own task sequence to PLDAPS. This
% specific format depends on the requirements of PLDAPS. This function
% gets called for every frame and changes internal PLDAPS states. PLDAPS
% cycles through states that are pre-defined (default) or custom-built.
% Default states are provided by 'pldapsDefaultTrialFunction()'.
% It is strongly recommended to build your code on top of
% 'pldapsDefaultTrialFunction()'.
%
% What are these states?
% PLDAPS states are designed to operate at the level of individual frames
% and synchronizing data acquitition with Plexon and PTB.
%
% Default order of state-traversal:
%
% 1. p.trial.pldaps.trialStates.frameUpdate
% 2. p.trial.pldaps.trialStates.framePrepareDrawing
% 3. p.trial.pldaps.trialStates.frameDraw
% .. p.trial.pldaps.trialStates.frameIdlePreLastDraw;
% .. p.trial.pldaps.trialStates.frameDrawTimecritical;
% 6. p.trial.pldaps.trialStates.frameDrawingFinished;
% .. p.trial.pldaps.trialStates.frameIdlePostDraw;
% 8. p.trial.pldaps.trialStates.frameFlip;
% .. means not implemented by PLDAPS version 4.2 (open-reception branch)
%
% CAUTION: if a certain frame state took too long, everything will get pushed
% back and frames could be dropped (p.data.timing: refer to flip times to double-check)
%
% 2017-11-16  YB   wrote it. <yoonbai@utexas.edu>
%
% 2018-09-05  SMS  repurposed it for psychophysical straightening study. <smshields@utexas.edu>
%


% Identify the struct-field where all of our variables reside.
modName = p.trial.modName;

% Use PLDAPS' default trial function
pldapsDefaultTrialFunction(p, state, modName);

% Switch among several states at the resolution of individual frames
switch state
    
    % Arrange in the order of most frequently visited cases--starting with
    % cases that deal functions at the level of individual frames
    
    % --------------------------------------------------------------------%
    % FRAME STATES
    % --------------------------------------------------------------------%
    case p.trial.pldaps.trialStates.frameUpdate
        
        % Update circular buffer for eye tracing. Eye positions are updated in 'frameUpdate' in
        % 'pldapsDefaultTrialFunction()'
        %NaturalStraightening.adjustGainOffsets(p);
        newest              = [p.trial.eyeX, p.trial.eyeY];
        p.trial.eyeTraceXY  = [p.trial.eyeTraceXY(2:end,:); newest];
        
        % listen for key press if in report state
        if (p.trial.(modName).states.current_state == p.trial.(modName).states.REPORT)
            NaturalStraightening.getKeyPress(p);
        end
    % --------------------------------------------------------------------%
    case p.trial.pldaps.trialStates.framePrepareDrawing
        %        p.trial.(modName).states.current_state  = NaturalStraightening.taskSequence(p, p.trial.(modName).states.current_state);
        p.trial.(modName).states.previous_state = p.trial.(modName).states.current_state;
        p.trial.(modName).states.current_state  = NaturalStraightening.taskSequence(p, p.trial.(modName).states.previous_state);
    
    % --------------------------------------------------------------------%
    case p.trial.pldaps.trialStates.frameDraw
        % *** Present image buffers (do not make textures here. this is designed to
        % "draw" or present pre-existing image buffers.
        % Also, this is where 'pldapsDefaultTrialFunction()' overlays the grid
        
        % target monitors
        monkeyDisplay       = p.trial.display.ptr;
        %experimenterDisplay = p.trial.display.overlayptr;
        
        % image presentation
        if(p.trial.(modName).states.current_state == p.trial.(modName).states.A_ON)
            NaturalStraightening.drawImageStimulus(p);
            
            if p.trial.datapixx.use && (p.trial.(modName).states.previous_state == p.trial.(modName).states.FP_HOLD)
                p.trial.timing.datapixxSTIMON   = NaturalStraightening.sendDigitalEvent( p.trial.pldaps.iTrial, p.trial.event.STIMULUS);
            end
            
        end
        
        if(p.trial.(modName).states.current_state == p.trial.(modName).states.X_ON)
            NaturalStraightening.drawImageStimulus(p);
            
            if p.trial.datapixx.use && (p.trial.(modName).states.previous_state == p.trial.(modName).states.FP_HOLD)
                p.trial.timing.datapixxSTIMON   = NaturalStraightening.sendDigitalEvent( p.trial.pldaps.iTrial, p.trial.event.STIMULUS);
            end
            
        end
        
        if(p.trial.(modName).states.current_state == p.trial.(modName).states.B_ON)
            NaturalStraightening.drawImageStimulus(p);
            
            if p.trial.datapixx.use && (p.trial.(modName).states.previous_state == p.trial.(modName).states.FP_HOLD)
                p.trial.timing.datapixxSTIMON   = NaturalStraightening.sendDigitalEvent( p.trial.pldaps.iTrial, p.trial.event.STIMULUS);
            end
            
        end
        
       
        % keep FP on until last stimulus presentation ('B_ON')
        if(p.trial.(modName).states.current_state < p.trial.(modName).states.B_OFF)
            NaturalStraightening.drawFixationPoint(p);
            % fixation point will turn off to indicate subject can break fixation and REPORT
        end
        
        if(NaturalStraightening.CONSTANTS.DEBUG_MODE)
            % EYE trace (only on the experimenter's monitor)
            NaturalStraightening.drawEyeTrace(p, monkeyDisplay);
            % draw fixation boundary (only on the experimenter's monitor)
            NaturalStraightening.drawFixationBoundary(p);
            NaturalStraightening.drawGainOffsetText(p, monkeyDisplay);
        end
    % --------------------------------------------------------------------%
    case p.trial.pldaps.trialStates.frameDrawingFinished
        % boolean status is saved to 'p.trial.(modName).isFixating'
        %NaturalStraightening.isFixating(p);
        
%         if(p.trial.sound.use)
%             if (p.trial.(modName).states.current_state == p.trial.(modName).states.REPORT)
%                 PsychPortAudio('Start', p.trial.sound.cue, 1, [], [], []);
%             end
%         end
        
    % --------------------------------------------------------------------%   
    case p.trial.pldaps.trialStates.frameFlip
        % You can modify frame rates here
        
        
        
    % --------------------------------------------------------------------%
    % TRIAL STATES
    % --------------------------------------------------------------------%
    case p.trial.pldaps.trialStates.trialSetup
        % Called once at the beginning of every trial
        
        % Initialize circular buffer for eye tracing
        buffSize                = floor(0.3 / p.trial.display.ifi); % 0.3 seconds of tracing
        p.trial.eyeTraceXY      = nan(buffSize,2);
        
        % custom switch to toggle b/w X or Y gain/offset
        p.trial.eyeTrackerToggle = false;
        
        % load gaze gain/offset from file
        filepath        = p.trial.TRIAL_MATRIX_FILEPATH;
        
        load(filepath, 'S'); % 'S' is the struct that contains experiment info
        p.trial.(modName).gaze.x_gain           = S.(modName).gaze.x_gain;
        p.trial.(modName).gaze.y_gain           = S.(modName).gaze.y_gain;
        p.trial.(modName).gaze.x_offset         = S.(modName).gaze.x_offset;
        p.trial.(modName).gaze.y_offset         = S.(modName).gaze.y_offset;
        p.trial.(modName).gaze.gain_step_size   = S.(modName).gaze.gain_step_size;
        p.trial.(modName).gaze.offset_step_size = S.(modName).gaze.offset_step_size;
        
        p.trial.(modName).gaze.curr_window_radius_deg           = p.trial.(modName).gaze.RADIUS_DEG;
        % pick up from where we left off
%         sessionFolder                           = ['./Data/', p.trial.session.subject, '/'];
%         sessionFilePath                         = [sessionFolder, 'sessionInfo.mat'];
%         load(sessionFilePath, 'session');
        load(p.trial.SESSION_INFO_FILEPATH, 'session');
        p.trial.(modName).sessionTrialIndex     = session.sessionTrialIndex;
        
    % --------------------------------------------------------------------%
    case p.trial.pldaps.trialStates.trialPrepare
        % Device buffers are cleared and prepared here (pldapsDefaultTrialFunction.m)
        
        % Audible cue
        if(p.trial.sound.use)
            % Start immediately (0 = immediately)
            startCue            = 0;
            % Should we wait for the device to really start (1 = yes)
            % INFO: See help PsychPortAudio
            waitForDeviceStart  = 1;
            repetitions         = 1;
            %PsychPortAudio('Start', p.trial.sound.cue, 1, [], [], []);
            PsychPortAudio('Start', p.trial.sound.cue, repetitions, startCue, waitForDeviceStart);

            % Wait for the beep to end. Here we use an improved timing method suggested
            % by : https://groups.yahoo.com/neo/groups/psychtoolbox/conversations/messages/20863
            [actualStartTime, ~, ~, estStopTime] = PsychPortAudio('Stop', p.trial.sound.cue, 1, 1);

        end
        
        % start keeping track of timestamps (or framestamps)
        p.trial.(modName).states.timestamps.START = p.trial.ttime;
        % PLDAPS maintenance
        p.trial.pldaps.goodtrial    = false;
        p.trial.finished            = false;
        p.trial.flagNextTrial       = false; % tell PLDAPS not to start next trial
        
        if p.trial.datapixx.use
            p.trial.timing.datapixxStartTime    = Datapixx('Gettime');
            p.trial.timing.datapixxTRIALSTART   = NaturalStraightening.sendDigitalEvent(p.trial.pldaps.iTrial, p.trial.event.TRIALSTART);
        end
    % --------------------------------------------------------------------%
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        % Called once at the end of every trial
        
        % in case we reach max. number of frames...
        if(p.trial.iFrame == p.trial.pldaps.maxFrames)
            p.trial.flagNextTrial = true;
        end
        
        trialIndex = p.trial.(modName).sessionTrialIndex;
        
        % determine outcome from subject's response
        switch p.trial.(modName).response.subjectResponse
             
            case p.trial.(modName).response.BREAK_FIX
                p.trial.(modName).outcome.trialOutcome      = p.trial.(modName).outcome.BREAK_FIX;
                
            case p.trial.(modName).response.NO_RESPONSE
                p.trial.(modName).outcome.trialOutcome      = p.trial.(modName).outcome.NO_RESPONSE;
                
            case p.trial.(modName).response.NO_ENGAGEMENT
                p.trial.(modName).outcome.trialOutcome      = p.trial.(modName).outcome.NO_RESPONSE;
                
            case p.trial.(modName).response.X_MATCHES_A
                isCorrect = p.conditions{trialIndex}.naturalstraightening.X_FRAMES == ...
                    p.conditions{trialIndex}.naturalstraightening.A_FRAMES;

                if(isCorrect)
                    p.trial.(modName).outcome.trialOutcome      = p.trial.(modName).outcome.SUCCESS;
                else
                    p.trial.(modName).outcome.trialOutcome      = p.trial.(modName).outcome.FAILURE;
                end
                
            case p.trial.(modName).response.X_MATCHES_B
                isCorrect = p.conditions{trialIndex}.naturalstraightening.X_FRAMES == ...
                    p.conditions{trialIndex}.naturalstraightening.B_FRAMES;

                if(isCorrect)
                    p.trial.(modName).outcome.trialOutcome      = p.trial.(modName).outcome.SUCCESS;
                else
                    p.trial.(modName).outcome.trialOutcome      = p.trial.(modName).outcome.FAILURE;
                end
        end
        
        
        % in case of using audible feedback, determine appropriate feedback
        % based on p.trial.custom.outcome
        
        % Start immediately (0 = immediately)
        startCue            = 0;
        % Should we wait for the device to really start (1 = yes)
        % INFO: See help PsychPortAudio
        waitForDeviceStart  = 1;
        repetitions         = 1;
        
        if(p.trial.sound.use)
            switch p.trial.(modName).outcome.trialOutcome
                case p.trial.(modName).outcome.SUCCESS
                    %PsychPortAudio('Start', p.trial.sound.reward,    1, [], [], []);
                    PsychPortAudio('Start', p.trial.sound.reward, repetitions, startCue, waitForDeviceStart);
                    [actualStartTime, ~, ~, estStopTime] = PsychPortAudio('Stop', p.trial.sound.reward, 1, 1);
                case p.trial.(modName).outcome.FAILURE
                    %PsychPortAudio('Start', p.trial.sound.incorrect, 1, [], [], []);
                    PsychPortAudio('Start', p.trial.sound.incorrect, repetitions, startCue, waitForDeviceStart);
                    [actualStartTime, ~, ~, estStopTime] = PsychPortAudio('Stop', p.trial.sound.incorrect, 1, 1);
                case p.trial.(modName).outcome.NO_RESPONSE
                    %PsychPortAudio('Start', p.trial.sound.incorrect, 1, [], [], []);
                    PsychPortAudio('Start', p.trial.sound.incorrect, repetitions, startCue, waitForDeviceStart);
                    [actualStartTime, ~, ~, estStopTime] = PsychPortAudio('Stop', p.trial.sound.incorrect, 1, 1);
                case p.trial.(modName).outcome.BREAK_FIX
                    %PsychPortAudio('Start', p.trial.sound.breakfix,  1, [], [], []);
                    PsychPortAudio('Start', p.trial.sound.breakfix, repetitions, startCue, waitForDeviceStart);
                    [actualStartTime, ~, ~, estStopTime] = PsychPortAudio('Stop', p.trial.sound.breakfix, 1, 1);
            end
        end
        
        if p.trial.datapixx.use
            p.trial.timing.datapixxEndTime    = Datapixx('Gettime');
            p.trial.timing.datapixxTRIALEND   = NaturalStraightening.sendDigitalEvent( p.trial.pldaps.iTrial, p.trial.event.TRIALEND);
        end
        

        % update session info 
        load(p.trial.SESSION_INFO_FILEPATH, 'session');
        session.sessionTrialMatrix( p.trial.(modName).sessionTrialIndex,  session.sessionTrialMatrix_fields.RESPONSE) = p.trial.(modName).response.subjectResponse;
        session.sessionTrialMatrix( p.trial.(modName).sessionTrialIndex,  session.sessionTrialMatrix_fields.FEEDBACK) = p.trial.(modName).outcome.trialOutcome;
        p.trial.(modName).sessionTrialIndex     = p.trial.(modName).sessionTrialIndex + 1;
        session.sessionTrialIndex               = p.trial.(modName).sessionTrialIndex;
        save(p.trial.SESSION_INFO_FILEPATH, 'session');
        
        % --------------------------------------------------------------------%
        % ITI
        switch p.trial.(modName).outcome.trialOutcome
            case p.trial.(modName).outcome.SUCCESS
                WaitSecs(p.trial.(modName).ITI);
                
            case p.trial.(modName).outcome.FAILURE
                WaitSecs(p.trial.(modName).ITI); % for monkeys: double ITI for negative feedback
                
            case p.trial.(modName).outcome.BREAK_FIX
                WaitSecs(p.trial.(modName).ITI); % for monkeys: double ITI for negative feedback
        end
        
    % --------------------------------------------------------------------%
    % EXPERIMENT SESSION STATES
    % --------------------------------------------------------------------%
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        % This state gets called exactly once after the screen was opened
        % (and after the specifyExperiment file got called).
        % This is a good place to define a texture.
        
        filepath        = p.trial.TRIAL_MATRIX_FILEPATH;
        load(filepath, 'S'); % 'S' is the struct that contains experiment info
        
%         % start from where we left off
%         sessionFolder                           = ['./Data/', datestr(now, 'mm-dd-yyyy'), '/'];
%         sessionFilePath                         = [sessionFolder, 'sessionInfo.mat'];
%         load(sessionFilePath, 'session');
%         p.trial.(modName).sessionTrialIndex     = session.sessionTrialIndex;
        
        % ???: everything slows down when generating a lot of textures
        p = NaturalStraightening.generateImageStimuliForSession(p);
        
        %         % DrawFormattedText bugs: http://www.vpixx.com/manuals/psychtoolbox/html/AdvancedDemo3.html
        %         if(p.trial.datapixx.use)
        %             Datapixx('SetVideoClut', [clutTestDisplay;clutConsoleDisplay]);
        %         end
        
        % Make overlay text clean (based on the following PTB comments):
        % "Disable text alpha-blending to avoid color weirdness in the color
        % overlay text due to off-by-one color index values indexing into the
        % wrong clut slot. This is a workaround for some alpha-blending bugs
        % in some MS-Windows graphics drivers. This is fine on MS-Windows and
        % on OSX with its default text renderer, as long as anti-aliasing for
        % text is disabled, which it is. On Linux we must keep alpha-blending
        % enabled/alone, as the text rendering plugin depends on it to actually define
        % the shape of the character glyphs in the alpha-channel, not in the color
        % channels."
        oldAntialias = Screen('Preference', 'TextAntiAliasing', 0);  % ...otherwise ghosting on overlay win
        if ~IsLinux
            oldTextAlpha = Screen('Preference', 'TextAlphaBlending', 1);
        else
            oldTextAlpha = Screen('Preference', 'TextAlphaBlending');
        end
        
        
    % --------------------------------------------------------------------%    
    % note: this is used when p.trial.pldaps.useModularStateFunctions
    % is true.
    case p.trial.pldaps.trialStates.experimentCleanUp
        
        % session
        load(p.trial.SESSION_INFO_FILEPATH, 'session');
        
        % overall experiment
        load(p.trial.TRIAL_MATRIX_FILEPATH, 'S');
        
        %% TRIAL MATRIX MAINTENANCE
        % copy this session's trial matrix to the original trial matrix ...
        % ONLY IF THE SUBJECT COMPLETED THE ENTIRE BLOCK
        unvisited_index         = find(isnan(S.trialMatrix(:, end)));
        current_block_start     = unvisited_index(1);
        current_block_end       = current_block_start + size(session.sessionTrialMatrix, 1) - 1;
        
        % record current status in p object
        p.trial.(modName).matrixInfo.latestTrial = current_block_end;
        current_block = current_block_end/NaturalStraightening.CONSTANTS.NUM_TRIALS_PER_BLOCK;
        p.trial.(modName).matrixInfo.latestBlock = current_block;
        
        isSuccessfulBlock   = numel(session.sessionTrials) == sum(~isnan(session.sessionTrialMatrix(:,end)));
        if(isSuccessfulBlock)
            S.trialMatrix(current_block_start:current_block_end, :) = session.sessionTrialMatrix;
            save(p.trial.TRIAL_MATRIX_FILEPATH, 'S');
        end
        
        %% PROVIDE OPTIONS TO USER
        if(~session.isFinalBlock)
            
            % if user has just finished training, display screen telling
            % them they must wait for the experimenter before they can
            % continue, and analyze user's training performance
            
            % otherwise, give user the option to continue right away,
            % calibrate before continuing, or end the current experiment
            % session
            
            if current_block == p.trial.(modName).matrixConstants.training.numBlocks
                % WHEN DONE WITH TRAINING...
                
                % Record for latest group as 0 (=training)
                p.trial.(modName).matrixInfo.latestGroup = 0;
                
                
                screenid = max(Screen('Screens'));
                
                % Open a fullscreen onscreen window on that display
                window_ptr = Screen('OpenWindow', screenid, 225);
% Use this block of code for naive subjects (was used prior to 7/4/2020)
%                 progress_report = 'Training complete!';
%                 instructions_1 = 'Please inform the experimenter.';
%                 instructions_2 = 'They will check your performance and tell you';
%                 instructions_3 = 'whether you can proceed with the experiment.';
%                 instructions_5 = 'Hit "3" to end this experiment session.';
                
                % custom instructions for subjects 1, 2, and 3
                progress_report = 'Warm-up complete!';
                instructions_1 = 'Please run your ''customize_trial_matrix'' script.';
                instructions_2 = 'It''s in your data folder';
                instructions_3 = 'Afterwards, re-run ''yoon.mlapp''';
                instructions_5 = 'Hit "3" to end this experiment session.';
                
                % font size
                Screen('TextSize', window_ptr, 40);
                
                % put this on frame that is about to be displayed
                [nx, ny, bbox] = DrawFormattedText(window_ptr, progress_report, 'center', 300, [0, 0, 0, 255]);
                [nx, ny, bbox] = DrawFormattedText(window_ptr, instructions_1, 'center', 400, [0, 0, 0, 255]);
                [nx, ny, bbox] = DrawFormattedText(window_ptr, instructions_2, 'center', 500, [0, 0, 0, 255]);
                [nx, ny, bbox] = DrawFormattedText(window_ptr, instructions_3, 'center', 550, [0, 0, 0, 255]);
                [nx, ny, bbox] = DrawFormattedText(window_ptr, instructions_5, 'center', 700, [255, 0, 0, 255]);
                
                % flip to the frame
                Screen('Flip', window_ptr);
                
                % ANALYZE training data and DISPLAY most relevant output for experimenter
                NaturalStraightening.analyzeTraining(session.subject,S.trialMatrix);
                
                % NOTE: PLDAPS has its own key codes that are different from PTB.
                % For example, the key '1' has a key code of 89 in PTB, but this is
                % 30 in PLDAPS...why...OTL...
                keyCode_3 = p.trial.keyboard.codes.KPthrKey;
                %             keyCode_3 = KbName('3');
                
                while 1
                    % Check the state of the keyboard.
                    [ keyIsDown, seconds, keyCode ] = KbCheck;
                    keyCode                         = find(keyCode, 1);
                    
                    % If the user is pressing a key, then display its code number and name.
                    if keyIsDown
                        % Note that we use find(keyCode) because keyCode is an array.
                        % See 'help KbCheck'
                        
                        fprintf('You pressed key %s (key code: %i)\n', KbName(keyCode), keyCode);
                        
                        switch keyCode
                            case keyCode_3 % abort session
                                session.calibrate       = false;
                                session.isOngoing       = false;
                                session.endExperiment   = true;
                                break;
                                
                            otherwise
                                fprintf('Unrecognized option for key: %s\n', KbName(keyCode));
                                
                                % temp: hardcoded for laptop emulator
                                % session.isOngoing       = false;
                                % session.endExperiment   = true;
                                break; % get out of the while-loop
                                
                        end
                        
                        % If the user holds down a key, KbCheck will report multiple events.
                        % To condense multiple 'keyDown' events into a single event, we wait until all
                        % keys have been released.
                        KbReleaseWait;
                        
                    end
                end
                
            else    % if not the end of training...
                
                screenid = max(Screen('Screens'));
                
                % Open a fullscreen onscreen window on that display
                window_ptr = Screen('OpenWindow', screenid, 225);
                
                % Calculate number of blocks in group
                for i=1:size(p.trial.(modName).matrixConstants.groupEnds,1)  % for each group (last block numbers of each pre-saved in createTrialMatrix.m)
                    if current_block <= p.trial.(modName).matrixConstants.groupEnds(i)   % check whether last completed block is within bounds of each group
                        if i == 1                                                   % if it's a training block...
                            completed_blocks = current_block;                           % ...record most recently completed block number
                            stop_block = p.trial.(modName).matrixConstants.groupEnds(i);     % ...record training end point as end point
                        else                                                        % if it's an experimental block...
                            completed_blocks = current_block - p.trial.(modName).matrixConstants.training.numBlocks;                        % ...record adjusted most recently completed block number
                            stop_block = p.trial.(modName).matrixConstants.exptGroupEnds(end);  % ...record expt group end point
                            %stop_block = p.trial.(modName).matrixConstants.exptGroupEnds(i-1);  % ...record expt group end point
                        end
                        p.trial.(modName).matrixInfo.latestGroup = i - 1;           % record adjusted current group number in p object
                        clear i; break  % exit for loop
                    end
                end
                
                progress_report = sprintf('%d out of %d blocks complete.', completed_blocks, stop_block);
                instructions_1 = 'You may now take a break and then proceed when ready.';
                instructions_2 = 'How would you like to proceed?';
                instructions_3 = 'Hit "1" to initiate the next block,';
                instructions_4 = 'Hit "2" to calibrate eye tracker,';
                instructions_5 = 'Hit "3" to end this experiment session.';
                
                % font size
                Screen('TextSize', window_ptr, 40);
                
                % put this on frame that is about to be displayed
                [nx, ny, bbox] = DrawFormattedText(window_ptr, progress_report, 'center', 300, [0, 0, 0, 255]);
                [nx, ny, bbox] = DrawFormattedText(window_ptr, instructions_1, 'center', 400, [0, 0, 0, 255]);
                [nx, ny, bbox] = DrawFormattedText(window_ptr, instructions_2, 'center', 500, [0, 0, 0, 255]);
                [nx, ny, bbox] = DrawFormattedText(window_ptr, instructions_3, 'center', 600, [255, 0, 0, 255]);
                %[nx, ny, bbox] = DrawFormattedText(window_ptr, instructions_4, 'center', 650, [255, 0, 0, 255]);
                [nx, ny, bbox] = DrawFormattedText(window_ptr, instructions_5, 'center', 700, [255, 0, 0, 255]);
                
                % flip to the frame
                Screen('Flip', window_ptr);
                
                % NOTE: PLDAPS has its own key codes that are different from PTB.
                % For example, the key '1' has a key code of 89 in PTB, but this is
                % 30 in PLDAPS...why...
                keyCode_1 = p.trial.keyboard.codes.KPoneKey;
                keyCode_2 = p.trial.keyboard.codes.KPtwoKey;
                keyCode_3 = p.trial.keyboard.codes.KPthrKey;
                %             keyCode_1 = KbName('1');
                %             keyCode_2 = KbName('2');
                %             keyCode_3 = KbName('3');
                
                while 1
                    % Check the state of the keyboard.
                    [ keyIsDown, seconds, keyCode ] = KbCheck;
                    keyCode                         = find(keyCode, 1);
                    
                    % If the user is pressing a key, then display its code number and name.
                    if keyIsDown
                        % Note that we use find(keyCode) because keyCode is an array.
                        % See 'help KbCheck'
                        
                        fprintf('You pressed key %s (key code: %i)\n', KbName(keyCode), keyCode);
                        
                        switch keyCode
                            case keyCode_1 % initiate next block
                                session.calibrate       = false;
                                session.isOngoing       = true;
                                session.endExperiment   = false;
                                break; % get out of the while-loop
                                
                            case keyCode_2 % calibrate eyelink in the next block

                                % NOTE (Jan 2019): between-session calibration does
                                % not work well. I'll have to force this
                                % choice to be equal to 'keyCode_3'
%                                 session.calibrate       = true;
%                                 session.isOngoing       = true;
%                                 session.endExperiment   = false;
%                                 break;
                                session.calibrate       = false;
                                session.isOngoing       = false;
                                session.endExperiment   = true;
                                break;
                                
                            case keyCode_3 % abort session
                                session.calibrate       = false;
                                session.isOngoing       = false;
                                session.endExperiment   = true;
                                break;
                                
                            otherwise
                                fprintf('Unrecognized option for key: %s\n', KbName(keyCode));
                                
                                % temp: hardcoded for laptop emulator
                                % session.isOngoing       = true;
                                % session.endExperiment   = false;
                                break; % get out of the while-loop
                                
                        end
                        
                        % If the user holds down a key, KbCheck will report multiple events.
                        % To condense multiple 'keyDown' events into a single event, we wait until all
                        % keys have been released.
                        KbReleaseWait;
                        
                    end
                end
            end
            
            Screen('Close', window_ptr);
            
        else % experiment is complete, abort session
            session.isOngoing       = false;
            session.endExperiment   = true;
        end
        save(session.sessionFilePath, 'session');
        
        mInfo = p.trial.(modName).matrixInfo;
        save([p.trial.DATA_FOLDER,'matrixInfo_',session.subject,'.mat'], 'mInfo');
        
        mConstants = p.trial.(modName).matrixConstants;
        save([p.trial.DATA_FOLDER,'matrixConstants_',session.subject,'.mat'], 'mConstants'); % NOTE: should be the same for every subject, so these files can be used as a sanity check
        

        % Shutdown Eyelink:
        Eyelink('Shutdown');
        
end

end