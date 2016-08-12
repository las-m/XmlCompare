%Class that represents Channels of the xmls. I mainly use an object 
%oriented approach here because its easier for other people to work with
%it. (And for me if I did not work on this project for while)
classdef Channel < handle
    
    properties (SetAccess = private)
        Name %Channel name
        IsPlotted %Indicates if a plot exists 
        Xml1Data %The array with the data from xml1
        Xml2Data %The array with the data from xml2
        Difference %=Xml1Data - Xml2Data
        Color %Color for all three Plots
        Offset %Offset for all three Plots
        Scale %Scale factor for all three Plots
        IsDivergent %Indicates if Xml1Data diverges from Xml2Data
        Plot1 %Plot of Xml1Data
        Plot2 %Plot of Xml2Data
        PlotDiff %Plot of logical(Difference)
        PlotDiffValue %Value with which the difference will get plotted
        cycleTimeDiff %Logical; Idicates if cycle time of the xmls differs
    end
    
    methods
        
        %Constructor of the Channel
        function obj = Channel(name,color,offset,scale, diffValue, data1, data2, cycleTimeDiff)
            
            %Store the to the constructor passed variables in properties
            obj.cycleTimeDiff = cycleTimeDiff;
            obj.Name = name;
            obj.Color = color;
            obj.Offset = offset;
            obj.Scale = scale;
            obj.Xml1Data = data1;
            obj.Xml2Data = data2;
            
            %Pad the shorter data array with zeros till the arrays are of
            %same length
            size1 = size(obj.Xml1Data);
            size2 = size(obj.Xml2Data);
            sizeDifference = size1(2) - size2(2);
            if cycleTimeDiff && sizeDifference > 0
                obj.Xml2Data = transpose(cat(1,transpose(obj.Xml2Data),transpose(zeros(1,abs(sizeDifference)))));
            elseif cycleTimeDiff && sizeDifference < 0
                obj.Xml1Data = transpose(cat(1,transpose(obj.Xml1Data),transpose(ones(1,abs(sizeDifference)))));
            end
            
            %On construction the channeldata is not plotted
            obj.IsPlotted = 0;
            obj.PlotDiffValue = diffValue;
            
            %Try to get the difference of the data arrays from xml1 and
            %xml2. Fails if the arrays have different length. This case 
            %should only occur if the the cycledurations are the same and
            %the time resoltuin differs. The case that the arrays have
            %different durations and the time resolution differs is not
            %handled. 
            try 
                obj.Difference = abs(obj.Xml1Data - obj.Xml2Data);
            catch
                warndlg('The vectors representing the channeldata are differently sized and can not be compared. The reason is most likely a difference in the time resolution used in the xml files.')
            end
            
            %Test if the channels data diverges. If so set the property
            %IsPlotted to 1 otherwise to 0
            cmpvec = zeros(size(obj.Difference));
            if ~isequal(obj.Difference,cmpvec)
                obj.IsDivergent = 1;
            else
                obj.IsDivergent = 0;
            end
            
        end
        
        %Some setters for properties
        function setIsPlotted(obj, value)
            obj.IsPlotted = value;
        end
        
        function setColor(obj, value)
            obj.Color = value;
        end
        function setOffset(obj, value)
            obj.Offset = value;
        end
        function setScale(obj, value)
            obj.Scale = value;
        end
        
        %Creates the plots of the scaled arrays containing the channeldata
        %for xml1, xml2 and their difference as logical array
        function createPlots(obj)
            
            %Apply the channelconfigurations for offset and scale
            dataToPlot1 = double(obj.Xml1Data)*obj.Scale+obj.Offset;
            dataToPlot2 = double(obj.Xml2Data)*obj.Scale+obj.Offset;
            ind = double(logical(obj.Difference))*obj.PlotDiffValue;
            
            %Make the plots
            obj.Plot1 = plot(dataToPlot1,'Color',obj.Color);
            obj.Plot2 = plot(dataToPlot2,':','Color',obj.Color);
            obj.PlotDiff = plot(ind, '--','color', obj.Color);
            
            %Set Islotted property to true (represented by 1) 
            obj.IsPlotted = 1;
        end
        
        %Deletes all the plots.
        function deletePlots(obj)
            delete(obj.Plot1);
            delete(obj.Plot2);
            delete(obj.PlotDiff);
        end
        
        
    end
    
    %No events
    events

    end
end