classdef Alice < handle
    %ALICE The sender of the message.
    %   Alice has powerful quantum capabilities and quantum memory.
    
    properties
        % K1:[number] - Array of 0's and 1's used to generate a Lehmer
        % permutation to shuffle S + Cb to send to Bob
        K1
        
        % K2:[number] - Array of 0's and 1's used to generate a Lehmer
        % permutation to resore the reflected Cb received from Bob
        K2
        
        % checkSequence:[number] - Array of 0's and 1's representing the
        % check state C. (Used to generate Bell-EPR pairs.)
        checkSequence
        
        % success:bool - Set to false when Alice sends a message, and set
        % to true again when Alice receives the correct reflected check
        % state from Bob
        success
    end
    
    methods
        function obj = Alice(K1, K2)
            obj.K1 = K1;
            obj.K2 = K2;
        end
        
        function [] = sendMessage(obj, bob, m)
            %SENDMESSAGE Sends a message to Bob
            %   in  bob:Bob - Recipient
            %   in  m:[number] - message cbits
            disp('Alice is sending a message to Bob.');
            obj.success = false;
            M = [m; utilities.hash(m)];
            S = Alice.generateBellPairs(M);
            obj.checkSequence = randi([0 1], length(M), 1);
            C = Alice.generateBellPairs(obj.checkSequence);
            Cba = Alice.separateCheckPairs(C);
            SCba = tensor(S, Cba);
            Q = Alice.LehmerShuffleSCb(SCba, obj.K1);
            bob.receiveMessage(obj, Q);
        end
        
        function [] = receiveReflectedCheckState(obj, reflectedSCba__)
            %RECEIVEREFLECTEDCHECKSTATE Receives the reflected Cb state
            %       from Bob and reorders to bring the Bell-EPR pairs back
            %       together, verifying with the original.
            %   in  bob:Bob - Recipient of original message. Sender of the
            %       reflected check state.
            %   in  collapsedSCba_:state - The Cb portion of this state is
            %       reflected by Bob. Ca was never actually sent by Alice,
            %       and S was measured by Bob using Z-basis measurement.
            
            disp('Alice is receiving the reflected check state from Bob.');
            SCba__ = Alice.LehmerRestoreCb(reflectedSCba__, obj.K2);
            SC_ = Alice.restoreCheckPairs(SCba__);
            checkSequence_ = Alice.readCheckState(SC_);
            if checkSequence_ == obj.checkSequence
                disp('Alice has confirmed that Bob successfully received the message.');
                obj.success = true;
            else
                disp('Failure: Check state reflected from Bob contained errors.');
                obj.success = false;
            end
        end
    end
    
    methods (Static)
        function [bellPairs] = generateBellPairs(cbits)
            %   in  cbits:[number] - input cbits for Bell-EPR pairs to
            %       generate
            %   out bellPairs:state - State containing all generated
            %       Bell-EPR pairs tensored together
            for i = 1:length(cbits)
                if cbits(i) == 0
                    % Phi+
                    newPair = state('Bell3');
                else
                    % Psi-
                    newPair = state('Bell1');
                end
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
                iToLast = helper.BSWAP(i, n, n);
                Cba = u_propagate(Cba, iToLast);
            end
        end
        
        function [SC_] = restoreCheckPairs(SCba__)
            %   in  SCba__:state - input qbits
            %   out SC_:state - The same qbits reordered such that Ca and
            %       Cb are paired back up into Bell-EPR pairs.
            
            % ignore S and start at Cb
            start = SCba__.subsystems() / 2 + 1;
            % number of qbits in Cba
            n = SCba__.subsystems() / 2;
            
            SC_ = SCba__;
            for i = start + n/2 - 1 : -1 : start
                % Move the first qbit from every pair to the end
                lastToI = helper.BSWAP(start + n - 1, i, start + n - 1);
                SC_ = u_propagate(SC_, lastToI);
            end
        end
        
        function [checkSequence_] = readCheckState(SC_)
            %   in  SC_:state - Contains check state C which should contain
            %       the originally generated Bell-EPR pairs.
            %   out checkSequence_:[number] - cbits obtained by performing
            %       Bell measurement on all pairs in C.
            
            % start with I gates for all qbits in S
            prep = helper.power(helper.I, SC_.subsystems() / 2);
            % ignore S and start at Cb
            start = SC_.subsystems() / 2 + 1;
            % number of qbits in Cba
            n = SC_.subsystems() / 2;
            
            % add Bell-measurement preparation gates for every pair of qbits
            for i = start : 2 : start + n - 1
                prep = tensor(prep, tensor(helper.H, helper.I) * helper.ACNOT);
            end
            preppedSC_ = u_propagate(SC_, prep);
            
            % measure each qbit in C
            checkSequence_ = zeros(n/2, 1);
            
            for i = start : 2 : start + n - 1
                [~, b1, preppedSC_] = measure(preppedSC_, i);
                b1 = b1 - 1;
                [~, b2, preppedSC_] = measure(preppedSC_, i+1);
                b2 = b2 - 1;
                
                if b1 == 0 && b2 == 0
                    % if the bits are the same, Alice sent a Phi+
                    % which represents 0
                    checkSequence_((i - start)/2 + 1) = 0;
                elseif b1 == 1 && b2 == 1
                    % if the bits are the different, Alice sent a Psi-
                    % which represents 1
                    checkSequence_((i - start)/2 + 1) = 1;
                else
                    disp('Error: unexpected Bell-measurement reading');
                    checkSequence_ = [];
                    return;
                end
            end
        end
        
        function [Q] = LehmerShuffleSCb(SCba, K1)
            %   in  SCba:state - S is the tensored Bell-EPR pairs
            %       representing the message and message hash components.
            %       Cb is the sequence of 1st qbits from each of the check
            %       state Bell-EPR pairs, and Ca is the 2nd qbit from each.
            %   in  K1:[number] - cbit Key used for reordering S+Cb according to
            %       the Lehmer code algorithm.
            %   out Q:state - Tensored and reordered output state. Ca stays
            %       the same but S and Cb are shuffled together according
            %       to K1.
            
            % TODO: implement shuffling rather than returning input
            Q = SCba;
        end
        
        function [SCba__] = LehmerRestoreCb(reflectedSCba__, K2)
            %   in  reflectedSCba__:state - S is the tensored Bell-EPR pairs
            %       representing the message and message hash components.
            %       Cb is the sequence of 1st qbits from each of the check
            %       state Bell-EPR pairs, and Ca is the 2nd qbit from each.
            %   in  K2:[number] - cbit Key used for reordering Cb back to its
            %       original order according to the Lehmer code algorithm.
            %   out SCba__:state - Reordered output state. Ca and S stay
            %       the same but Cb is shuffled back to its original order
            %       according to K2.
            
            % TODO: implement shuffling rather than returning input
            SCba__ = reflectedSCba__;
        end
    end
end

