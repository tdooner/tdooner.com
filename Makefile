deploy:
	bundle exec middleman deploy

build/resume.pdf: source/resume.json Makefile
	hackmyresume BUILD source/resume.json TO build/resume.all -t node_modules/jsonresume-theme-short
	/usr/local/bin/wkhtmltopdf --margin-top 20mm --margin-bottom 0mm --zoom 0.75 build/resume.pdf.html build/resume.pdf
