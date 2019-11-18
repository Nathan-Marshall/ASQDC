classdef Bob < handle
    %BOB The receiver of the message.
    %   Bob has only classic capabilities and Z-basis measurement.
    
    properties
        % K1:[number] - Array of 0's and 1's used to generate a Lehmer
        % permutation to restore S + Cb received from to Bob
        K1
        
        % K2:[number] - Array of 0's and 1's used to generate a Lehmer
        % permutation to shuffle the reflected Cb sent to Bob
        K2
        
        % receivedMessage:[number] - Array of 0's and 1's representing the
        % message sent from Alice. If the calculated hash is invalid, the
        % protocol is aborted and this value is cleared.
        receivedMessage
    end
    
    methods
        function obj = Bob(K1, K2)
            obj.K1 = K1;
            obj.K2 = K2;
        end
        
        function [] = receiveMessage(obj, alice, Q_)
            %RECEIVEMESSAGE Receives a message from Alice
            %   in  alice:Alice - Sender
            %   in  Q:state - message as a quantum state containing the
            %       message component S which is shuffled with the 2nd part
            %       of the check component Cb, followed by the first part
            %       of the check component Ca. Ca is technically not sent
            %       by Alice and should not be touched by Bob in this
            %       simulation.
            disp('Bob is receiving a message.');
            SCba_ = Bob.LehmerRestoreSCb(Q_, obj.K1);
            [M_, collapsedSCba_] = Bob.readMessage(SCba_);
            [m_, hashVerified] = Bob.verifyHash(M_);
            if hashVerified
                obj.receivedMessage = m_;
                disp('Bob successfully received the message.');
                disp('Bob is reflecting the check state back to Alice.');
                shuffledSCba_ = Bob.LehmerShuffleCb(collapsedSCba_, obj.K2);
                alice.receiveReflectedCheckState(shuffledSCba_);
            else
                disp('Failure: Incorrect hash on message received by Bob.');
                obj.receivedMessage = '';
            end
        end
    end
    
    methods (Static)
        function [SCba_] = LehmerRestoreSCb(Q_, K1)
            %   in  Q_:state - State as received from Alice (ignore Ca).
            %       We will shuffle the S+Cb component back to its original
            %       order.
            %   in  K1:[number] - cbit Key used for reordering S+Cb according to
            %       the Lehmer code algorithm.
            %   out SCba_:state - Reordered output state. Ca stays the same
            %       but S and Cb are shuffled back to their original order.
            
            % TODO: implement shuffling rather than returning input
            SCba_ = Q_;
        end
        
        function [shuffledSCba_] = LehmerShuffleCb(SCba_, K2)
            %   in  SCba_:state - State as received from Alice (ignore Ca).
            %       We will shuffle the S+Cb component back to its original
            %       order.
            %   in  K2:[number] - cbit Key used for reordering Cb according to
            %       the Lehmer code algorithm.
            %   out shuffledSCba_:state - Reordered output state. Ca and S
            %       stay the same but Cb is shuffled according to K2.
            
            % TODO: implement shuffling rather than returning input
            shuffledSCba_ = SCba_;
        end
        
        function [M_, collapsedSCba_] = readMessage(SCba_)
            n = SCba_.subsystems();
            M_ = zeros(n/4, 1);
            collapsedSCba_ = SCba_;
            for i = 1:2:n/2
                [~, b1, collapsedSCba_] = measure(collapsedSCba_, i);
                b1 = b1 - 1;
                [~, b2, collapsedSCba_] = measure(collapsedSCba_, i+1);
                b2 = b2 - 1;
                
                if b1 == b2
                    % if the bits are the same, Alice sent a Phi+
                    % which represents 0
                    M_((i-1)/2 + 1) = 0;
                else
                    % if the bits are the different, Alice sent a Psi-
                    % which represents 1
                    M_((i-1)/2 + 1) = 1;
                end
            end
        end
        
        function [m_, success] = verifyHash(M_)
            m_ = M_(1 : length(M_)/2);
            h_ = M_(length(M_)/2 + 1 : length(M_));
            success = (h_ == utilities.hash(m_));
        end
    end
end

