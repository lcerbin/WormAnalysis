%%
MAX = uint8(zeros(551,551,2));
for e = 33
    if ~exist(['./Try/well' int2str(e)], 'dir')
        mkdir(['./Try/well' int2str(e)]);
    end
    MAX(:,:,1)=imread(strcat("Cropped/well_",num2str(e),'/',num2str(e),".jpg"));
    for n=2:600 % use maxprojection to create background image
        I=imread(strcat("Cropped/well_",num2str(e),'/',num2str(n),".jpg"));
        MAX(:,:,2)=I;
        MAX= max(MAX,[],3);
        MAX(:,:,1) = MAX;
    end
    Neg = MAX(:,:,1);
    for v = 1:600
        filename = strcat("Cropped/well_",num2str(e),'/',num2str(v),".jpg");
        IM = uint8(255 * mat2gray(imcomplement((Neg-(imread(filename))))));
        Mask(IM);
        BinIM = IM <160;
        BinIM = bwmorph(BinIM,'hbreak', Inf);
        eroimg = imerode(BinIM, strel('disk', 1));
        eroimg = bwareaopen(eroimg, 10, 4);
        BinIM = imdilate(eroimg, strel('disk', 1));
        BinIM = bwareafilt(BinIM,1);
        BinIM = bwskel(BinIM);
        %[y, x] = find(BinIM);
%       BW4 = bwmorph(BW3, 'endpoints');
% 
%       [B,T] = find(BW4>0); %B,T give the coordinates of the endpoints of the skeletonized worm
%       Have user mark head for only the first frame, after that, calculate
%       distance from the last head position to keep correctly marking the
%       head. Run the shortest path algorithm from there?
        imwrite(BinIM, strcat('./Try/well',int2str(e),'/','croppedImageMaxed',num2str(e),'-',num2str(v),".png"));
    end
end
%% TESTING
%files for well 1 :   files = dir(strcat('croppedImage',1,'-*.*'));
IM = uint8(255 * mat2gray(imcomplement((Neg-(imread("Cropped/well_21/21.jpg"))))));
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