%close all;
clear;
%addpath(genpath('../plot_conventions'));

% rig settings
% height_cm       = 30;
% viewing_cm      = 47;
% height_pixels   = 1024;
% half_visual_deg = atand( (height_cm/2) / viewing_cm);
% pixels_per_deg  = (height_pixels/2) / half_visual_deg;
pixels_per_deg  = 29.0070; % determined from rig

% stimulus conditions
annulus_ratio    = 6;
stim_diam_outer = [6, 24, 36];
stim_diam_inner = stim_diam_outer ./ annulus_ratio;
num_sizes       = length(stim_diam_outer);
image_diam_pix  = 512;
bg_lum          = 1/4;


% images
stim_folder     = './stimulus/stimselected-zoom1x/';
folder_structs  = dir(fullfile(stim_folder, 'movie*'));
folders         = {folder_structs.name};
num_movies      = numel(folders);

% types
NATURAL         = 1;
SYNTHETIC       = 2;
img_types       = [NATURAL, SYNTHETIC];
num_types       = numel(img_types); % natural & synthetics

% image filenames across all movie folders
num_frames      = 11;
filenames       = cell(num_types, 1);
% naturals
for i = 1:num_frames
    filenames{NATURAL}{i}   = sprintf('natural%02d.png', i);
end
% synthetics
 filenames{SYNTHETIC}{1}    = filenames{NATURAL}{1};
for i = 2:num_frames-1
    filenames{SYNTHETIC}{i} = sprintf('synthetic%02d.png', i);
end
 filenames{SYNTHETIC}{11}   = filenames{NATURAL}{11};

% output size index
FOVEAL              = 1;
PARAFOVEAL          = 2;
PERIPHERY           = 3;

% output folders
output_folders{FOVEAL}      = fullfile('./stimulus_revised/', 'diameter_06_deg');
output_folders{PARAFOVEAL}  = fullfile('./stimulus_revised/', 'diameter_24_deg');
output_folders{PERIPHERY}   = fullfile('./stimulus_revised/', 'diameter_36_deg');

% output image sizes
stim_diam_pixels    = floor(stim_diam_outer .* pixels_per_deg);
for i = 1:numel(stim_diam_pixels)
    if( mod(stim_diam_pixels(i), 2) == 0)
        stim_diam_pixels(i)  = stim_diam_pixels(i) + 1;
    end
end

for i = 1:num_movies

    for j = 1:num_types
    
        for k = 1:num_frames
            img_filepath    = [stim_folder, folders{i} '/', filenames{j}{k}];
            img             = im2double(imread(img_filepath));
            
            % first shrink image to foveal size
            foveal_img      = imresize(img, [stim_diam_pixels(FOVEAL), stim_diam_pixels(FOVEAL)], 'bicubic');
            i_output_folder = fullfile(output_folders{FOVEAL},folders{i});
            if(k == 1)
                mkdir(i_output_folder);
            end
            output_filepath = fullfile(i_output_folder, filenames{j}{k});
            imwrite(foveal_img, output_filepath);
            
            % parafoveal
            parafoveal_img  = imresize(foveal_img, 4, 'nearest');
            i_output_folder = fullfile(output_folders{PARAFOVEAL},folders{i});
            if(k == 1)
                mkdir(i_output_folder);
            end
            output_filepath = fullfile(i_output_folder, filenames{j}{k});
            imwrite(parafoveal_img, output_filepath);
            
            % periphery
            periphery_img   = imresize(foveal_img, 6, 'nearest');
            i_output_folder = fullfile(output_folders{PERIPHERY},folders{i});
            if(k == 1)
                mkdir(i_output_folder);
            end
            output_filepath = fullfile(i_output_folder, filenames{j}{k});
            imwrite(periphery_img, output_filepath);
            
%             % test code snippet for debugging
%             figure,anchor=172/2;ii=anchor:anchor+2,imagesc(foveal_img(ii,ii));axis square;
%             figure,ii=anchor*4-1*4+1:anchor*4+2*4,imagesc(parafoveal_img(ii,ii));axis square;
%             figure,ii=anchor*6-1*6+1:anchor*6+2*6,imagesc(periphery_img(ii,ii));axis square;
        end
    end
    
end