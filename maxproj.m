function [Neg] = maxproj(e)
%takes a well number and returns max projection of that well

    MAX = uint8(zeros(551,551,2));
    MAX(:,:,1)=imread(strcat("data/well",num2str(e),"/croppedImage",num2str(e),"-1.png"));    
    for n=2:600 % use maxprojection to create background image
        I=imread(strcat('data/well',num2str(e),'/croppedImage',num2str(e),'-',num2str(n),".png"));
        MAX(:,:,2)=I;
        MAX= max(MAX,[],3);
        MAX(:,:,1) = MAX;
    end
    Neg = MAX(:,:,1);
end