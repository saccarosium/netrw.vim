.PHONY: test
test:
	./run_test.sh vim
	./run_test.sh nvim

.PHONY: test_vim
test_vim:
	./run_test.sh vim

.PHONY: test_nvim
test_nvim:
	./run_test.sh nvim
