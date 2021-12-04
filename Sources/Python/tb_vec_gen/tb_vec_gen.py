import gmpy2 as g
import math  as m

def n_to_str (num, n_bits_per_word, n_words,base = 2):
    """ This function takes as input a number and returns a string representing
    the number divided into n_words of n_bits_per word each"""

    #create a string and format it in order to have right alignment and zero padding
    n_symbols_per_word = (int) (n_bits_per_word / m.log(base,2))
    bin_num_str = g.digits(num,base).zfill(n_words * n_symbols_per_word)

    final_str = ''

    for i in range(0,(n_words)):
        final_str = final_str + bin_num_str[(i*n_symbols_per_word):( ( (i+1)*n_symbols_per_word )) ] + ' '

    return final_str[:-1]

def monmult_str (a,b,n,r,base=16):
    """This function computes the modular multiplication and returns it as a string"""

    rr = g.invert(r,n)
    mmult = g.f_mod(g.mul(g.mul(a,b),rr),n)
    mult_str = g.digits(mmult,base)
    return mult_str


def send_tv_str (a,b,n,r,n_bits_per_word,n_words,base=16):

    n_symbols_per_word = (int) (n_bits_per_word / m.log(base,2))

    nn = g.digits(g.invert(-n,r),base).zfill(n_symbols_per_word*n_words)

    a_str = n_to_str(a,n_bits_per_word,n_words,base) + ' '
    b_str = n_to_str(b,n_bits_per_word,n_words,base) + ' '
    n_str = n_to_str(n,n_bits_per_word,n_words,base) + ' '
    nn0_str = nn[-n_symbols_per_word:] + '\r\n'
    str_out = a_str + b_str + n_str + nn0_str
    return str_out





if __name__ == "__main__":
    import sys
    int_args = [int(i) for i in sys.argv[1:]]
    n_to_str(*int_args)
