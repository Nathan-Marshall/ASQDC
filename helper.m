% Quantum Programming Helper
% Author: Michel Barbeau
% Version: February 8, 2016
% Dependency: Quantum Information Toolkit
classdef helper < handle
    % static properties
    properties (Constant)
        % Gates
        ACNOT = gate.mod_add(2, 2)
        BCNOT = helper.ACNOT * helper.SWAP * helper.ACNOT
        H = gate.qft(2)
        I = gate.id(2)
        SWAP = gate.swap(2,2)
        X = gate.mod_inc(-1, 2)
        Y = 1 / i * helper.Z * helper.X
        Z = helper.H * gate.mod_inc(1, 2) * helper.H'
        % Bell-EPR production
        E = helper.ACNOT * tensor(helper.H, helper.I);
        % Bell-EPR measurement preperation
        prep = tensor(helper.H, helper.I) * helper.ACNOT;
    end
    methods (Static)
        function [ P ] = power(G, n)
            % return the nth tensor power of gate G (n?0)
            % WARNING: power(G,0) does not work with tensor function
            if (n == 0)
                P = lmap(1, {[ 1 1 ]});
            else
                P = G;
                for i = 2 : n
                    P = tensor(P, G);
                end
            end
        end
        
        function [ G ] = R(k, n)
            % return a n by n gate swapping qubits k and k+1
            if (k <= 0 || k >= n)
                error('In function R: must have 0<k<n');
            end
            if (k + 1 < n)
                G = tensor(helper.SWAP, helper.power(helper.I, n - (k + 1)));
            else
                G = helper.SWAP;
            end
            if (k > 1)
                G = tensor(helper.power(helper.I, k - 1), G);
            end
        end
        
        function [ G ] = BSWAP(k, l, n)
            % if k<l
            % ret. a n*n gate swapping qubit k and qubits k+1 to l
            % if k>l
            % ret. a n*n gate swapping qubits l to k-1 and qubit k
            % else
            % ret. a n*n I gate
            if (k <= 0 || k > n)
                error('In function BSWAP: must have 0<k?n');
            end
            if (l <= 0 || l > n)
                error('In function BSWAP: must have 0<l?n');
            end
            G = helper.power(helper.I, n);
            if (k < l)
                for m = k : l - 1
                    G = helper.R(m, n) * G;
                end
            elseif (k > l)
                for m = k - 1 : -1 : l
                    G = helper.R(m, n) * G;
                end
            end
        end
        
        function [ S ] = ebit(in)
            % return a Bell-EPR state
            % in=input state, e.g., |00>
            S = u_propagate(in, helper.E);
        end
    end
end