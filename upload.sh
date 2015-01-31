#!/bin/bash

rsync -azP ./_build/html/ linux.cs.uchicago.edu:/stage/web_static/chi/htdocs/
