% Alexnet support package support for MATLAB Compiler.
classdef AlexNetPackageInfo < matlab.addons.internal.SupportPackageInfoBase
    
    methods        
        function obj = AlexNetPackageInfo()
            obj.baseProduct = 'Neural Network Toolbox';            
            obj.displayName = 'Neural Network Toolbox Model for AlexNet Network';
            obj.name        = 'Neural Network Toolbox Model for AlexNet Network';
           
            sproot = matlabshared.supportpkg.getSupportPackageRoot();
 
            % Define all the data that should be deployed from the support
            % package. This includes the actual language data, which will
            % be archived in the CTF.
            obj.mandatoryIncludeList = {...
                    fullfile(sproot, 'toolbox','nnet','supportpackages','alexnet','+nnet') ...
					fullfile(sproot, 'toolbox','nnet','supportpackages','alexnet','data','alexnet.mat') }; 
            
            % Specify that the alexnet.mat data file should only be
            % suggested in the deploy app if the alexnet.m file is used in
            % the application code. Otherwise, there is no need to mention
            % it.
            obj.conditionalIncludeMap = containers.Map;
            obj.conditionalIncludeMap(fullfile(toolboxdir('nnet'), 'cnn', 'alexnet.m')) = {};
                            
        end
    end
end
