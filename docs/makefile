all: spec.pdf
	open spec.pdf

spec.pdf: spec.tex
	platex spec
	dvipdfmx spec
	-git commit -am "$(shell date '+%Y/%m/%d %H:%M')"

clean:
	rm spec.{aux,dvi,log,pdf}
