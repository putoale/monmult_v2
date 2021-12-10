import tb_vec_gen as tbm
import math as m
import gmpy2 as g
import pprint as pp

test_vec_256_1 = {
    'a': 0xe41be5bde54ea01c5fd8132dae3c50bd9f96c5af1324a68d08d978048f69bf76,
    'b': 0xf9852cd21de6a57f70ba175bea2fffc2a40a26a7d424cf6f3cc8843f9135d1ed,
    'n': 0xb6fb5f6da48f54fc63af7b4b3e9c3631cd781a526fb464a66bb3e127e74e2c25,
    'r': 0x10000000000000000000000000000000000000000000000000000000000000000
}

test_vec_256_2 = {
    'a': 0xa9bf5dff81ef3871f8206ecdd8b673cfb0b6737d5a983628babdca532e76f1ef,
    'b': 0xc893cd7b64513b7a2652d8e4865dc4d07af5bb3bd1ef10aa28197d81e622029f,
    'n': 0xbaa9614c0aff9d805f10ab09561f9bb9879bcf08bd25aa6955db00b696ac2173,
    'r': 0x10000000000000000000000000000000000000000000000000000000000000000
}

test_vec_32_2 = {
    'a': 0xabcdef99,
    'b': 0x9876abed,
    'n': 0xfde9fde9,
    'r': 0x100000000
}

test_vec_32_1 = {
    'a': 0x12345678,
    'b': 0x9abcdef1,
    'n': 0xfde9fde9,
    'r': 0x100000000
}

tv_256_list = [test_vec_256_1,test_vec_256_2]

tv_32_list = [test_vec_32_1,test_vec_32_2]

tv_list = [] #list containing test vectors to send to file

tv_list.extend([test_vec_256_1,test_vec_256_2])
#tv_list.extend([test_vec_32_2,test_vec_32_2])
#tv_list.append(test_vec_32_2)

file_lines =[] #create empty list to send to file

#populate file_lines from tv_list (256_4_64)
for i in tv_list:
    file_lines.append(tbm.send_tv_str_oneline(*i.values(),64,4,16))

#populate file_lines from tv_list (16_4_8)
#for i in tv_list:
    #file_lines.append(tbm.send_tv_str_oneline(*i.values(),8,4,16))

if len(file_lines) > 1:
    file_lines[-1] = file_lines[-1][:-2] #remove last \n\r from output
else:
    file_lines[0] = file_lines[0][:-2] #remove last \n\r from output

# find path of file to write to
import os
script_dir = os.path.dirname(__file__)
rel_path = "txt"
file_name = "input_vectors_256_4_64.txt"
complete_path = os.path.join(script_dir,rel_path,file_name)

with open(complete_path,"w") as ff:
    ff.writelines(file_lines)