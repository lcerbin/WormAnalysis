% Get the name of the file that the user wants to use.
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
%% 
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
%%
MAX = uint8(zeros(551,551,2));
for e = 21%:48
    MAX(:,:,1)=imread(strcat("data/well",num2str(e),"/croppedImage",num2str(e),"-1.png"));    
    for n=2:600 % use maxprojection to create background image
        I=imread(strcat('data/well',num2str(e),'/croppedImage',num2str(e),'-',num2str(n),".png"));
        MAX(:,:,2)=I;
        MAX= max(MAX,[],3);
        MAX(:,:,1) = MAX;
    end
    Neg = MAX(:,:,1);
    for v = 1:600
        filename = strcat('data/well',num2str(e),'/croppedImage',num2str(e),'-',num2str(v),".png")
        IM = uint8(255 * mat2gray(imcomplement((Neg-(imread(filename))))));
        BinIM = IM <160;
        BinIM = bwmorph(BinIM,'hbreak', Inf);
        eroimg = imerode(BinIM, strel('disk', 1));
        eroimg = bwareaopen(eroimg, 10, 4);
        BinIM = imdilate(eroimg, strel('disk', 1));
        BinIM = bwareafilt(BinIM,1);
        BinIM = bwskel(BinIM);
        imwrite(BinIM, strcat('Try/croppedImageMaxed',num2str(e),'-',num2str(v),".png"));
    end
end
%% TESTING Cleanup
%files for well 1 :   files = dir(strcat('croppedImage',1,'-*.*'));
IM = uint8(255 * mat2gray(imcomplement((Neg-(imread("data/well21/croppedImage21-526.png"))))));
BinIM = IM <160;
%BinIM = bwmorph(BinIM, 'open');
eroimg = imerode(BinIM, strel('disk', 1));
eroimg = bwareaopen(eroimg, 10, 4);
BinIM = imdilate(eroimg, strel('disk', 1));
BinIM = bwmorph(BinIM,'hbreak', Inf);
BinIM = bwareafilt(BinIM,1);
BinIM = bwskel(BinIM);

%% Find branchpoints (hopefully only ever 1) and remove
branchPoints = bwmorph(BinIM, 'branchpoints');
branchSub = BinIM - bwmorph(branchPoints, 'thicken');
imshow(branchSub);
hold on

[r, c] = find(branchPoints.' == 1);
position = [r, c];
plot(position(:,1), position(:,2), 'ro')

disp(position(:,1))
hold off
%% Find 3 nearest neighbours to branch point:
    imshow(branchSub);
    hold on
    plot(position(:,1), position(:,2), 'ro')
    [a,b] = find(branchSub.' == 1);
    nonzero = [a,b];
    [m,n] = size(nonzero);
    distances = [];
    for i = 1:m
        distances = [distances, sqrt((nonzero(i,1) - position(:,1))^2 + (nonzero(i,2) - position(:,2))^2)];
    end
n = 3;
val = zeros(n,1);
idx = zeros(n,1);
%find 3 points that are minimums of distances
for i=1:n
  [val(i),idx(i)] = min(distances);
  distances(idx(i)) = NaN;
end
plot(nonzero(idx(1),1), nonzero(idx(1),2), 'yo')
plot(nonzero(idx(2),1), nonzero(idx(2),2), 'go')
plot(nonzero(idx(3),1), nonzero(idx(3),2), 'bo')

%% Determine which point is on the main branch
    %Find line with largest area, determine which point (of three) is on
    %that line
%mainline = bwareafilt(logical(bwmorph(branchSub, 'endpoints')), 1);
mainline = bwareafilt(~(branchSub<1),1);
imshow(mainline);
hold on
plot(nonzero(idx(1),1), nonzero(idx(1),2), 'bo');
disp(nonzero(idx(1),1));
disp(nonzero(idx(1),2));
%% Define the Points
imshow(mainline)
hold on
plot(nonzero(idx(1),1), nonzero(idx(1),2), "ro")
plot(mainline(nonzero(idx(1),1), nonzero(idx(1),2)), "bo")
plot(mainline(nonzero(idx(1),1), nonzero(idx(1),2)), "bo")
disp(nonzero(idx(1),2))
if mainline(nonzero(idx(1),2), nonzero(idx(1),1)) == 1
    %then point one on mainline
    mainlinept = [nonzero(idx(1),2), nonzero(idx(1),1)];
    branchpt1 = [nonzero(idx(2),2), nonzero(idx(2),1)];
    branchpt2 = [nonzero(idx(3),2), nonzero(idx(3),1)];
   
elseif mainline(nonzero(idx(2),1), nonzero(idx(2),2)) ==1
    %then second point on mainline
    mainlinept = [nonzero(idx(2),2), nonzero(idx(2),1)];
    branchpt1 = [nonzero(idx(1),2), nonzero(idx(1),1)];
    branchpt2 = [nonzero(idx(3),2), nonzero(idx(3),1)];
else
    %then third point on mainline
    mainlinept = [nonzero(idx(3),2), nonzero(idx(3),1)];
    branchpt1 = [nonzero(idx(2),2), nonzero(idx(2),1)];
    branchpt2 = [nonzero(idx(1),2), nonzero(idx(1),1)];
end

imshow(branchSub)
hold on
plot(mainlinept(1,2), mainlinept(1,1), 'yo')
plot(branchpt1(1,2), branchpt1(1,1), 'go')
plot(branchpt2(1,2), branchpt2(1,1), 'bo')
%% Find angle between main branch point, branchpoint, and either branch
a = mainlinept;
b = [branchpt1; branchpt2];
c = [position(:,1), position(:,2)]; %original branch point

%compute the Euclidean norm of the vectors :
ab1=sqrt((b(1,2)-a(1,2))^2+(b(1,1)-a(1,1))^2);
ab2=sqrt((b(2,2)-a(1,2))^2+(b(2,1)-a(1,1))^2);
ac=sqrt((c(1,2)-a(1,2))^2+(c(1,1)-a(1,1))^2);

%Obtain the angle by :
angle1 = acos(dot([a(1,1) c(1,1)],[a(1,1) b(1,1)])/(ac*ab1))*180/pi;
angle2 = acos(dot([a(1,1) c(1,1)],[a(1,1) b(2,1)])/(ac*ab2))*180/pi;

%% OTher Try Angle
x0 = mainlinept(1,2);
y0 = mainlinept(1,1);
x1 = position(1,1);
y1 = position(1,2);
x2 = branchpt1(1,2);
y2 = branchpt1(1,1);
x3 = branchpt2(1,2);
y3 = branchpt2(1,1);

imshow(branchSub)
hold on
plot(x0, y0, 'bo')
plot(x1, y1, 'ro')
plot(x2, y2, 'yo')
plot(x3, y3, 'go')

x10 = x1-x0;
y10 = y1-y0;
x20 = x2-x0;
y20 = y2-y0; 
x30 = x3-x0;
y30 = y3-y0; 

ang2 = atan2(abs(x10*y20-x20*y10),x10*y10+x20*y20)*180/pi;
ang3 = atan2(abs(x10*y30-x30*y10),x10*y10+x30*y20)*180/pi;
%% SPLINE
I = imread("Try/croppedImageMaxed1-515.png");
F=sparse(I);
figure, spy(F);
%improfile(imread("Try/croppedImageMaxed21-1.png")), grid on
[y, x] = find(I);
figure, scatter(x,y)
