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
            SCba_ = utilities.LehmerShuffleK1(Q_, obj.K1);
            [M_, collapsedSCba_] = Bob.readMessage(SCba_);
            [m_, hashVerified] = Bob.verifyHash(M_);
            obj.receivedMessage = m_;
            if hashVerified
                disp('Bob successfully received the message.');
                disp('Bob is reflecting the check state back to Alice.');
                shuffledSCba_ = utilities.LehmerShuffleK2(collapsedSCba_, obj.K2);
                alice.receiveReflectedCheckState(shuffledSCba_);
            else
                disp('Failure: Incorrect hash on message received by Bob.');
            end
        end
    end
    
    methods (Static)
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

