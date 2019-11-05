classdef Bob
    %BOB The receiver of the message.
    %   Bob has only classic capabilities and Z-basis measurement.
    
    properties
        Property1
    end
    
    methods
        function obj = Bob(inputArg1,inputArg2)
            obj.Property1 = inputArg1 + inputArg2;
        end
    end
end

