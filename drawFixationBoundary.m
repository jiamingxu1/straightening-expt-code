function drawFixationBoundary(p)
%
% 2017-11-16  YB   wrote it. <yoonbai@utexas.edu>
%

modName                 = p.trial.modName;

deg2pix                 = p.trial.display.ppd;

% Need to translate coordinate w.r.t. screen center
screenCenter            = p.trial.display.ctr;
x_0                     = screenCenter(1);
y_0                     = screenCenter(2);

% NOTE: you have to use 'p.trial.display.clut.window' for
% the color in your overlay window
color                   = p.trial.display.clut.window;
fixWindowRect           = [0, 0, ...
                            p.trial.(modName).gaze.curr_window_radius_deg * deg2pix * 2, ...
                            p.trial.(modName).gaze.curr_window_radius_deg * deg2pix * 2];


                        
fp_x_pixels             = p.trial.(modName).stimulus.fp.location.X_DEG * deg2pix + x_0;
fp_y_pixels             = y_0 - p.trial.(modName).stimulus.fp.location.Y_DEG * deg2pix;
centeredFixWindowRect   = CenterRectOnPointd(fixWindowRect, ...
                            fp_x_pixels, ...
                            fp_y_pixels);


%Screen('FrameOval',p.trial.display.overlayptr, color, centeredFixWindowRect) ;
Screen('FrameOval',p.trial.display.ptr, [1 1 1], centeredFixWindowRect) ;

end