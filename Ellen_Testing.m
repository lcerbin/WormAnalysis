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
%% TESTING
%files for well 1 :   files = dir(strcat('croppedImage',1,'-*.*'));
IM = uint8(255 * mat2gray(imcomplement((Neg-(imread("data/well21/croppedImage21-515.png"))))));
BinIM = IM <160;
%BinIM = bwmorph(BinIM, 'open');
eroimg = imerode(BinIM, strel('disk', 1));
eroimg = bwareaopen(eroimg, 10, 4);
BinIM = imdilate(eroimg, strel('disk', 1));
BinIM = bwmorph(BinIM,'hbreak', Inf);
BinIM = bwareafilt(BinIM,1);
BinIM = bwskel(BinIM);

branchPoints = bwmorph(BinIM, 'branchpoints');
branchSub = BinIM - branchPoints;
imshow(branchSub);
%branchSub = bwareafilt(logical(branchSub),1, 'smallest');
imshow(branchSub);

%BinIM = cutBranch(BinIM);
%BinIM = bwmorph(BinIM,'spur',Inf);
imwrite(MAX(:,:,1), "back.png");
imwrite(BinIM , "plan.png");

%(bwmorph(BinIM, 'thin', Inf)
%% SPLINE
I = imread("Try/croppedImageMaxed1-515.png");
F=sparse(I);
figure, spy(F);
%improfile(imread("Try/croppedImageMaxed21-1.png")), grid on
[y, x] = find(I);
figure, scatter(x,y)
