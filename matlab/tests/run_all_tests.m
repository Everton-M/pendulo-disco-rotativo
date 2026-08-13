function results = run_all_tests()
%RUN_ALL_TESTS Add project code to the path and run the test suite.
testsDirectory = fileparts(mfilename('fullpath'));
matlabRoot = fileparts(testsDirectory);
addpath(matlabRoot);
results = runtests(testsDirectory, 'IncludeSubfolders', true);
disp(table(results));
assertSuccess(results);
end
