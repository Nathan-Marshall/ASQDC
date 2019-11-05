#!/usr/bin/python3

import random
from math import floor

def createLehmerCode(len):
    result = []
    for i in range(len, 0, -1):
        result.append(random.randint(0,i))
    return result

#NOT FUNCTIONAL - MUTATES ELEMS
def codeToPermutation(elems, code):
    def f(i):
        e=elems.pop(i)
        return e
    return list(map(f, code))

def factorial(n):
    if (n<=0):
        return 1
    else:
        return n*factorial(n-1)

def integerToCode(K, n):
    if (n<=1):
        return [0]
    multiplier = factorial(n-1)
    digit = floor(K/multiplier)
    r = [digit]
    r.extend(integerToCode(K%multiplier, n-1))
    return r

#a = ['a','b','c']
#print(createLehmerCode(3))
#print(codeToPermutation(['a','b','c'],[0,0,0]))
print(codeToPermutation(['b','a','c'],integerToCode(2,3)))
print(integerToCode(2,3))
