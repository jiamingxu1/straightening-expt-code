function nextState = taskSequence(p, currentState)
% TASKSEQUENCE handles the state machine for the task according to the task
% sequence for the psychophysical experiment. Next state is determined by
% gaze and current state. Variables that track the current state of the
% subject is defined in 'defineVariables.m'.
%
% VARIABLES THAT WILL BE UPDATED HERE:
% 1. Next state
% 2. Timestamps indicating when the subject first entered each state: p.trial.(modName).states.timestamps
% 3. Response: p.trial.(modName).response
% 4. PLDAPS' "good trial": p.trial.pldaps.goodtrial
% 5. PLDAPS' variable for indicating the end of this trial: p.trial.finished
% 6. PLDAPS' variable to trigger next trial: p.trial.flagNextTrial;

% 2017-11-20  YB   wrote it. <yoonbai@utexas.edu>
%
% 2018-09-05  SMS  repurposed it for psychophysical straightening study. <smshields@utexas.edu>
%

% Identify the field where all of our custom variables reside (this will be
% useful for 'modular' PLDAPS).
modName     = p.trial.modName;

nextState	= nan;

switch currentState
    
    % --------------------------------------------------------------------%
    % START TRIAL
    % --------------------------------------------------------------------%
    case p.trial.(modName).states.START
        delta_t     = p.trial.ttime - p.trial.(modName).states.timestamps.START;
        if(delta_t < p.trial.(modName).states.duration.START)
            nextState   = p.trial.(modName).states.START;
        else
            nextState   = p.trial.(modName).states.FP_ON;
            p.trial.(modName).states.timestamps.FP_ON = p.trial.ttime;
        end
        
    % --------------------------------------------------------------------%
    % GET SUBJECT TO ENGAGE
    % --------------------------------------------------------------------%    
        
    case p.trial.(modName).states.FP_ON
        % FP_ON is the initial state when the FP is presented. We'll wait
        % until monkey engages. The monkey might wander around, and we will
        % allow this up to a certain amount of time. This will be tracked
        % by a seprate timer to allow a longer period of waiting. 
        trial_delta_t   = p.trial.ttime - p.trial.(modName).states.timestamps.START;
        
        if(trial_delta_t < p.trial.(modName).states.duration.MAX_FP_ON_DURATION)
            
            if(NaturalStraightening.isFixating(p)) 
                
                delta_t     = p.trial.ttime - p.trial.(modName).states.timestamps.FP_ON;
                % make sure this isn't an accidental eye drift
                if(delta_t < p.trial.(modName).states.duration.FP_ON)
                    nextState   = p.trial.(modName).states.FP_ON;
                else
                    nextState   = p.trial.(modName).states.FP_HOLD;
                    p.trial.(modName).states.timestamps.FP_HOLD = p.trial.ttime;
                end
            else
                % we will be in this state until subject fixates
                nextState       = p.trial.(modName).states.FP_ON;
                % reset timestamp for next round of successful fixation during FP_ON
                p.trial.(modName).states.timestamps.FP_ON = nan;
            end
            
            p.trial.(modName).stimulus.fp.color.COLOR_INDEX = 7;
        else
            % we gave the monkey enough time to engage in the task, but the
            % monkey didn't want to do the task.
            nextState   = p.trial.(modName).states.TRIAL_COMPLETE;
            p.trial.(modName).response.subjectResponse = p.trial.(modName).response.NO_ENGAGEMENT;
            
        end
        
    case p.trial.(modName).states.FP_HOLD
        if(NaturalStraightening.isFixating(p)) % while fixating...
            
            delta_t     = p.trial.ttime - p.trial.(modName).states.timestamps.FP_HOLD;
            if(delta_t < p.trial.(modName).states.duration.FP_HOLD)
                nextState   = p.trial.(modName).states.FP_HOLD;
                
                %sizePercentage = delta_t/p.trial.(modName).states.duration.FP_HOLD;
                %p.trial.(modName).gaze.curr_window_radius_deg = p.trial.(modName).gaze.RADIUS_DEG + (1 - sizePercentage) * (p.trial.(modName).gaze.PRE_STIM_RADIUS_DEG - p.trial.(modName).gaze.RADIUS_DEG);
                %p.trial.(modName).stimulus.fp.size.curr_diameter_deg = p.trial.(modName).stimulus.fp.size.DIAMETER_DEG + (1 - sizePercentage) * (p.trial.(modName).stimulus.fp.size.PRE_STIM_DIAMETER_DEG - p.trial.(modName).stimulus.fp.size.DIAMETER_DEG);
%                 p.trial.(modName).gaze.curr_window_radius_deg           = p.trial.(modName).gaze.RADIUS_DEG;
                p.trial.(modName).stimulus.fp.size.curr_diameter_deg    = p.trial.(modName).stimulus.fp.size.DIAMETER_DEG;
                
            else
                % the monkey successfully held fixation
                nextState   = p.trial.(modName).states.A_ON;
                p.trial.(modName).states.current_img_index = 1;
                p.trial.(modName).states.timestamps.A_ON = p.trial.ttime;
                
                p.trial.(modName).gaze.curr_window_radius_deg = p.trial.(modName).gaze.RADIUS_DEG;
                
            end
            
            p.trial.(modName).stimulus.fp.color.COLOR_INDEX = 7;
            
        else % in this case, subject broke fixation.
            nextState   = p.trial.(modName).states.BREAK_FIX;
        end
        
    % --------------------------------------------------------------------%
    % DISPLAY STIMULI
    % --------------------------------------------------------------------%    
        
    case p.trial.(modName).states.A_ON
        if(NaturalStraightening.isFixating(p))
            delta_t     = p.trial.ttime - p.trial.(modName).states.timestamps.A_ON;
            
            if(delta_t > (p.trial.(modName).states.duration.A_ON))
                nextState   = p.trial.(modName).states.A_OFF;
                p.trial.(modName).states.timestamps.A_OFF = p.trial.ttime;
            else
                nextState   = p.trial.(modName).states.A_ON;
            end
            
        else
            nextState = p.trial.(modName).states.BREAK_FIX;
            p.trial.finished = true;
        end
        
    case p.trial.(modName).states.A_OFF
        if(NaturalStraightening.isFixating(p))
            delta_t     = p.trial.ttime - p.trial.(modName).states.timestamps.A_OFF;
            
            if(delta_t > (p.trial.(modName).states.duration.A_OFF))
                nextState   = p.trial.(modName).states.X_ON;
                p.trial.(modName).states.timestamps.X_ON = p.trial.ttime;
                p.trial.(modName).states.current_img_index = 2;
            else
                nextState   = p.trial.(modName).states.A_OFF;
            end
            
        else
            nextState = p.trial.(modName).states.BREAK_FIX;
            p.trial.finished = true;
        end
        
    case p.trial.(modName).states.X_ON
        if(NaturalStraightening.isFixating(p))
            delta_t     = p.trial.ttime - p.trial.(modName).states.timestamps.X_ON;
            
            if(delta_t > (p.trial.(modName).states.duration.X_ON))
                nextState   = p.trial.(modName).states.X_OFF;
                p.trial.(modName).states.timestamps.X_OFF = p.trial.ttime;
            else
                nextState   = p.trial.(modName).states.X_ON;
            end
            
        else
            nextState = p.trial.(modName).states.BREAK_FIX;
            p.trial.finished = true;
        end
        
    case p.trial.(modName).states.X_OFF
        if(NaturalStraightening.isFixating(p))
            delta_t     = p.trial.ttime - p.trial.(modName).states.timestamps.X_OFF;
            
            if(delta_t > (p.trial.(modName).states.duration.X_OFF))
                nextState   = p.trial.(modName).states.B_ON;
                p.trial.(modName).states.timestamps.B_ON = p.trial.ttime;
                p.trial.(modName).states.current_img_index = 3;
                
            else
                nextState   = p.trial.(modName).states.X_OFF;
            end
            
        else
            nextState = p.trial.(modName).states.BREAK_FIX;
            p.trial.finished = true;
        end
        
    case p.trial.(modName).states.B_ON
        if(NaturalStraightening.isFixating(p))
            delta_t     = p.trial.ttime - p.trial.(modName).states.timestamps.B_ON;
            
            if(delta_t > (p.trial.(modName).states.duration.B_ON))
                nextState   = p.trial.(modName).states.B_OFF;
                p.trial.(modName).states.timestamps.B_OFF = p.trial.ttime;
            else
                nextState   = p.trial.(modName).states.B_ON;
            end
            
        else
            nextState = p.trial.(modName).states.BREAK_FIX;
            p.trial.finished = true;
        end
        
    case p.trial.(modName).states.B_OFF
        delta_t     = p.trial.ttime - p.trial.(modName).states.timestamps.B_OFF;
        if(delta_t > (p.trial.(modName).states.duration.B_OFF))
            nextState   = p.trial.(modName).states.REPORT;
            p.trial.(modName).states.timestamps.REPORT = p.trial.ttime;
        else
            nextState   = p.trial.(modName).states.B_OFF;
        end
          
%         % we don't need to enforce fixation at this step
%         if(NaturalStraightening.isFixating(p))
%             delta_t     = p.trial.ttime - p.trial.(modName).states.timestamps.B_OFF;
%             
%             if(delta_t > (p.trial.(modName).states.duration.B_OFF))
%                 nextState   = p.trial.(modName).states.REPORT;
%                 p.trial.(modName).states.timestamps.REPORT = p.trial.ttime;
%             else
%                 nextState   = p.trial.(modName).states.B_OFF;
%             end
%             
%         else
%             nextState = p.trial.(modName).states.BREAK_FIX;
%             p.trial.finished = true;
%         end

    % --------------------------------------------------------------------%
    % GET SUBJECT TO REPORT RESPONSE
    % --------------------------------------------------------------------%
        
    case p.trial.(modName).states.REPORT
        if (~isnan(p.trial.(modName).response.subjectResponse)) % if subject has reported...
            % ...record time of reporting if it has not already been recorded
            if (isnan(p.trial.(modName).states.timestamps.KEY_PRESS))
                p.trial.(modName).states.timestamps.KEY_PRESS = p.trial.ttime;
            end
            nextState = p.trial.(modName).states.TRIAL_COMPLETE; % ...complete the trial
        else % if subject has not made a valid response...
            % ...calculate time since beginning of report state
            delta_t = p.trial.ttime - p.trial.(modName).states.timestamps.REPORT;
            if(delta_t < p.trial.(modName).states.duration.REPORT_MAX)
                % ...if the maximum alotted time for the report state has not passed...
                nextState = p.trial.(modName).states.REPORT; % ...stay in report state
            else % ...if subject does not respond within alotted response time...
                % ...record no response
                p.trial.(modName).states.timestamps.CHOICE_START = nan;
                p.trial.(modName).response.subjectResponse       = p.trial.(modName).response.NO_RESPONSE;
                p.trial.pldaps.goodtrial                         = false;
                nextState                                        = p.trial.(modName).states.TRIAL_COMPLETE;
            end
        end
        
    % --------------------------------------------------------------------%
    % FINISH TRIAL
    % --------------------------------------------------------------------%    
        
    case p.trial.(modName).states.TRIAL_COMPLETE
        % successfully ended trial, irrespective of response
        % responses were already registered in previous states
        nextState                   = p.trial.(modName).states.TRIAL_COMPLETE;
        p.trial.pldaps.goodtrial    = true;
        p.trial.finished            = true;
        p.trial.flagNextTrial       = true; % tell PLDAPS to start next trial
        p.trial.(modName).states.timestamps.TRIAL_COMPLETE = p.trial.ttime;
        
    % --------------------------------------------------------------------%
    % -OR- RECORD THAT SUBJECT DISENGAGED FROM TRIAL (BROKE FIXATION)
    % --------------------------------------------------------------------%
    
    case p.trial.(modName).states.BREAK_FIX
        nextState                   = p.trial.(modName).states.BREAK_FIX;
        p.trial.(modName).response.subjectResponse  = p.trial.(modName).response.BREAK_FIX;
        p.trial.pldaps.goodtrial    = false;
        p.trial.finished            = true;
        p.trial.flagNextTrial       = true; % tell PLDAPS to start next trial
        p.trial.(modName).states.timestamps.BREAK_FIX = p.trial.ttime;
        
    otherwise
        % you've entered an undefined state. This is a bug
        warning('YOU''VE REACHED AN UNDEFINED STATE IN taskSequence.m!!');
        
end

end