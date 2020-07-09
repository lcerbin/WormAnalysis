function [maskImg] = Mask(inputImg)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    circleCenterX = 300;
    circleCenterY = 250;
    circleRadius = 210;
    [rows, columns, channels] = size(inputImg);
    circleImage = false(rows, columns); 
    [x, y] = meshgrid(1:columns, 1:rows); 
    circleImage((x - circleCenterX).^2 + (y - circleCenterY).^2 <= circleRadius.^2) = true;
    maskImg = inputImg; % Initialize with the entire image.
    maskImg(~circleImage) = 0; % Zero image outside the circle mask.
end

