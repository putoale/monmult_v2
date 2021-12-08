import os
import tb_vec_gen as tbm

script_dir = os.path.dirname(__file__)
vec_rel_path = "txt"
vec_file_name = "input_vectors.txt"
res_file_name = "out_results.txt"
vec_f_cplt_path = os.path.join(script_dir,vec_rel_path,vec_file_name)
tv_res_f_cplt_path = os.path.join(script_dir,vec_rel_path,res_file_name)


n_words = 4
n_bits_per_word = 64
total_n_bits = n_words * n_bits_per_word
r = pow(2,total_n_bits)


#get list of sent test vectors from file
tv_list = tbm.load_tv_from_file(vec_f_cplt_path,4,64,r)

#add r value to tv_list
[tv.update({'r': r}) for tv in tv_list]

#compute golden results
golden_list = [tbm.monmult_int(*list(tv.values())[:3],r) for tv in tv_list]


#read module results from file
module_results_list = tbm.load_res_from_file(tv_res_f_cplt_path)

#add module results to tv_list
for i in range(0,len(tv_list)):
    tv_list[i].update({'module_results':module_results_list[i]})

#add golden results to tv_list
for i in range(0,len(tv_list)):
    tv_list[i].update({'golden_result':golden_list[i]})

