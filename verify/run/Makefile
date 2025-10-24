# 
#
#

.PHONY: debug compile sim clear

RUN_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PRJ_ROOT := ${RUN_DIR}/../..
DUT_DIR := ${PRJ_ROOT}/design
DV_DIR := ${PRJ_ROOT}/verify


TESTNAME ?= xbar_simple_test_case
TOOL_VAL ?= xrun 
TOOL_OPTION = -tool xrun 
SIM_VAL ?= cr
GUI_VAL ?= gui 

PRE_RUN_OPTIONS = -test ${TESTNAME} 
PRE_RUN_OPTIONS += -gui gui 

RUN_OPTIONs := run 
RUN_OPTIONs += ${PRE_RUN_OPTIONS} 
RUN_OPTIONs += ${TOOL_OPTION} 

compile: 
	run -sim ro &

sim: 
	./run_test -test ${TESTNAME} -sim rc -gui gui &
sim_no_b:
	./run_test -test ${TESTNAME} -sim rc -gui gui -en_slv_b 0 &
sim_b:
	./run_test -test ${TESTNAME} -sim rc -gui gui -en_slv_b 15 &
sim_no_r:
	./run_test -test ${TESTNAME} -sim rc -gui gui -en_slv_b 15 &
sim_r: 
	./run_test -test ${TESTNAME} -sim rc -gui gui -en_slv_b 15 -en_slv_r 15 &
sim_atomic_no_b: 
	./run_test -test xbar_atomic_transaction_test_case -sim rc -gui gui -en_slv_r 15 &
sim_atomic: 
	./run_test -test xbar_atomic_transaction_test_case -sim rc -gui gui -en_slv_b 15 -en_slv_r 15 &
sim_err:
	./run_test -test xbar_addr_random_test_case -sim rc -gui gui -en_slv_b 15 -en_slv_r 15 &

clear: 
	rm -rf __pycache__ 
	rm -rf run_result


debug: 
	@echo "RUN_DIR location: "${RUN_DIR}
	@echo "PRJ_ROOT location: "${PRJ_ROOT}
	@echo "DUT_DIR location: "${DUT_DIR}
	@echo "DV_DIR location: "${DV_DIR}
	@echo "PRE_RUN_OPTIONS : "${PRE_RUN_OPTIONS}
	@echo "TOOL_OPTION : "${TOOL_OPTION}
	@echo "RUN_OPTIONs : "${RUN_OPTIONs}
