import java.security.*;
import java.math.*;

 classdef assister
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
            % instantiate Java MessageDigest using MD5
            md = MessageDigest.getInstance('MD5');
            % convert m to ASCII numerical rep in base-64 radix
            hash = md.digest(double(m));
            % convert int8 array into Java BigInteger
            bi = BigInteger(1, hash);
            % convert hash into string format
            h = char(bi.toString(16))
        end
     end
 end