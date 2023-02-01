TEST := test/*_test.rb

.PHONY : test

test :
	ruby $(TEST)
