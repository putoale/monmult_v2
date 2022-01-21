import os
import tb_vec_gen as tbm
import pprint as pp
import sys

script_dir = os.path.dirname(__file__)
vec_rel_path = "../../../monmult_v2.sim/top_sim/behav/xsim"
vec_rel_path_csv = "txt"
output_base = 16

# Configs represent strings with the format C1_C2_C3 where C1=N_BITS C2=N_WORDS C3 = N_BITS_PER_WORD
# You can call this script in two modes:
#   mode 1: "script --single <config>"  => The script compares the out_results.txt file with the input vector file corresponding to the selected config
#           and it produces a .csv file with the result.

#   mode 2: "script --multi <*configs>" => The script compares (for each config) the out_results_C1_C2_C3.txt file with the input_vectors_C1_C2_C3.txt file
#           and it produces a single csv file with all results.

if len(sys.argv) > 1:
    if '--single' in sys.argv:
        mode_flag = 'single'
        config_list = sys.argv[2]

    elif '--multi' in sys.argv:
        mode_flag = 'multi'
        config_list = sys.argv[2:]

    else:
        mode_flag = 'single'
        config_list = sys.argv[2]
else:
    mode_flag = 'single'
    config_list = ["32_4_8"] #default configuration


tv_list = []
#get list of sent test vectors from file


for conf in config_list:
    parsed_conf = [int(i) for i in conf.split("_")]
    curr_conf_tv_list = []

    curr_conf_vec_file_name = "input_vectors_" + conf + ".txt"
    curr_conf_vec_file_path = os.path.join(script_dir,vec_rel_path,curr_conf_vec_file_name)

    #save all read tv into a list
    curr_conf_tv_list.extend(tbm.load_tv_from_file(curr_conf_vec_file_path,parsed_conf[1],parsed_conf[2],pow(2,parsed_conf[0]),output_base))
    print(curr_conf_tv_list)

    if mode_flag == 'single':
        res_file_name = 'out_results.txt'
    else:
        res_file_name = "out_results_" + conf + ".txt"
    
    res_file_path = os.path.join(script_dir,vec_rel_path,res_file_name)
    curr_conf_results_list = tbm.load_res_from_file(res_file_path,parsed_conf[0],output_base)

    for i in range(0,len(curr_conf_tv_list)):
        curr_conf_tv_list[i].update({'MODULE_RESULT':curr_conf_results_list[i]})

    tv_list.extend(curr_conf_tv_list)

outcome =  tbm.test_tv_pass(tv_list)

#uncomment the following lines to get a list of passed and not passed tv

#print(len(outcome['POS_tv']),' Positive Tests:')
#pp.pprint(outcome['POS_tv'],sort_dicts=0)

#print(len(outcome['NEG_tv']),' Negative Tests:')
#pp.pprint(outcome['NEG_tv'],sort_dicts=0)

csv_path = os.path.join(script_dir,vec_rel_path_csv,"out_report.csv")
tbm.print_csv_out(csv_path,tv_list)

print(len(outcome['POS_tv']),' test PASSED', ',',len(outcome['NEG_tv']),' test FAILED\n\r\n\r')