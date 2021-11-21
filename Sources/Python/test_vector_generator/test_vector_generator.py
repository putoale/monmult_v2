#this script generates test vectors
#TAKE N_BITS=32, with S=4 e NBITS_PER_WORD=8
n=0x00AAAAAA
r=0x10000000
n_inv = pow(n, -1, r)
r_inv= pow(r, -1, n)
n_prime=n_inv % (2**8-1)
a=0x123456
b=0x123456
monmult=(a * b) % n
print(f"monmult={monmult}")
