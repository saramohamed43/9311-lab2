dir=$(HOME)/test
malicious_dir=$(HOME)/quarantine
interval_secs=5



antivirus: create_dir
	./antivirusd.sh $(dir) $(malicious_dir) $(interval_secs)
	
restore: create_dir
	./restore.sh $(dir) $(malicious_dir)

create_dir:
	mkdir -p $(malicious_dir)