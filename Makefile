deploy:
	bundle exec middleman deploy

build/resume.pdf: source/resume.json Makefile
	hackmyresume BUILD source/resume.json TO build/resume.pdf.html -t jsonresume-theme-short-tdooner
