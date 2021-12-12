import gmpy2 as g
import math  as m
import csv
import random as rnd
import pprint as pp

def n_to_str (num, n_bits_per_word, n_words,base = 2):
    """ This function takes as input a number and returns a string representing
    the number separated (with spaces) into n_words of n_bits_per word each"""

    #create a string and format it in order to have right alignment and zero padding
    n_symbols_per_word = (int) (n_bits_per_word / m.log(base,2))         #compute number of symbols per word (wrt base)
    bin_num_str = g.digits(num,base).zfill(n_words * n_symbols_per_word).upper() #create complete string

    final_str = ''

    for i in range(0,(n_words)):
        final_str = final_str + bin_num_str[(i*n_symbols_per_word):( ( (i+1)*n_symbols_per_word )) ] + ' ' #compose final string with spaces

    return final_str[:-1] #return final string without last space

def monmult_str (a,b,n,r,base=16):
    """This function computes the modular multiplication and returns the result as a string in the selected base"""

    rr = g.invert(r,n) #compute inverse of r mod n
    mmult = g.f_mod(g.mul(g.mul(a,b),rr),n) #compute modular multiplication
    mult_str = g.digits(mmult,base)  # create output string
    return mult_str #return result of mult as string in the selected base

def monmult_int (a,b,n,r):
    """This function computes the modular multiplication and returns the result as an integer value"""

    rr = g.invert(r,n) #compute inverse of r mod n
    mmult = (int) (g.f_mod(g.mul(g.mul(a,b),rr),n)) #compute modular multiplication
    return mmult #return result of mult as int


def send_tv_str_oneline (a,b,n,r,n_bits_per_word,n_words,base=16):
    """This function takes a test vector (a,b,n,r), the number of words and of bits per word, and the base, and it returns a string (one line) 
    in the format: <a  b  n  n'(0)>  separated by double spaces"""

    n_symbols_per_word = (int) (n_bits_per_word / m.log(base,2)) #compute number of symbols per word wrt base argument

    nn = g.digits(g.invert(-n,r),base).zfill(n_symbols_per_word*n_words) # compute n'

    a_str = n_to_str(a,n_bits_per_word,n_words,base) + '  ' # create string containing "a" operator
    b_str = n_to_str(b,n_bits_per_word,n_words,base) + '  ' # create string containing "b" operator
    n_str = n_to_str(n,n_bits_per_word,n_words,base) + '  ' # create string containing "n"
    nn0_str = nn[-n_symbols_per_word:] + '\r\n'             # create string containing n'(0)
    str_out = a_str + b_str + n_str + nn0_str.upper()       # compose output string
    return str_out                                          # return test vector data in a single line separated by spaces

def load_tv_from_file(file_path,n_words,n_bits_per_word,r,base=16):
    """This function loads test vectors from a file, and return a list of dictionaries with keys:
    a,b,n,nn0,r,golden_res """

    tv_list = []
    file_lines =[]

    dict_keys = ['A', 'B','N',"N'(0)",'R','N BIT TOTAL','N BITS PER WORD','N WORDS','GOLDEN_RESULT']

    n_symbols = (int) ( (n_bits_per_word*n_words) / m.log(base,2))

    with open(file_path,"r") as ff:
        file_lines = ff.readlines()
    


    for lin in file_lines.copy():

        op_list = lin.split ("  ")
        dict_values_str = [op.replace(" ","").replace("\n","").replace("\r","") for op in op_list] #stripped operators of 1 test vector
        dict_values_int = [int(i,base=base) for i in dict_values_str]
        dict_values_int.append(r)
        dict_values_str.append(g.digits(r,base))

        dict_temp = dict_values_int.copy()
        dict_temp.pop(3) #remove nn0 from values

        dict_values_str.append(n_bits_per_word * n_words)
        dict_values_str.append(n_bits_per_word)
        dict_values_str.append(n_words)

        golden_res = monmult_int(*dict_temp)


        dict_values_str.append(g.digits(golden_res,base).zfill(n_symbols).upper())

        tv_list.append(dict(zip(dict_keys,dict_values_str)))

    return tv_list


def load_res_from_file(file_path,n_bits,base = 16):
    """This function reads the results of the vhdl module from a file and returns them in a list"""

    n_symbols = (int) (n_bits / m.log(base,2))

    with open(file_path,"r") as ff:
        file_lines = ff.readlines()
    
    file_lines_stripped = [st.replace(" ","").replace("\n","").replace("\r","").zfill(n_symbols) for st in file_lines]

    return file_lines_stripped


def print_csv_out (file_name, tvv_list):
    """This function generates a csv output file with all test vectors sent and results"""

    with open(file_name, 'w', newline='') as csvfile:
        fieldnames = ['A', 'B','N',"N'(0)",'R','N BIT TOTAL','N BITS PER WORD','N WORDS','GOLDEN_RESULT','MODULE_RESULT','PASSED']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()

        for elem in tvv_list:
            writer.writerow(elem)

def test_tv_pass (tv_list):
    """This function evaluates the pass state of a test vector list
     and adds a field PASSED to each test vector"""

    positive_list = []
    negative_list = []
    for elem in tv_list:
        if elem['MODULE_RESULT'].upper() == elem['GOLDEN_RESULT'].upper():
            pass_status = "YES"
            positive_list.append(elem)
        else:
            pass_status = "NO"
            negative_list.append(elem)

        elem.update({'PASSED':pass_status})
    return{'POS_tv':positive_list,'NEG_tv':negative_list}

def generate_tv (n_bits, n_tests):
    """This function generates n test vectors with the specified number of bits"""
    generated_tv = []
    dict_keys = ['a','b','n','r','n_bits']
    r = pow(2,n_bits)
    random_st = g.random_state()
    valid = 0

    for i in range (0,n_tests):

        while(valid == 0):
            dict_values = []

            n = g.mpz_rrandomb(random_st,n_bits)

            if g.f_mod(n,2) == 0:
                n-=1

            a = g.f_mod(g.mpz_rrandomb(random_st,n_bits),n)
            b = g.f_mod(g.mpz_rrandomb(random_st,n_bits),n)

            valid = (g.mul(a,b) < g.mul(n,r))

        dict_values.extend((a,b,n,r,n_bits))
        generated_tv.append(dict(zip(dict_keys,dict_values)))
        valid = 0


        #pp.pprint(dict_values)
    
    return generated_tv



