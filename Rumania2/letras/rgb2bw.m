% Pone a todos los archivos un nombre con un numero creciente

cd 3/
%% Lista todos los archivos con la extension ".jpg"
files = dir('*.jpg');

%%  Renombra los archivos en el directorio
for num_file = 1:length(files) % Ciclo para cada archivo
    I = imread(files(num_file).name);  
    imwrite(I(:,:,1), files(num_file).name);  
end

cd ..