classdef Alice
    %ALICE The sender of the message.
    %   Alice has powerful quantum capabilities and quantum memory.
    
    properties
        K1
        K2
    end
    
    methods
        function obj = Alice(K1, K2)
            obj.K1 = K1;
            obj.K2 = K2;
        end
        
        function [] = sendMessage(obj, Bob, m)
            %SENDMESSAGE Sends a message to Bob
            %   Bob:Bob
            %   m:string
            M = m + hash(m);
            S = generateBellStates(M);
            C = generateBellStates(randi([0 1], m.length, 1));
            [Ca, Cb] = splitBellStates(C);
            Q = LehmerReorder([dissolveBellStates(S) Cb], obj.K1);
        end
    end
    
    methods (Static)
        function [h] = hash(m)
            %   h:string
            %   m:string
            
        end
        
        function [bellStates] = generateBellStates(cbits)
            %   bellStates:[state]
            %   cbits:string
            bellStates = zeros(cbits.length/2, 1, state);
            for i = 1:2:cbits.length
                bellStates((i+1)/2) = helper.ebit(state(cbits.substring(i, i+1)));
            end
        end
        
        function [qbits] = dissolveBellStates(bellStates)
            %   QBits:[state]
            %   bellStates:[state]
            
        end
        
        function [firstQBits, secondQBits] = splitBellStates(bellStates)
            %   firstQBits:[state]
            %   secondQBits:[state]
            %   bellStates:[state]
            
        end
        
        function [reorderedQBits] = LehmerReorder(qbits, key)
            
        end
    end
end

