def n_to_str (num, n_bits_per_word, n_words):
    """ This function takes as input a number and returns a string representing
    the number divided into n_words of n_bits_per word each"""

    #create a string and format it in order to have right alignment and zero padding
    bin_num_str = bin(num)[2:].zfill(n_bits_per_word*n_words);
    #str_list = list(bin_num_str)
    counter = 0
    final_str = ''

    for i in range(0,(n_words)):
        final_str = final_str + bin_num_str[(i*n_bits_per_word):( ( (i+1)*n_bits_per_word )) ] + ' '

    print(final_str[:-1])
    return final_str[:-1]





if __name__ == "__main__":
    import sys
    int_args = [int(i) for i in sys.argv[1:]]
    n_to_str(*int_args)
