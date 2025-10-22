#!/usr/bin/python3

import os
import random
import sys
import argparse 

XRUN_UVM_HOME = "/home/summer/Cadence/XCELIUMMAIN22.09/tools/methodology/UVM/CDNS-1.2/sv/"
sim_dir = os.getcwd()
#print(sim_dir)

xrun_base_str = 'xrun -ALLOWREDEFINITION -64bit -nowarn DSEMEL -nowarn NOMTDGUI -nowarn DSEM2009 -sv -timescale 1ns/1ps -uvm -date -clean' 
xrun_base_str += ' -uvmhome '+ XRUN_UVM_HOME
xrun_gui_args = {
        'gui': ' -gui -access +rwc -input '+sim_dir+'/wave_cfg/vsim_axi_xbar.do', 
        'cw': ' -acess +rwc -input vsim_crossbar.do',
        'c': ' -access +rwc -input vsim_noprobe.do'
        }
def parse_args():
    parser = argparse.ArgumentParser(description="run script help",formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('-tool', dest='tool', choices=('xrun', 'vcs'), help='select tools (xrun, vcs)', default='xrun')
    parser.add_argument('-gui', dest='gui', help=''' Use gui or command line. \ngui: gui with waveform; \ncw: command line with waveform; \nc: command line without waveform''', choices = xrun_gui_args.keys(), default='gui')
    parser.add_argument('-test', dest='testcase', help='define the UVM_TESTCASE', default='xbar_simple_test_case')
    #parser.add_argument('-run_dir', dest='run_dir', help='set run directory', default=os.getenv('CB_PRJ_ROOT')+"/verify/out")
    parser.add_argument('-log', dest='log', help='set log file', default='xrun.log')
    parser.add_argument('-cov', dest='cov', help='set coverage enable', choices=('0','1'), default='0')
    parser.add_argument('-comp', dest='comp', help='compile option: 1-compile enable, 0-do not compile', choices=('0','1'), default='1')
    parser.add_argument('-sim', dest='sim', help='simulation option: co: compile only; ro: simulate only; cr: compile and simulate ', default='cr')
    # for test_cfg
    parser.add_argument('-en_slv_b', dest='enable_slv_b_channel', help='enable slave b channel - 0: all disable, 1: enable slave 0, 2: enable slave 1, 3: enable slave 0&1 ... this argumet will be parsed as binary bits', default='0')
    parser.add_argument('-en_slv_r', dest='enable_r_channel', help='enable slave r channel - 0:  all disable, 1: enable slave 0, 2: enable slave 1, 3: enable slave 0&1 ... this argumet will be parsed as binary bits', default='0')
    #parser.add_argument('-', dest='', help='', default=)
    args = parser.parse_args()   
    return args

def gen_compile_param(args):
    os.environ['XRUN_UVM_HOME'] = XRUN_UVM_HOME
    compile_param = ' +incdir+'+XRUN_UVM_HOME+'src'
    compile_param += ' -f %s/../flist/tb.f'%sim_dir
    #compile_param += ' -top tb_fifo_top'
    compile_param += ' -top tb_axi_xbar_top %s/../tb_axi_xbar_top.sv'%sim_dir
    compile_param += xrun_gui_args[args.gui]
    return(compile_param+' ')

def gen_run_param(args):
    run_param = ' +UVM_TESTNAME=%s '%args.testcase
    run_param += ' -svseed ' + str(random.randint(0,0xffffffff))
    run_param += ' -l %s'%(args.log)
    run_param += ' +enable_slv_b_channel=' + args.enable_slv_b_channel
    run_param += ' +enable_r_channel=' + args.enable_r_channel
    return(run_param+' ')


if __name__ == '__main__':
        args = parse_args()
        #print(args)
