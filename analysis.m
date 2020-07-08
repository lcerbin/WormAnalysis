%First, get information on the file, it's easiest to interact through
%commandline
prompt = 'How many frames would you like to analyze? ';
frameNum = input(prompt);

prompt = 'Starting frame number? ';
start = input(prompt);

prompt = 'Ending frame number? ';
final = input(prompt);

prompt = 'Do you want to preprocess? (y/n) ';
response = input(prompt, 's');

fileStart = './6/';
if response == 'y'
    for i = start:final
        Preprocess([fileStart int2str(i) '.jpg'], i);
    end
end
    
%imageArray = cell(1, 48);  
%imshow(image);
%counter = 0;
%step 550 across the width from 500
%step 550 across height from 200
%for i = 500:550:4350
 %   for j = 200:550:2950
  %      counter = counter+1;
   %     newImage = imcrop(image, [i, j, 550, 550]);
    %    imageArray{counter} = newImage;
 %   end
%end

