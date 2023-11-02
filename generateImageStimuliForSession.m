function p = generateImageStimuliForSession(p)
% GENERATE images for this session (block)
%
%   YB   wrote it. <yoonbai@utexas.edu>
%
% 2018-09-05  SMS  repurposed it for psychophysical straightening study. <smshields@utexas.edu>


modName             = p.trial.modName;

deg2pix             = p.trial.display.ppd;
screenCenter        = p.trial.display.ctr;

%% screen center
x_0                 = screenCenter(1);
y_0                 = screenCenter(2);

x_deg               = p.trial.(modName).stimulus.image.location.X_DEG;
y_deg               = p.trial.(modName).stimulus.image.location.Y_DEG;

%% image dimensions 

% movie category/name/stimulus size

% frame indices
movie_frame_indices     = NaturalStraightening.CONSTANTS.FRAME_INDEX_PER_MOVIE;

% frame location
img_center_x            =  x_deg * deg2pix;
img_center_y            = -y_deg * deg2pix;

% all images are resized (using nearest neighbors) from foveal condition
foveal_outer_diam_deg         = NaturalStraightening.CONSTANTS.IMG_OUTER_DIAMETERS_DEG(1);
foveal_outer_diam_pixels      = round(foveal_outer_diam_deg * deg2pix);
foveal_inner_diam_deg         = NaturalStraightening.CONSTANTS.IMG_INNER_DIAMETERS_DEG(1);
foveal_inner_diam_pixels      = round(foveal_inner_diam_deg * deg2pix);


% frame size
stim_size_index         = unique(p.trial.sessionTrialMatrix(:,p.trial.sessionTrialMatrix_fields.STIM_SIZE));
inner_diam_deg          = NaturalStraightening.CONSTANTS.IMG_INNER_DIAMETERS_DEG(stim_size_index);
outer_diam_deg          = NaturalStraightening.CONSTANTS.IMG_OUTER_DIAMETERS_DEG(stim_size_index);
inner_diam_pixels       = round(inner_diam_deg * deg2pix);
outer_diam_pixels       = round(outer_diam_deg * deg2pix);
% % use odd numbers for image sizes in order to center images precisely
% if(mod(inner_diam_pixels,2) == 0)
%     inner_diam_pixels   = inner_diam_pixels + 1;
% end
% if(mod(outer_diam_pixels,2) == 0)
%     outer_diam_pixels   = outer_diam_pixels + 1;
% end

% fixation boundary (this is too hard for foveal tasks)
%p.trial.(modName).gaze.curr_window_radius_deg = (inner_diam_deg/2) * sqrt(2);% * 2 *sqrt(2);
%p.trial.(modName).gaze.curr_window_radius_deg = 2*sqrt(2)/2;

%  Outer vignette (in case original image is not vignetted)
flattop8                = im2double(imread(NaturalStraightening.CONSTANTS.MASK_FILE));
flattop8                = squeeze(flattop8(:,:,end));
flattop8                = flattop8 ./ max(flattop8(:));
outer_mask              = imresize(flattop8, [foveal_outer_diam_pixels, foveal_outer_diam_pixels]);

% Inner vignette (foveal image)
inner_mask              = ones(size(outer_mask));
padding_size            = round((foveal_outer_diam_pixels-foveal_inner_diam_pixels)/2);
inner_x                 = 1+padding_size : 1+padding_size+foveal_inner_diam_pixels-1;
inner_y                 = 1+padding_size : 1+padding_size+foveal_inner_diam_pixels-1;
inner_mask(inner_x, inner_y) = imresize(1-flattop8,[foveal_inner_diam_pixels, foveal_inner_diam_pixels]);

% pixel depth (grayscale steps)
pixelRange              = 2^NaturalStraightening.CONSTANTS.PIXEL_BIT_DEPTH;
bgIntensityNormalized   = p.trial.display.bgColor(end);

% Each block is restricted to a single movie & image size. 
movie_type              = unique(p.trial.sessionTrialMatrix(:,p.trial.sessionTrialMatrix_fields.MOVIE_TYPE));
movie_index             = unique(p.trial.sessionTrialMatrix(:,p.trial.sessionTrialMatrix_fields.MOVIE_NUM));
if(movie_type == NaturalStraightening.CONSTANTS.SYNTHETIC_TYPE)
    movie_index     = movie_index / NaturalStraightening.CONSTANTS.INDEX_DIFFERENCE; % correct for change made to indices to differentiate natural and synthetic movies
end
texture_pointers        = nan(length(movie_frame_indices), 1);

% apply vignette (if necessary) and save to texture pointers
for i = 1:length(texture_pointers)
    
    if(movie_type == NaturalStraightening.CONSTANTS.NATURAL_TYPE)
        img_filepath        = fullfile(NaturalStraightening.CONSTANTS.STIMULUS_FOLDER, ...
                                        NaturalStraightening.CONSTANTS.MOVIE_FOLDERS{movie_index}, ...
                                        NaturalStraightening.CONSTANTS.NATURAL_FRAMES{i});
    else
        img_filepath        = fullfile(NaturalStraightening.CONSTANTS.STIMULUS_FOLDER, ...
                                        NaturalStraightening.CONSTANTS.MOVIE_FOLDERS{movie_index}, ...
                                        NaturalStraightening.CONSTANTS.SYNTHETIC_FRAMES{i});
    end
    
    img                 = im2double(imread(img_filepath));
    % Center bg intensity to zero. Use image bg values in case 
    % background luminance is not identical to the desired bg intensity
    img                 = img - mean([img(1,1),img(1,end),img(end,1),img(end,end)]);
    
    % first shrink image to foveal size (using bicubic to avoid salient
    % pixels that can make discrimination too easy)
    foveal_img          = imresize(img, [foveal_outer_diam_pixels, foveal_outer_diam_pixels], 'bicubic');
       
    % NOTE: For this experiment, the outer vignette was already applied 
    % to all images. Only need to add inner vignette.
    % Therefore, no need to apply outer mask in this experiment.
    %img                 = img .* outer_mask;
    foveal_img          = foveal_img .* inner_mask;
    foveal_img          = foveal_img + bgIntensityNormalized;
    
    % resize image using nearest neighbors to preserve image information
    resize_ratio        = outer_diam_deg / foveal_outer_diam_deg;
    resized_img         = imresize(foveal_img, resize_ratio, 'nearest');
    resized_img         = uint8(resized_img .* pixelRange);
    texture_pointers(i) = Screen('MakeTexture', p.trial.display.ptr, resized_img);
    
end
theRect = [0 0 outer_diam_pixels outer_diam_pixels];

% pass this onto PLDAPS 
p.trial.(modName).stimulus.image.pointers   = texture_pointers;
p.trial.(modName).stimulus.image.srcRect    = CenterRectOnPoint(theRect, x_0, y_0);
p.trial.(modName).stimulus.image.dstRect    = OffsetRect(p.trial.(modName).stimulus.image.srcRect, img_center_x, img_center_y);

