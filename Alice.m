classdef Alice
    %ALICE The sender of the message.
    %   Alice has powerful quantum capabilities and quantum memory.
    
    properties
        K1
        K2
        SCba
    end
    
    methods
        function obj = Alice(K1, K2)
            obj.K1 = K1;
            obj.K2 = K2;
        end
        
        function [] = sendMessage(obj, bob, m)
            %SENDMESSAGE Sends a message to Bob
            %   in  bob:Bob - Recipient
            %   in  m:string - message (cbit string)
            M = m + utilities.hash(m);
            S = generateBellPairs(M);
            obj.C = generateBellPairs(randi([0 1], M.length, 1));
            Cba = separateCheckPairs(obj.C);
            obj.SCba = tensor(S, Cba);
            Q = LehmerReorder(obj.SCba, obj.K1);
            bob.receiveMessage(obj, Q);
        end
        
        function [] = receiveReflectedCheckState(obj, bob, collapsedSCba_)
            %RECEIVEREFLECTEDCHECKSTATE Receives the reflected Cb state
            %       from Bob and reorders to bring the Bell-EPR pairs back
            %       together, verifying with the original.
            %   in  bob:Bob - Recipient of original message. Sender of the
            %       reflected check state.
            %   in  collapsedSCba_:state - The Cb portion of this state is
            %       reflected by Bob. Ca was never actually sent by Alice,
            %       and S was measured by Bob using Z-basis measurement.
            
            % TODO : Reorder reflected Cb based on K2, reassemble Bell-EPR
            %        pairs, check validity.
        end
    end
    
    methods (Static)
        function [bellPairs] = generateBellPairs(cbits)
            %   in  cbits:string - input cbit string for Bell-EPR pairs to
            %       generate
            %   out bellPairs:state - State containing all generated
            %       Bell-EPR pairs tensored together
            for i = 1:2:cbits.length
                newPair = helper.ebit(state(cbits.substring(i, i+1)));
                if exist('bellPairs', 'var')
                    bellPairs = tensor(bellPairs, newPair);
                else
                    bellPairs = newPair;
                end
            end
        end
        
        function [Cba] = separateCheckPairs(C)
            %   in  C:state - input qbits
            %   out Cba:state - The same qbits reordered such that the
            %       first qbit from every pair is pushed to the end. The
            %       first n/2 qbits are considered Cb and the last n/2
            %       qbits are considered Ca.
            n = C.subsystems();
            Cba = C;
            for i = 1:n/2
                % Move the first qbit from every pair to the end
                swapToEnd = helper.BSWAP(i, n, n);
                Cba = u_propagate(Cba, swapToEnd);
            end
        end
        
        function [Q] = LehmerReorder(SCba, K1)
            %   in  SCba:state - S is the tensored Bell-EPR pairs
            %       representing the message and message hash components.
            %       Cb is the sequence of 1st qbits from each of the check
            %       state Bell-EPR pairs, and Ca is the 2nd qbit from each.
            %   in  K1:string - Key used for reordering S+Cb according to
            %       the Lehmer code algorithm.
            %   out Q:state - Tensored and reordered output state. Ca stays
            %       the same but S and Cb are shuffled together according
            %       to K1.
            
        end
    end
end

