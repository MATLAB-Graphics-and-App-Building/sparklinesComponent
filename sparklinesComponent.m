classdef (Sealed) sparklinesComponent < matlab.ui.componentcontainer.ComponentContainer
% sparklinesComponent  Create small graphs which show the general trend of data.
% 
%   sparklinesComponent('Data',data) Create small graphs which show the 
%   general trend of the data in each row or column. By default the 
%   sparklines summarize each row and are stacked as a column.
%
%   sparklinesComponent(___,Name,Value) specifies additional options for 
%   the sparklineComponent using one or more name-value pair arguments. 
%
%   sparklinesComponent(parent,___) create the sparkline component in the 
%   specified ui parent (e.g. uifigure, uigridlayout, etc.).
%
%   h = sparklinesComponent(___) returns the sparklineComponent object. 
%   Use h to modify properties of the component after creating it.
%
% Copyright 2021 The MathWorks, Inc.

    properties
        Data (:,:) double = []
        DataOrientation (1,1) string {mustBeMember(DataOrientation, {'row', 'column'})} = 'row';
        SparklinesLayout (1,1) string {mustBeMember(SparklinesLayout, {'row', 'column'})} = 'column'
        ColorStyle (1,1) string {mustBeMember(ColorStyle, {'gradient', 'solid'})} = 'solid'
        SparklineColor (:,:) {validatecolor(SparklineColor)} = [0 0 0]
        LimitColors (2,3) {mustBeNumeric} = [1 0 0; 0 0 1]
        LineWidth (1,1) double {mustBeScalarOrEmpty} = 1;
        SparklineStyle (1,1) string {mustBeMember(SparklineStyle, {'line', 'bar', 'dotted', 'dashed'})} = 'line'
    end

    properties(Access=private, Transient, NonCopyable)
        % Height and width of each sparkline uihtml component
        SparklineWidth double {mustBeScalarOrEmpty} = 210;
        SparklineHeight double {mustBeScalarOrEmpty} = 50;

        % uigridlayout which contains all sparkline uihtml components
        LinesGrid matlab.ui.container.GridLayout
    end

    events (HasCallbackProperty, NotifyAccess=protected)
        DataChanged
    end

    methods (Access=protected)
        function setup(obj)
            % Grid to contain sparklines
            obj.LinesGrid = uigridlayout(obj, 'Padding', 0);
        end

        function update(obj)
            % If data is empty, delete existing lines and return the empty grid
            if isempty(obj.Data)
                delete(obj.LinesGrid.Children)
                return
            end

            % Display a warning if DataOrientation does not match with
            % the standard SparklinesLayout
            if strcmp(obj.DataOrientation, 'row') && ~strcmp(obj.SparklinesLayout, 'column')
                warning(['Sparklines summarize data in each ' ...
                    'row of the Data property and are arranged in a row.'], 'dimensionsWarning');
            elseif strcmp(obj.DataOrientation, 'column') && ~strcmp(obj.SparklinesLayout, 'row')
                warning(['Sparklines summarize data in each ' ...
                    'column of the Data property and are arranged in a column.'], 'dimensionsWarning');
            end

            % Set background color of LinesGrid to be the same as the
            % parent background color
            obj.LinesGrid.BackgroundColor = obj.BackgroundColor;
            obj.LinesGrid.Scrollable = 'on';
            
            % If the color mode is 'gradient', determine the minimimum and
            % maximum values of the matrix
            minVal = min(obj.Data, [], 'all');
            maxVal = max(obj.Data, [], 'all');

            % Determine the number of sparklines to be drawn
            if strcmp(obj.DataOrientation, 'row')
                nLinesNeeded = size(obj.Data, 1);
            elseif strcmp(obj.DataOrientation, 'column')
                nLinesNeeded = size(obj.Data, 2);
            end

            % Determine the dimensions of the sparklines grid
            if strcmp(obj.SparklinesLayout, 'column')
                nLinesHave = numel(obj.LinesGrid.Children);
            elseif strcmp(obj.SparklinesLayout, 'row')
                nLinesHave = numel(obj.LinesGrid.Children);
            end

            % Create space for extra lines as needed
            linesGrid = obj.LinesGrid;
            
            % Create extra lines as needed
            for n = nLinesHave+1:nLinesNeeded
                sparkline = uihtml(linesGrid);

                if strcmp(obj.SparklinesLayout, 'column')
                    sparkline.Layout.Row = n;
                    sparkline.Layout.Column = 1;
                else
                    sparkline.Layout.Row = 1;
                    sparkline.Layout.Column = n;
                end

                sparkline.HTMLSource = fullfile(fileparts(mfilename('fullpath')), 'sparkline.html');
            end
            
            % Update data for sparklines
            for i = 1:nLinesNeeded
                sparkline = linesGrid.Children(i);

                % Data to create the ith sparkline
                if strcmp(obj.DataOrientation, 'row')
                    DataVector = obj.Data(i, :);
                else
                    DataVector = obj.Data(:, i);
                end

                % Change data of htmlComponent
                sparkline.Data = {obj.SparklineStyle, ...
                    obj.ColorStyle, ...
                    obj.LimitColors(1, :), obj.LimitColors(2, :), ...
                    minVal, maxVal, ...
                    obj.SparklineColor, ...
                    obj.LineWidth, ...
                    DataVector};
            end

            % Delete unneeded lines
            delete(linesGrid.Children((nLinesNeeded + 1):numel(linesGrid.Children)));

            obj.LinesGrid = linesGrid;

            % Adjust sparklines grid height and width
            if strcmp(obj.SparklinesLayout, 'column')
                rowHeights = cell(1, nLinesNeeded);
                rowHeights(:) = {obj.SparklineHeight};
                obj.LinesGrid.RowHeight = rowHeights;

                obj.LinesGrid.ColumnWidth = {obj.SparklineWidth};
            elseif strcmp(obj.SparklinesLayout, 'row')
                colWidths = cell(1, nLinesNeeded);
                colWidths(:) = {obj.SparklineWidth};
                obj.LinesGrid.ColumnWidth = colWidths;

                obj.LinesGrid.RowHeight = {obj.SparklineHeight};
            end
        end
        
    end

    methods
        function set.Data(obj, val)
            obj.Data = val;
            notify(obj, 'DataChanged')
        end

        function set.SparklineColor(obj, color)
            obj.SparklineColor = validatecolor(color);
        end
    end

end