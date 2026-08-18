function result = import_cad_model(options)
%IMPORT_CAD_MODEL Import the SolidWorks assembly into Simscape Multibody.
%   The import stops when SolidWorks reports unsupported mates unless
%   AllowExportWarnings is explicitly enabled for diagnostic work.

arguments
    options.AllowExportWarnings (1,1) logical = false
    options.ModelName (1,1) string = "rotating_pendulum_cad"
    options.Overwrite (1,1) logical = false
end

thisFolder = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(thisFolder));
exportFolder = fullfile(projectRoot, 'estrutura cad', ...
    'corrected-solidworks', 'simscape-export-corrected');
xmlFile = fullfile(exportFolder, 'rotating_disk_pendulum_corrected.xml');

assert(isfile(xmlFile), 'rotpend:cad:MissingXML', ...
    'CAD export not found: %s', xmlFile);

errorFiles = dir(fullfile(exportFolder, '*error*.txt'));
exportReport = "";
for index = 1:numel(errorFiles)
    report = strtrim(string(fileread(fullfile( ...
        errorFiles(index).folder, errorFiles(index).name))));
    if strlength(report) > 0
        exportReport = exportReport + newline + report;
    end
end
exportReport = strtrim(exportReport);

if strlength(exportReport) > 0 && ~options.AllowExportWarnings
    error('rotpend:cad:ExportWarnings', ...
        ['SolidWorks reported unsupported mates. Correct them and export ' ...
         'the assembly again before importing:\n\n%s'], exportReport);
end

outputFolder = fullfile(thisFolder, 'cad_import_final');
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end

stepFiles = dir(fullfile(exportFolder, '*.STEP'));
assert(~isempty(stepFiles), 'rotpend:cad:MissingGeometry', ...
    'No STEP geometry files were found in: %s', exportFolder);
for index = 1:numel(stepFiles)
    copyfile(fullfile(stepFiles(index).folder, stepFiles(index).name), ...
        fullfile(outputFolder, stepFiles(index).name), 'f');
end

modelFile = fullfile(outputFolder, options.ModelName + ".slx");
dataFileName = options.ModelName + "_data";
dataFile = fullfile(outputFolder, dataFileName + ".m");

if (isfile(modelFile) || isfile(dataFile)) && ~options.Overwrite
    error('rotpend:cad:OutputExists', ...
        ['Generated CAD model already exists. Use Overwrite=true only ' ...
         'after checking that the new export is ready.']);
end

if options.Overwrite
    deleteIfPresent(modelFile);
    deleteIfPresent(dataFile);
end

originalFolder = pwd;
folderCleanup = onCleanup(@() cd(originalFolder));
cd(outputFolder);

[modelHandle, generatedDataFile] = smimport(xmlFile, ...
    'ModelName', char(options.ModelName), ...
    'DataFileName', char(dataFileName), ...
    'ModelSimplification', 'none');
modelCleanup = onCleanup(@() closeLoadedModel(modelHandle));
pathCallback = [ ...
    "modelFolder = fileparts(get_param(bdroot, 'FileName')); " ...
    "if isfolder(modelFolder), addpath(modelFolder); end; " ...
    "clear modelFolder"];
set_param(modelHandle, 'PostLoadFcn', char(pathCallback));
set_param(modelHandle, 'SignalLogging', 'off', 'SaveOutput', 'off');
save_system(modelHandle, modelFile);

result = struct( ...
    'modelFile', string(modelFile), ...
    'dataFile', string(fullfile(outputFolder, generatedDataFile + ".m")), ...
    'xmlFile', string(xmlFile), ...
    'exportReport', exportReport);
end

function deleteIfPresent(fileName)
if isfile(fileName)
    delete(fileName);
end
end

function closeLoadedModel(modelHandle)
try
    modelName = get_param(modelHandle, 'Name');
catch
    return
end
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
end
