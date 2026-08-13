function results = run_all_tests()
%RUN_ALL_TESTS Run every automated test in this project.
matlabRoot = fileparts(mfilename('fullpath'));
testsDirectory = fullfile(matlabRoot, 'tests');
addpath(matlabRoot);
results = runtests(testsDirectory, 'IncludeSubfolders', true);
disp(table(results));
assertSuccess(results);
end
