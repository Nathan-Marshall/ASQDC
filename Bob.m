classdef Bob
    %BOB The receiver of the message.
    %   Bob has only classic capabilities and Z-basis measurement.
    
    properties
        K1
        K2
        m_
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
            SCba_ = LehmerReorder(Q_, obj.K1);
            [M_, collapsedSCba_] = ReadMessage(SCba_);
            [m_, hashVerified] = VerifyHash(M_);
            if hashVerified
                obj.m_ = m_;
            else
                % ERROR? Restart?
            end
            
            % TODO: Reorder Cb based on K2
            
            alice.ReceiveReflectedCheckState(obj, collapsedSCba_);
        end
    end
    
    methods (Static)
        function [SCba_] = LehmerReorder(Q_, K1)
            %   in  Q:state - State as received from Alice (ignore Ca). We
            %       will shuffle the S+Cb component back to its original
            %       order.
            %   in  K1:string - Key used for reordering S+Cb according to
            %       the Lehmer code algorithm.
            %   out Q_:state - Reordered output state. Ca stays the same
            %       but S and Cb are shuffled back to their original order.
            
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
        
        function [h_] = hash(m_)
            %   in  m_:string - input cbit string
            %   out h_:string - hashed value cbit string
            
        end
        
        function [m_, success] = VerifyHash(M_)
            h_ = M_.substring(1, M_.length/2);
            m_ = M_.substring(M.length/2 + 1, M.length);
            success = (h_ == hash(m_));
        end
    end
end

