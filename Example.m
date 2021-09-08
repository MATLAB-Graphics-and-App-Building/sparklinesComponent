function Example()
% Example: Create sparklines using different data and styles. The following
% code is meant to demo some features and use cases for sparklines.

% Copyright 2021 The MathWorks, Inc.

    % Create a sparklines table for Danish stock returns, bond yields, 1922–1999.
    % This particular example requires the MATLAB Econometrics Toolbox to access the data. 
    tableData = load('Data_Danish').DataTable;

    % Read table data and call createUIobjects
    createUISparklinesGrid(tableData);

    % Generate a matrix of normal data. 
    normalDist = makedist('Normal', 'mu', 0, 'sigma', 1);
    Data = random(normalDist, 5, 10);

    % Create a column of solid sparklines for normally distrbuted data.
    % These sparklines are for the rows of the matrix, which is how sparklines 
    % are created by default. 
    createSolidSparklinesColumn(Data);

    % Create a row of solid sparklines for normally distributed data
    createSolidSparklinesRow(Data);

    % Created dashed sparklines with a gradient color style
    createDashedGradientSparklines(Data);

    % Create bar graph style sparklines with a gradient color style
    createBarGradientSparklines(Data);

    % Create solid blue dotted sparklines
    createSolidBlueDottedSparklines(Data);
end

% Create nested ui objects to demo how sparklines can be used to visualize
% data
function createUISparklinesGrid(tableData)
    numVariables = size(tableData, 2);
    
    % Create ui figure to contain ui objects which contain sparklinesComponents.
    % Adjust width and height of the uifigure.
    f = uifigure;
    f.Position(3:4) = [1200 330];
    
    % Create and populate grid for two side-by-side panels
    panelGrid = uigridlayout(f, [1 2]);
    panelGrid.ColumnWidth = {'fit', '1x'};
    leftPanel = uipanel(panelGrid);
    rightPanel = uipanel(panelGrid);
    
    % In the leftpanel, create a uigridlayout for the variable names,
    % sparklines, and plot buttons
    leftGridLayout = uigridlayout(leftPanel, [numVariables, 3]);
    leftGridLayout.ColumnWidth = {'fit','fit','fit'};
    leftGridLayout.RowHeight = repmat({'fit'},[numVariables, 1]);
    
    % In the right panel, create axes for plotting full-size graphs
    % corresponding to sparklines
    ax = uiaxes(rightPanel);
    ax.Position(3) = 800;
    
    % In the left panel, create sparklineComponents
    for colIdx = 1:numVariables
        % Create a column of variable names in the leftmost column
        varName = tableData.Properties.VariableNames{colIdx};
        uilabel(leftGridLayout,'Text', varName);
    
        % Create a column of sparklineComponents in the center column
        varData = tableData{:, colIdx};
        sparklinesComponent(leftGridLayout, 'Data', varData, ...
            'SparklinesLayout', 'row', ...
            'DataOrientation', 'column', ...
            'ColorStyle', 'gradient');
    
        % Create a plot button in the rightmost column
        uibutton(leftGridLayout, 'Text', 'Plot', ...
            'ButtonPushedFcn',@(o,e)plotThisData(o,e,ax,varData,varName));
    end
    
    function plotThisData(~,~,ax,data,label)
        delete(ax.Children);
        plot(ax, data, 'k');
        title(ax, label);
    end
end

% Create a column of solid color (black) sparklines from a matrix of data in a
% uifigure
function createSolidSparklinesColumn(Data)    
    f = uifigure;
    h = sparklinesComponent(f, 'Data', Data);
    f.Position = [0 0 210 300];
    h.Position = [0 0 210 300];
end

% Create a row of solid color (black) sparklines from a matrix of data in a
% uifigure
function createSolidSparklinesRow(Data) 
    f = uifigure;
    h = sparklinesComponent(f, 'Data', Data);
    f.Position = [0 0 1500 100];
    h.Position = [0 0 1500 100];

    % Change the property SparklinesLayout such that the sparklines are 
    % displayed in a row.
    h.DataOrientation = 'column';
    h.SparklinesLayout= 'row';
end

% Create dashed sparklines with a gradient color style
function createDashedGradientSparklines(Data)
    f = uifigure;
    h = sparklinesComponent(f, 'Data', Data);
    f.Position = [0 0 210 300];
    h.Position = [0 0 210 300];

    % Change the line style and color style of the sparklines.
    h.SparklineStyle = "dashed";
    h.ColorStyle = "gradient";
end

% Create bar graph style sparklines with a gradient color style
function createBarGradientSparklines(Data)
    f = uifigure;
    h = sparklinesComponent(f, 'Data', Data);
    f.Position = [0 0 210 300];
    h.Position = [0 0 210 300];

    % Change the line style and color style of the sparklines.
    h.SparklineStyle = "bar";
    h.ColorStyle = "gradient";
end

% Create solid blue dotted sparklines
function createSolidBlueDottedSparklines(Data)
    f = uifigure;
    h = sparklinesComponent(f, 'Data', Data);
    f.Position = [0 0 210 300];
    h.Position = [0 0 210 300];

    % Change the color, style, and width of the sparklines. 
    h.SparklineColor = [0 0 1];
    h.SparklineStyle = "dotted";
    h.LineWidth = 2;
end