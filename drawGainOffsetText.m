function drawGainOffsetText(p, targetScreenPointer)
%
% 2017-11-16  YB   wrote it. <yoonbai@utexas.edu>
%

modName             = p.trial.modName;


x_text                  = sprintf('X: GAIN %1.2f   OFFSET %1.2f', p.trial.(modName).gaze.x_gain, p.trial.(modName).gaze.x_offset);
y_text                  = sprintf('Y: GAIN %1.2f   OFFSET %1.2f', p.trial.(modName).gaze.y_gain, p.trial.(modName).gaze.y_offset);
increment_size_text     = sprintf('increment size: GAIN %1.2f   OFFSET %1.2f', p.trial.(modName).gaze.gain_step_size, p.trial.(modName).gaze.offset_step_size);
%increment_size_text     = sprintf('time: %4.2f', p.trial.ttime*1000);

%Screen('TextSize',targetScreenPointer, 25);
% p.trial.display.clut.window
if(p.trial.eyeTrackerToggle == false) % adjust X
    Screen('TextSize',targetScreenPointer, 25);
    DrawFormattedText(targetScreenPointer, x_text, 50,  50, [255,   0,   0, 255]);
    Screen('TextSize',targetScreenPointer, 15);
    DrawFormattedText(targetScreenPointer, y_text, 50, 80, [255, 255, 255, 255]);
    %DrawFormattedText(targetScreenPointer, y_text, 50, 80, p.trial.display.clut.window);
else
    Screen('TextSize',targetScreenPointer, 15);
    DrawFormattedText(targetScreenPointer, x_text, 50,  50, [255, 255, 255, 255]);
    Screen('TextSize',targetScreenPointer, 25);
    DrawFormattedText(targetScreenPointer, y_text, 50, 80, [255,   0,   0, 255]);
end
% Screen('TextSize',targetScreenPointer, 14);
% DrawFormattedText(targetScreenPointer, increment_size_text, 50, 120, [255, 255, 255, 255]);

end 