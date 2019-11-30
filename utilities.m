classdef utilities
    methods (Static)
        function [code] = createLehmerCode(len)
            %def createLehmerCode(len):
            %   result = []
            %   for i in range(len, 0, -1):
            %       result.append(random.randint(0,i))
            %   return result
            code = [];
            for i = len : -1 : 1
                code = [code randi(i)];
            end
        end
        
        function [e] = remove(elems, i)
            a = elems(1:(i-1));
            b = elems((i+1):length(elems));
            e = [a b];
                
        end
        
        function [perm] = permuteFromCode(elems, code)
            %def codeToPermutation(elems, code):
            %  def f(i):
            %      e=elems.pop(i)
            %      return e
            %  return list(map(f, code))
            
            %x = @(f) remove(
            %perm = []
            %perm = maprec(code, pop(elems,i));
            
            e = elems(1:length(elems));
            perm = [];
            for i = 1 : length(code)
                perm = [perm e(code(i))];
                e = utilities.remove(e,code(i));
            end
        end
        
        function [perm] = codeToPermutation(code)
            perm = code;
            n = length(perm);
            for i = n:-1:1
                for j = i+1:n
                    if perm(j) >= perm(i)
                        perm(j) = perm(j) + 1;
                    end
                end
            end
        end
        
        function [inv] = invertPermutation(perm)
            n = length(perm);
            inv = zeros(n, 1);
            for i = 1:n
                x = perm(i);
                inv(x) = i;
            end
        end
        
        function [code] = permutationToCode(perm)
            code = perm;
            n = length(code);
            for i = 1:n
                for j = i+1:n
                    if code(j) > code(i)
                        code(j) = code(j) - 1;
                    end
                end
            end
        end
        
        function [invCode] = invertLehmerCode(code)
            perm = utilities.codeToPermutation(code);
            invPerm = utilities.invertPermutation(perm);
            invCode = utilities.permutationToCode(invPerm);
        end
        
        function [num] = bitArrayToNumber(bits)
            n = length(bits);
            num = 0;
            for exp = 0:n-1
                i = n - exp;
                if bits(i) == 1
                    num = num + 2^exp;
                end
            end
        end
        
        function [code] = integerToCode(K, n)
            %def integerToCode(K, n):
            %   if (n<=1):
            %       return [0]
            %   multiplier = factorial(n-1)
            %   digit = floor(K/multiplier)
            %   r = [digit]
            %   r.extend(integerToCode(K%multiplier, n-1))
            %   return r
            
            if n <= 1
                code = [1];
            else
               multiplier = factorial(n-1);
               digit = floor(K/multiplier)+1;
               if (digit > n)
                   error('K >= n!');
               end
               code = [digit utilities.integerToCode(rem(K,multiplier), n-1)];
            end
        end
        
        function [h] = hash(m)
            %%%   h:string
            %%%   m:string
            %import java.security.*;
            %import java.math.*;
            %%% instantiate Java MessageDigest using MD5
            %md = MessageDigest.getInstance('MD5');
            %%% convert m to ASCII numerical rep in base-64 radix
            %h_array = md.digest(double(m));
            %%% convert int8 array into Java BigInteger
            %bi = BigInteger(1, h_array);
            %%% convert hash into string format
            %hStr = char(bi.toString(2));
            %%% convert string to bit array
            %h = zeros(128, 1);
            %for i = 1:length(hStr)
            %    h(length(h) + 1 - i) = str2num(hStr(length(hStr) + 1 - i));
            %end
            
            
            % Ignore the good hash function above and use this poor one
            % because we can only afford a few bits. This not very secure
            % but guaranteed to be collision free. In practice, we would
            % use the above function, but we cannot simulate the protocol
            % with that many qubits on an ordinary computer (not enough
            % RAM).
            h = m;
            for i = 1:length(h)
                if h(i) == 0
                    h(i) = 1;
                else
                    h(i) = 0;
                end
            end
        end
        
        function [outState] = LehmerShuffle(inState, code, first, last)
            n = inState.subsystems();
            if length(code) ~= last - first + 1
                error('Key length does not match number of elements');
            end
            
            outState = inState;
            for i = 1 : last - first + 1
                index = first + code(i) - 1;
                iToLast = helper.BSWAP(index, last, n);
                outState = u_propagate(outState, iToLast);
            end
        end
        
        function [Q] = LehmerShuffleK1(SCba, K1)
            %   in  SCba:state - S is the tensored Bell-EPR pairs
            %       representing the message and message hash components.
            %       Cb is the sequence of 1st qbits from each of the check
            %       state Bell-EPR pairs, and Ca is the 2nd qbit from each.
            %   in  K1:[number] - cbit Key used for reordering S+Cb according to
            %       the Lehmer code algorithm.
            %   out Q:state - Tensored and reordered output state. Ca stays
            %       the same but S and Cb are shuffled together according
            %       to K1.
            
            n = SCba.subsystems();
            Q = utilities.LehmerShuffle(SCba, K1, 1, n*3/4);
        end
        
        function [shuffledSCba_] = LehmerShuffleK2(SCba_, K2)
            %   in  SCba_:state - State as received from Alice (ignore Ca).
            %       We will shuffle the S+Cb component back to its original
            %       order.
            %   in  K2:[number] - cbit Key used for reordering Cb according to
            %       the Lehmer code algorithm.
            %   out shuffledSCba_:state - Reordered output state. Ca and S
            %       stay the same but Cb is shuffled according to K2.
            
            n = SCba_.subsystems();
            shuffledSCba_ = utilities.LehmerShuffle(SCba_, K2, n*1/2 + 1, n*3/4);
        end
        
        function [str] = bitstring(bitArray)
            str = "";
            for i = 1:length(bitArray)
                if bitArray(i) == 0
                    str = str + "0";
                else
                    str = str + "1";
                end
            end
        end
    end
end