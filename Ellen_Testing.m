%% Initialize all folders
%Get the names of the files that the user wants to use.
resultsFolder = uigetdir(pwd,"Select Folder to Put Results Into:");
cd(resultsFolder);
% makes news folder inside user specified folder
mkdir data;
cd("data");
for i = 1:48
    mkdir(strcat("well",num2str(i)));
end
cd ..;
datafile = uigetdir(pwd,"Select Folder with Data Folder:");
scripts = uigetdir(pwd,"Select Folder with Matlab Functions Folder:");

%% Crop all images and save to folders 1-48
%step 550 across the width from 500 (to 4350)
%step 550 across height from 200 (to 2950)
counter=1;
frame = 0;
%for each large image
for m = 1:600
    frame = frame+1;
    filename = strcat(datafile,'/',num2str(m),'.jpg');
    image = imread(filename);
    for i = 500:550:4350
        for j = 200:550:2950
            Cropped = imcrop(image, [i, j, 550, 550]);
            newfilename = strcat("data/well", num2str(counter),"/croppedImage",num2str(counter),"-",num2str(frame),".png")
            imwrite(Cropped, newfilename);
            counter = counter+1;
            if counter>48
                counter=1;
            end
            %imageArray(1:counter) = Cropped;
            %imshow(newImage) 
        end
    end
end


%% Collecta all COM, Speed, Axes, etc.
%dataOut = ["Time (s)", "COM x-coordinate (px)", "COM y-coordinate (px)", "Speed (mm/s)", "Major Axis (px)", "Minor Axis (px)", "Area (px)", "Perimeter (px)", "Min Feret Diameter (px)", "Max Feret Diameter px)", "Spline Length (px)", "Distance between Endpoints (px)"];

for i = 1:600
    dataOut(i+1,1) = [i*0.2]; %frame number
    IM = imread(strcat('Try/croppedImageMaxed',num2str(20),'-',num2str(i),".png"));
    s = regionprops (IM, 'MajorAxisLength','MinorAxisLength', 'Centroid', 'Area', 'Perimeter', 'MinFeretProperties', 'MaxFeretProperties');
    
    disp(i);
    major = s.MajorAxisLength;
    minor = s.MinorAxisLength;
    centroid = s.Centroid;
    area = s.Area;
    perimeter  =s.Perimeter;
    minferet = s.MinFeretDiameter;
    maxferet = s.MaxFeretDiameter;

    dataOut(i+1,2) = [centroid(1,1)];
    dataOut(i+1,3) = [centroid(1,2)];
    dataOut(i+1,4) = [speed];
    dataOut(i+1,5) = [major];
    dataOut(i+1,6) = [minor];
    dataOut(i+1,7) = [area];
    dataOut(i+1,8) = [perimeter];
    dataOut(i+1,9) = [minferet];
    dataOut(i+1,10) = [maxferet];
end

for i = 1:600
    if i==600
        dataOut(i+1,4) = NaN;
    else
        dataOut(i+1,4) = sqrt((str2num(dataOut(i+1,2)) - str2num(dataOut(i+2, 2)))^2 + (str2num(dataOut(i+1,3)) - str2num(dataOut(i+2, 3)))^2)/73/0.2;
    end
    disp(i)
end
%% Collect all spline parameters
well = 20;
Neg = maxproj(well);
for i = 1:600
    im = imread(strcat("data/well", num2str(well),"/croppedImage", num2str(well), "-", num2str(i), ".png"));
    IM = uint8(255 * mat2gray(imcomplement(Neg-im)));
    
    BinIM = IM <140;
    %BinIM = bwmorph(BinIM, 'open');
    %eroimg = imerode(BinIM, strel('disk', 1));
    %eroimg = bwareaopen(eroimg, 10, 4);
    %BinIM = imdilate(eroimg, strel('disk', 1));
    %BinIM = bwmorph(BinIM,'hbreak', Inf);
    BinIM = bwareafilt(BinIM,1);
    BinIM = imfill(BinIM, 'holes');
    BinIMf = bwskel(BinIM);
    
    %get rid of branch if there is one
    BinIM_nobranch = noBranch(BinIM);
    [spline, endpoints] = extend(BinIM, BinIM_nobranch); %extend nonbranched spline
    
    %convert to binary image and back to points
    binaryImage = false(551, 551);
    for k = 1 : length(spline(:,1))
        row = round(spline(k,2));
        col = round(spline(k,1));
        binaryImage(row, col) = true;
    end
    [a,b] = find(binaryImage.' == 1); %get array of points on extended spline
    extendedSpline = [a,b];

    [calcLength, ~] = size(extendedSpline);
    dataOut(i+1,11) = [calcLength];
    
    calcDistend = sqrt((endpoints(1,1)-endpoints(1,2))^2 + (endpoints(2,1)-endpoints(2,2))^2);
    dataOut(i+1,12) = [calcDistend];
    
    wantDisp = 1; %make 0 if not want to show every image
    if wantDisp == 1
        disp(i)
        imshow(BinIM)
        hold on
        scatter(extendedSpline(:,1), extendedSpline(:,2), 'r.');
        lightBlue = [91, 207, 244] / 255; 
        scatter(endpoints(:,1), endpoints(:,2), 'o', 'b', 'MarkerFaceColor', lightBlue);
        pause(0.5);
    end
end

%% Save dataOut as file


%% Use to show one well at one timepoint
    well = 20;
    frame = 109;
    im = imread(strcat("data/well", num2str(well),"/croppedImage", num2str(well), "-", num2str(frame), ".png"));
    Neg = maxproj(well);
    IM = uint8(255 * mat2gray(imcomplement(Neg-im)));
    BinIM = IM <140;
    %BinIM = bwmorph(BinIM, 'open');
    %eroimg = imerode(BinIM, strel('disk', 1));
    %eroimg = bwareaopen(eroimg, 10, 4);
    %BinIM = imdilate(eroimg, strel('disk', 1));
    %BinIM = bwmorph(BinIM,'hbreak', Inf);
    BinIM = bwareafilt(BinIM,1);
    BinIM = imfill(BinIM, 'holes');
    BinIMf = bwskel(BinIM);
   
    BinIM_nobranch = noBranch(BinIM);
    [spline, endpoints] = extend(BinIM, BinIM_nobranch);
    
    f1 = figure;
    f2 = figure;
    figure(f1);
    imshow(BinIM)
    hold on
    %scatter(nonzero(:,1), nonzero(:,2), 'r.');
    scatter(spline(:,1), spline(:,2), 'r.');
    lightBlue = [91, 207, 244] / 255; 
    scatter(endpoints(:,1), endpoints(:,2), 'o', 'b', 'MarkerFaceColor', lightBlue);
    hold off

    figure(f2);
    imshow(IM);
    hold on
    %scatter(nonzero(:,1), nonzero(:,2), 'r.');
    scatter(spline(:,1), spline(:,2), 'r.');

%% ALL FUNCTIONS: