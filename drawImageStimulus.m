function drawImageStimulus(p)
% DRAWIMAGESTIMULUS draws the current image (texture pointer in PTB jargon) 
% specified by 'p.trial.(modName).states.current_img_index'
%
% 2018-05-15  YB   wrote it. <yoonbai@utexas.edu>
%

modName                 = p.trial.modName;
current_image_idx       = p.trial.(modName).states.current_img_index;

% % when using 'generateImageStimuliForTrial.m'
% Screen('DrawTextures', p.trial.display.ptr, ...
%     p.trial.(modName).stimulus.image.pointers(current_image_idx), ...
%     [], ...%p.trial.(modName).stimulus.image.srcRect, ...
%     p.trial.(modName).stimulus.image.dstRect);

% when using 'generateImageStimuliForSession.m'

texturePtrIndex = p.trial.sessionTrialMatrix( ...
    p.trial.(modName).sessionTrialIndex, ...
    p.trial.sessionTrialMatrix_fields.A_FRAMES+current_image_idx-1 );
  

Screen('DrawTextures', p.trial.display.ptr, ...
    p.trial.(modName).stimulus.image.pointers(texturePtrIndex), ...
    [], ...%p.trial.(modName).stimulus.image.srcRect, ...
    p.trial.(modName).stimulus.image.dstRect);

