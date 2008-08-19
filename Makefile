#!/usr/bin/make -f

NAME := textformat
FILES := */$(NAME).*

$(NAME).vba.gz: $(NAME).vba
	gzip -9 --stdout $^ >$@

$(NAME).vba: $(FILES)
	printf "%s\n" $^ | vim \
		-c 'let g:vimball_home="."' \
		-c 'silent! 1,$$MkVimball! $(NAME)' \
		-c 'qa!' -

clean:
	rm -f *.vba *.vba.gz

.PHONY: clean
