import sys
import tb_vec_gen as tbm
import math as m
import gmpy2 as g
import pprint as pp
import os

script_dir = os.path.dirname(__file__)
rel_path = "txt"

output_base = 16

test_vec_256_1 = {
    'a': 0xe41be5bde54ea01c5fd8132dae3c50bd9f96c5af1324a68d08d978048f69bf76,
    'b': 0xf9852cd21de6a57f70ba175bea2fffc2a40a26a7d424cf6f3cc8843f9135d1ed,
    'n': 0xb6fb5f6da48f54fc63af7b4b3e9c3631cd781a526fb464a66bb3e127e74e2c25,
    'r': 0x10000000000000000000000000000000000000000000000000000000000000000,
    'n_bits':256
}

test_vec_256_2 = {
    'a': 0xa9bf5dff81ef3871f8206ecdd8b673cfb0b6737d5a983628babdca532e76f1ef,
    'b': 0xc893cd7b64513b7a2652d8e4865dc4d07af5bb3bd1ef10aa28197d81e622029f,
    'n': 0xbaa9614c0aff9d805f10ab09561f9bb9879bcf08bd25aa6955db00b696ac2173,
    'r': 0x10000000000000000000000000000000000000000000000000000000000000000,
    'n_bits':256
}

test_vec_256_3 = {
    'a': 0xb071fcf379e962002c54d59662641609f870ddfb50601d5e2da14f6de24da602,
    'b': 0xfa5cdcb31e308c75ddfb1f57812e4c1cf20dc45cabef6b25ea9b707e6e0bc147,
    'n': 0xa8c219a6b9410befd065464c689949dd21bed322a0851311b10b84f1ba87eccd,
    'r': 0x10000000000000000000000000000000000000000000000000000000000000000,
    'n_bits':256
}

test_vec_64_1 = {
    'a' : 0xAABBCCDDEEFF1122,
    'b' : 0x1122334455667788,
    'n' : 0xFEF93EAFAEF9FFA9,
    'r' : 0x10000000000000000,
    'n_bits' : 64
}

test_vec_32_2 = {
    'a': 0xabcdef99,
    'b': 0x9876abed,
    'n': 0xfde9fde9,
    'r': 0x100000000,
    'n_bits':32
}

test_vec_32_1 = {
    'a': 0x12345678,
    'b': 0x9abcdef1,
    'n': 0xfde9fde9,
    'r': 0x100000000,
    'n_bits':32
}

all_tv = [test_vec_256_1,test_vec_256_2,test_vec_256_3,test_vec_32_1,test_vec_32_2,test_vec_64_1] #list with all test vectors

all_tv.extend(tbm.generate_tv(64,10))

# you can call this script specifying a configuration. E.g. "python3 script 256_4_64 256_8_32 32_4_8" will print all 256 bits tv with 4 words and
# 64 bits per word, in a file named "input_vectors_256_4_64" and so on...
# If the script is called without any args, it assumes the default configuration

if len(sys.argv) > 1:
    tv_config_list = sys.argv[1:]
else:
    tv_config_list = ["256_4_64","256_8_32"] #default configurations
    #tv_config_list = ["64_8_8"]


tv_list = [] #list containing test vectors to send to file (At the moment it's populated but not used)

for tv_conf in tv_config_list:

    #parse the string to understand which tv_conf are needed
    parsed_conf = [int(i) for i in tv_conf.split("_")]
    curr_conf_list = [] #tv_list for current config only

    #add to the final tv list all the test vectors with the desired n. of bits and configurations
    for i in all_tv:

        if i['n_bits'] == parsed_conf[0]:
            i_copy = i.copy()
            i_copy.update({'N_BITS_PER_WORD':parsed_conf[2],'N_WORDS':parsed_conf[1]})
            tv_list.append(i_copy)
            i_copy.pop('n_bits')
            curr_conf_list.append(i_copy)
    
    #once tv_list is populated write test_vectors on files (one per config):
    file_name  = "input_vectors_" + tv_conf + ".txt"

    file_lines = [tbm.send_tv_str_oneline(*i.values(),base=output_base) for i in curr_conf_list]
    file_lines[-1] = file_lines[-1][:-2] #remove last \n\r from output

    file_path = os.path.join(script_dir,rel_path,file_name)
    with open(file_path,"w") as ff:
        ff.writelines(file_lines)

    print("written ",len(curr_conf_list),"test vectors to file ",file_path)