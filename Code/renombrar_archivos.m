% Pone a todos los archivos un nombre con un numero creciente

cd I/
%% Lista todos los archivos con la extension ".jpg"
files = dir('*.png');

%%  Renombra los archivos en el directorio
for num_file = 1:length(files) % Ciclo para cada archivo
    [~, filename] = fileparts(files(num_file).name); % Obtiene el nombre sin la extension
    try
        if ~strcmp(strtok(filename,'_'),'HD')
            if num_file == 1
                disp(' ** Renombrando los archivos');
            end
            movefile(files(num_file).name, sprintf('%d.jpg', num_file)); % Renombra los archivos
            if num_file == length(files)
                fprintf(' *** Un total de: %d archivos han sido renombrados \n', num_file);
            end
        else
            if num_file == 1
                disp(' **** Ya los archivos tienen el nombre correcto');
            end
        end
    catch
        disp(' **** Ya los archivos tienen el nombre correcto � ha ocurrido un error renombrando los archivos');
        break;
    end
end

cd ..