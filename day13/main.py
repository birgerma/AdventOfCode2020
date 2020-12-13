# A Python 3program to demonstrate 
# working of Chinise remainder 
# Theorem 
  
# Returns modulo inverse of a with 
# respect to m using extended 
# Euclid Algorithm. Refer below  
# post for details: 
# https://www.geeksforgeeks.org/multiplicative-inverse-under-modulo-m/ 
def inv(a, m) : 
      
    m0 = m 
    x0 = 0
    x1 = 1
  
    if (m == 1) : 
        return 0
  
    # Apply extended Euclid Algorithm 
    while (a > 1) : 
        # q is quotient 
        q = a // m 
  
        t = m 
  
        # m is remainder now, process  
        # same as euclid's algo 
        m = a % m 
        a = t 
  
        t = x0 
  
        x0 = x1 - q * x0 
  
        x1 = t 
      
    # Make x1 positive 
    if (x1 < 0) : 
        x1 = x1 + m0 
  
    return x1 
  
# k is size of num[] and rem[].  
# Returns the smallest 
# number x such that: 
# x % num[0] = rem[0], 
# x % num[1] = rem[1], 
# .................. 
# x % num[k-2] = rem[k-1] 
# Assumption: Numbers in num[]  
# are pairwise coprime 
# (gcd for every pair is 1) 
def findMinX(num, rem, k) : 
      
    # Compute product of all numbers 
    prod = 1
    for i in range(0, k) : 
        prod = prod * num[i] 
  
    # Initialize result 
    result = 0

    # Apply above formula
    ppList = []
    invList = []
    for i in range(0,k): 
        pp = prod // num[i]
        ppList.append(pp)
        invList.append(inv(pp, num[i]))
        result = result + rem[i] * inv(pp, num[i]) * pp 
      
    # Print factors:
    print("Prod:",prod)
    print("Pp:",ppList)
    print("Inv:", invList)
    print("Rem:", rem)
    print("Prod sum:",result)
    print("X=",result%prod)
      
    return result % prod 
  
# Driver method 
# num = [3, 4, 5] 
# rem = [2, 3, 1]
num = [7,13,59,31,19]
rem = [0,-1,-4,-6,-7]
k = len(num) 
print( "x is " , findMinX(num, rem, k)) 
  
# This code is contributed by Nikita Tiwari. 

# Erlang values:
# List:[7,13,59,31,19]
# Rem:[0,-1,-4,-6,-7]

# Prod:3162341
# PP:[451763,243257,53599, 102011,166439]
# Inv:[2,1, 35,3, 18]
# ProdSum:-30554629
# X=
