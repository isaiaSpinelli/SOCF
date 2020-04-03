SHELL := /bin/bash

EXCLUDE_DIR={./axi4lite/doc,./axi4lite/publi,./axi4lite/hard/script,./axi4lite/hard/sim,./axi4lite/hard/tb,./axi4lite/hard/eda/db,./axi4lite/hard/eda/hps_isw_handoff,./axi4lite/hard/eda/incremental_db,./axi4lite/hard/eda/output_files,./axi4lite/hard/eda/qsys_system,./axi4lite/hard/eda/simulation,./axi4lite/hard/eda/.qsys_edit,./axi4lite/soft/build,./axi4lite/soft/test}
EXCLUDE_IP_DIR={./IP_axi4lite_interface/script,./IP_axi4lite_interface/sim}
EXCLUDE_FILES={./axi4lite/hard/eda/*.tcl~,./axi4lite/hard/eda/*.txt,./axi4lite/hard/eda/*.csv,./axi4lite/hard/eda/*.qws,./axi4lite/hard/eda/*.sopcinfo,./axi4lite/soft/proj/*.axf,./axi4lite/soft/proj/*.objdump,./axi4lite/soft/proj/*.srec}

zip:
	tar --exclude=$(EXCLUDE_DIR) --exclude=$(EXCLUDE_IP_DIR) --exclude=$(EXCLUDE_FILES) -zcf ../axi4lite.tar.gz .