function getKeyPress(p)
%
% 2017-11-20  YB   wrote it as "adjustGainOffsets.". <yoonbai@utexas.edu>
%
% 2018-09-13  SMS  repurposed it as "getKeyPress.m" for psychophysical
% straightening study. <smshields@utexas.edu>
%

modName         = p.trial.modName;

% subjectResponse keys
keyCode_left    = p.trial.keyboard.codes.Larrow;
keyCode_right   = p.trial.keyboard.codes.Rarrow;

if p.trial.keyboard.pressedQ
    % TO DO: consider using switch-case statements instead of multiple
    % if-else statements. Switch-cases are more efficient for single-event
    % key strokes.
    
    %% GAIN
    % check left arrow
    if(p.trial.keyboard.firstPressQ(keyCode_left))
        p.trial.(modName).response.subjectResponse  = p.trial.(modName).response.X_MATCHES_A;
    end
    
    % check right arrow
    if(p.trial.keyboard.firstPressQ(keyCode_right))
        p.trial.(modName).response.subjectResponse  = p.trial.(modName).response.X_MATCHES_B;
    end
    
end