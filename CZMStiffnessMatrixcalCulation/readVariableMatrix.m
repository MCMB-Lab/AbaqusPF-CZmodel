function matrixData = readVariableMatrix(filename)
    % Function to read data from a file with varying row lengths
    % and store it in a matrix, padding shorter rows with NaN.
    %
    % Usage: matrixData = readVariableMatrix('yourfile.txt');
    
    % Open the file for reading
    fileID = fopen(filename, 'r');
    
    % Initialize an empty cell array to store rows
    data = {}; 
    line = fgetl(fileID); % Read the first line
    
    % Loop through each line in the file
    while ischar(line)
        % Use textscan to read each line of data
        row = textscan(line, '%f', 'Delimiter', {',', ' '}, 'MultipleDelimsAsOne', 1);
        data{end+1} = row{1}'; % Store the row as a row vector in the cell array
        line = fgetl(fileID); % Move to the next line
    end

    % Close the file
    fclose(fileID);

    % Find the maximum number of columns in any row
    maxCols = max(cellfun(@length, data));

    % Preallocate a matrix with NaN for missing values
    matrixData = NaN(length(data), maxCols);

    % Fill the matrix with data from the cell array
    for i = 1:length(data)
        matrixData(i, 1:length(data{i})) = data{i};
    end
end
