function drawFixationPoint(p, color_index)
% DRAWFIXATIONPOINT draws the fixation point. If color is not specified,
% default color is white. Value of 'color' is defined in the 'TrialMatrix'.
%
% 2017-11-16  YB   wrote it. <yoonbai@utexas.edu>
%
% 2018-09-13  SMS  repurposed it for psychophysical straightening study. <smshields@utexas.edu>
%

if nargin < 2 
    color_index = 8;
end
colorVec = p.trial.display.monkeyCLUT(color_index,:);

% Need to translate coordinate w.r.t. screen center
screenCenter            = p.trial.display.ctr;
x_0                     = screenCenter(1);
y_0                     = screenCenter(2);

% draw fixation point
modName                 = p.trial.modName;
deg2pix                 = p.trial.display.ppd;

fp_diameter_deg         = p.trial.(modName).stimulus.fp.size.curr_diameter_deg;
fixPointRect            = [0, 0, ...
                        fp_diameter_deg * deg2pix, ...
                        fp_diameter_deg * deg2pix];

donutRect               = [0, 0, ...
                        2*fp_diameter_deg * deg2pix, ...
                        2*fp_diameter_deg * deg2pix];
                    
fp_x_pixels             = p.trial.(modName).stimulus.fp.location.X_DEG * deg2pix + x_0;
fp_y_pixels             = y_0 - p.trial.(modName).stimulus.fp.location.Y_DEG * deg2pix;
centeredFixPointRect    = CenterRectOnPointd(fixPointRect, ...
                            fp_x_pixels, ...
                            fp_y_pixels);

centeredDonutRect       = CenterRectOnPointd(donutRect, ...
                            fp_x_pixels, ...
                            fp_y_pixels);

blackColor              = p.trial.display.monkeyCLUT(10,:);

if(p.trial.(modName).stimulus.fp.shape.current == p.trial.(modName).stimulus.fp.shape.SQUARE)
    Screen('FillRect', p.trial.display.ptr, colorVec, centeredFixPointRect);
elseif(p.trial.(modName).stimulus.fp.shape.current == p.trial.(modName).stimulus.fp.shape.CIRCLE)
    Screen('FillOval', p.trial.display.ptr, blackColor, centeredDonutRect);
    Screen('FillOval', p.trial.display.ptr, colorVec,   centeredFixPointRect);
%     if (p.trial.(modName).states.current_state ~= p.trial.(modName).states.REPORT)
%         Screen('FillOval', p.trial.display.ptr, blackColor, centeredDonutRect);
%         Screen('FillOval', p.trial.display.ptr, colorVec, centeredFixPointRect);
%     elseif  (p.trial.(modName).states.current_state == p.trial.(modName).states.REPORT)
%         Screen('FillOval', p.trial.display.ptr, [1 1 1], centeredDonutRect);
%         Screen('FillOval', p.trial.display.ptr, [1 1 1], centeredFixPointRect);
%     end
end

end