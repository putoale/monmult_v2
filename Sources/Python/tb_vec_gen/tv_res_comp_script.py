import os
import tb_vec_gen as tbm
import pprint as pp

script_dir = os.path.dirname(__file__)
vec_rel_path = "txt"
vec_file_name_256_4_64 = "input_vectors.txt"
res_file_name = "out_results.txt"
res_file_name_256_4_64 = "out_results.txt"
vec_f_cplt_path = os.path.join(script_dir,vec_rel_path,vec_file_name_256_4_64)

tv_res_f_cplt_path = os.path.join(script_dir,vec_rel_path,res_file_name)
tv_res_f_cplt_path_256_4_64 = os.path.join(script_dir,vec_rel_path,res_file_name)

csv_path = os.path.join(script_dir,vec_rel_path,"out_report.csv")


r_256 = pow(2,256)
r_512 = pow(2,512)

tv_list = []
#get list of sent test vectors from file

#256 bit, 4 words, 64 bits_per word
tv_list.extend(tbm.load_tv_from_file(vec_f_cplt_path,4,64,r_256))


#read module results from file
module_results_list_256_4_64 = tbm.load_res_from_file(tv_res_f_cplt_path_256_4_64)


#add module results to tv_list

#256_4_64 tv
for i in range(0,len(tv_list)):
    tv_list[i].update({'module_result':module_results_list_256_4_64[i]})


tbm.test_tv_pass(tv_list)

tbm.print_csv_out(csv_path,tv_list)


#pp.pprint(tv_list,sort_dicts=0)