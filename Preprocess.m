function [output] = Preprocess(filename, frame) 
    image = imread(filename);
    if ~exist('./Cropped', 'dir')
        mkdir('Cropped')
    end
    counter = 0;
    for i = 500:550:4350
        for j = 200:550:2950
            counter = counter+1;
            if(frame == 1)
                mkdir(['./Cropped/well_' int2str(counter)]);
            end
            newImage = imcrop(image, [i, j, 550, 550]);
            saveName = ['./Cropped/well_' int2str(counter) '/' int2str(frame) '.jpg'];
            imwrite(newImage, saveName);
        end
    end
    output = 200;
