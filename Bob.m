classdef Bob < handle
    %BOB The receiver of the message.
    %   Bob has only classic capabilities and Z-basis measurement.
    
    properties
        K1
        K2
        receivedMessage
    end
    
    methods
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
            SCba_ = LehmerRestoreSCb(Q_, obj.K1);
            [M_, collapsedSCba_] = ReadMessage(SCba_);
            [m_, hashVerified] = VerifyHash(M_);
            if hashVerified
                obj.receivedMessage = m_;
                disp('Bob successfully received the message.');
                disp('Bob is reflecting the check state back to Alice.');
                shuffledSCba_ = LehmerShuffleCb(collapsedSCba_, obj.K2);
                alice.ReceiveReflectedCheckState(obj, shuffledSCba_);
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
            %   in  K1:string - Key used for reordering S+Cb according to
            %       the Lehmer code algorithm.
            %   out SCba_:state - Reordered output state. Ca stays the same
            %       but S and Cb are shuffled back to their original order.
            
        end
        
        function [shuffledSCba_] = LehmerShuffleCb(SCba_, K2)
            %   in  SCba_:state - State as received from Alice (ignore Ca).
            %       We will shuffle the S+Cb component back to its original
            %       order.
            %   in  K2:string - Key used for reordering Cb according to
            %       the Lehmer code algorithm.
            %   out shuffledSCba_:state - Reordered output state. Ca and S
            %       stay the same but Cb is shuffled according to K2.
            
        end
        
        function [M_, collapsedSCba_] = ReadMessage(SCba_)
            M_ = "";
            n = SCba_.subsystems();
            collapsedSCba_ = SCba_;
            for i = 1:n/2
                [~, b, collapsedSCba_] = measure(collapsedSCba_, i);
                b = b - 1;
                M_ = M_ + num2str(b, '%1d');
            end
        end
        
        function [m_, success] = VerifyHash(M_)
            h_ = M_.substring(1, M_.length/2);
            m_ = M_.substring(M.length/2 + 1, M.length);
            success = (h_ == utilities.hash(m_));
        end
    end
end

