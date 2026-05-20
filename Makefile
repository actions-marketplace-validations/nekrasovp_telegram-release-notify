.PHONY: test check verify

test:
	bash -n scripts/send-telegram.sh
	bash -n test/smoke.sh
	bash test/smoke.sh

check: test

verify: test
