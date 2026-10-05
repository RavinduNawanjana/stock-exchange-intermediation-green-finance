.PHONY: r python notebook site all

r:
	Rscript analysis/master.R

python:
	python python/run_audit.py
	pytest -q

notebook:
	jupyter nbconvert --to notebook --execute notebooks/independent_python_audit.ipynb --output independent_python_audit_executed.ipynb

site: r
	quarto render

all: python site
