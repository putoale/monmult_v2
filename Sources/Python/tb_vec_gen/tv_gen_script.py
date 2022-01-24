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

test_vec_256_4 = {
    'a': 0xadb09a026dd44879f2105d553469fcaa036f4cf64450f1d7f36be42497926400,
    'b': 0x80b2a5ad7645210135d2908799f573eab3a2dbe497f669ccc907f65b47e8c205,
    'n': 0xbe0887bad260f54a528fb17779e03a7c7bea418f3fb4ced2a5cc8f841c7e28a5,
    'r': 0x10000000000000000000000000000000000000000000000000000000000000000,
    'n_bits':256
}

test_vec_256_5 = {
    'a': 0xf8f89a1014078fe4c1c403074dd57d2e2af0ea5ff74467d58f3ff278749cd6e6,
    'b': 0xae435f91aad89bf845fba8b69cc0da52d6c5776714d63f6d3823f98b1712c2cc,
    'n': 0x880d640184375378e15e975b2b7550a974dccab541a5addd9ce5ff01128a7005,
    'r': 0x10000000000000000000000000000000000000000000000000000000000000000,
    'n_bits':256
}

test_vec_512_1 = {
    'a': 0x919425cebf5038fd6692568fc18014529d527f6e2eae2ca7adc83a73e4398416ba139cbd0f1b1a7171f60e7b6bbd086461460d8d3eebc517c5ca407d38ec7b31,
    'b': 0x86c345f271827b60c4df90e44ef9e8afce5b6364efb558aee9ff7aaed0538a214b5cfb536cc005243cf7838b5ac5b7cac8f49ecdbc137f2635f71ce640a303bc,
    'n': 0xc2b4f82ee693407aa871d788f2d874298cefb19c4a396e671b6e9beef6ac89747f6de818d6d7d6e19a71940f6b5084b573fb0f65712f41da7a73891399729741,
    'r': 0x10000000000000000000000000000000000000000000000000000000000000000,
    'n_bits':512
}

test_vec_512_2 = {
    'a': 0xd62097cebd3dce1096e056e7b418a257f16e31457e667a54dca66bdf6b533f32ef79c4e864566a7c2e06b58670f4a0a139f3bca33081c61b48a46faeba2d9077,
    'b': 0xa9b46f130a25ce8dc3e8a76ac00318b2bd864d7dd1eec4a8ea93b5114e55e230f32cdf1c37a78c340499c8385e39abd767f2fbebbf717092ba80711bf6dbdfe,
    'n': 0xb73ae3e1bb5c756c2a550dc96a54905797040a8c93816c9271ad0c1d3115f219406d5c1013623046ecd13e7c410375409dc360de2d9271a685617cc0121d8ec7,
    'r': 0x10000000000000000000000000000000000000000000000000000000000000000,
    'n_bits':512
}

test_vec_512_3 = {
    'a': 0xf5e66bb5f19d9bab2025df6ed5a84b4cb36b61a54143fa5a09dd4cbc0570ad55a416594d23bf9438722dafb96824de9e3f9169670b55cba60290afb3df8686b9,
    'b': 0xd615915ab93019a7420b38686b83f769c82ec1d85a5ab3183a44d3d1aff468c6bedb4e0d706bb8a97957958e1e932548c9c2c78c90763d1ead66e650d036e8ef,
    'n': 0xcd86300a395dde2937c9610b5442d3c141bf5069cf4caba2b3e0b07b7bf22e0632195360a6c5c8f69a11aadca2f831c29c8343140a275f899193c739ee5d6119,
    'r': 0x10000000000000000000000000000000000000000000000000000000000000000,
    'n_bits':512
}

test_vec_512_4 = {
    'a': 0xeb63a1f8c173dfb22fb06c830d93602a840c2ec3bc7a375a2ff80f68ad856b6eef641c7f0d694685bed758239caad60b4d1a261a3985d04b6be492351a3fefb3,
    'b': 0xa162d9a386bb7729d6ef07eb3dfadb46e5563cdf78f66a36b8b4c98b8cff48366c61a2fa4a9cd4ba697c4a69cc93c2e67dcce9d1f727a4816941050c62cf1c89,
    'n': 0x959d0296f86a6fde340509ce489f2b39fa83ef317482d1893f748a4b486d8111d7a4e6640864823b2760a7a4b359dc8645de851a28e1eb3d997ddf40ea4fb5a3,
    'r': 0x10000000000000000000000000000000000000000000000000000000000000000,
    'n_bits':512
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

all_tv = [test_vec_256_1,test_vec_256_2,test_vec_256_3,test_vec_256_4,test_vec_256_5,test_vec_512_1,test_vec_512_2,test_vec_512_3,test_vec_512_4,test_vec_32_1,test_vec_32_2,test_vec_64_1] #list with all test vectors

all_tv.extend(tbm.generate_tv(64,10))
all_tv.extend(tbm.generate_tv(128,10))
all_tv.extend(tbm.generate_tv(256,10))
all_tv.extend(tbm.generate_tv(512,20))

# you can call this script specifying a configuration. E.g. "python3 script 256_4_64 256_8_32 32_4_8" will print all 256 bits tv with 4 words and
# 64 bits per word, in a file named "input_vectors_256_4_64" and so on...
# If the script is called without any args, it assumes the default configuration

if len(sys.argv) > 1:
    tv_config_list = sys.argv[1:]
else:
    tv_config_list = ["32_4_8","64_4_16"] #default configurations
    #tv_config_list = ["64_8_8"]


tv_list = [] #list containing test vectors to send to file (At this point it's populated but not used)

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
