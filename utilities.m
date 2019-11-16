classdef utilities
    methods (Static)
        function [code] = createLehmerCode(len)
            %def createLehmerCode(len):
            %   result = []
            %   for i in range(len, 0, -1):
            %       result.append(random.randint(0,i))
            %   return result
            for i = len : -1 : 1
                code = [code randi(i)];
            end
        end
        
        function [perm] = codeToPermutation(elems, code)
            %def codeToPermutation(elems, code):
            %  def f(i):
            %      e=elems.pop(i)
            %      return e
            %  return list(map(f, code))
            perm = maprec(code, pop(elems,i));
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
                code = [0];
            else
               multiplier = factorial(n-1);
               digit = floor(K/multiplier);
               code = [digit integerToCode(rem(K,multiplier), n-1)];
            end
        end
        
        function [h] = hash(m)
            %   h:string
            %   m:string
            import java.security.*;
            import java.math.*;
            % instantiate Java MessageDigest using MD5
            md = MessageDigest.getInstance('MD5');
            % convert m to ASCII numerical rep in base-64 radix
            h_array = md.digest(double(m));
            % convert int8 array into Java BigInteger
            bi = BigInteger(1, h_array);
            % convert hash into string format
            hStr = char(bi.toString(2));
            % convert string to bit array
            h = zeros(128, 1);
            for i = 1:length(hStr)
                h(length(h) + 1 - i) = str2num(hStr(length(hStr) + 1 - i));
            end
            % cut down on the number of bits we use
            h = h(1:128:length(h));
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