clc;
clear all;

imageNames = dir(fullfile('../','Data','Training_Images_Macenko','*.bmp'));
labelNames = dir(fullfile('../','Data','Training_Images_Macenko_Labelled','*.bmp'));

boxSide = 51;
verbose=0;

roi = [];
nonRoiBoundary = [];
nonRoiInside = [];


for i = 1:size(imageNames,1)
    
    fprintf('%d. ============== working on image %s ==================\n',i,imageNames(i).name);
    
    image = imread(fullfile('../','Data','Training_Images_Macenko',imageNames(i).name));
    labelled_image = preprocessLabelledImage(image,imread(fullfile('../','Data','Training_Images_Macenko_Labelled',labelNames(i).name)),verbose);
    
    for angle = 0:10:170
        fprintf('Rotating %d degrees\n',angle);
        
        trainImage = rgb2gray(imrotate(image,angle));
        labelImage = im2bw(imrotate(labelled_image,angle));          

        % set the last parameter (verbose) to 1 to understand what this
        % function call is doing
        [labelImage boundaryImage insideImage] = getNonRoiPixels(trainImage,labelImage,boxSide,0);

        [roiPixels,nonRoiBoundaryPixels,nonRoiInsidePixels] = sendImage(insideImage,boundaryImage,labelImage,trainImage,boxSide);

        roi = cat(1,roi,roiPixels);
        nonRoiBoundary = cat(1,nonRoiBoundary, nonRoiBoundaryPixels);
        nonRoiInside = cat(1,nonRoiInside, nonRoiInsidePixels);        
    end   
    
end

% concatenate the data for three classes
X = cat(1,roi,nonRoiBoundary,nonRoiInside);

% Y is an nx3 matrix of labels.
%[1,0,0] indicates Roi, 
%[0,1,0] NonRoiBoundary
%[0,0,1] NonRoiInside
Y = zeros(size(X,1),3);
Y(1:size(roi,1),1) = 1;
Y(size(roi,1)+1:size(roi,1)+size(nonRoiBoundary,1),2) = 1;
Y(size(roi,1)+size(nonRoiBoundary,1)+1:end,3) = 1;

clearvars -except X Y

