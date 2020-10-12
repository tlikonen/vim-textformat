NAME := textformat
FILES := */$(NAME).*

$(NAME).vmb.gz: $(NAME).vmb
	gzip -9 --stdout $^ >$@

$(NAME).vmb: $(FILES)
	printf "%s\n" $^ | vim \
		-c 'let g:vimball_home="."' \
		-c 'silent! 1,$$MkVimball! $(NAME)' \
		-c 'qa!' -

clean:
	rm -f *.vmb *.vmb.gz

.PHONY: clean
