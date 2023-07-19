import os
import sys
sys.path.insert(0, os.path.abspath("."))
sys.path.insert(0, os.path.abspath('../../'))


project = 'ManimGL'
copyright = '2020-2021 Manim Kindergarten Team'
author = 'TonyCrane & widcardw'

version = '0.1.0'
release = ''

extensions = [
    'sphinx.ext.todo',
    'sphinx.ext.githubpages',
    'sphinx.ext.mathjax',
    'sphinx.ext.intersphinx',
    'sphinx.ext.autodoc', 
    'sphinx.ext.coverage',
    'sphinx.ext.napoleon',
    'sphinx_copybutton',
    'manim_example_ext'
]

autoclass_content = 'both'
mathjax_path = "https://fastly.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"

templates_path = ['_templates']
source_suffix = '.rst'
master_doc = 'index'
language = 'zh_CN'
html_search_language = 'zh'
pygments_style = 'default'

html_static_path = ["_static"]
html_css_files = [
    "https://mkcdn.tonycrane.cc/manimgl_assets/custom.css", 
    "https://mkcdn.tonycrane.cc/manimgl_assets/colors.css"
]
html_theme = 'furo'  # pip install furo==2020.10.5b9
html_favicon = '_static/mk.png'
html_logo = '_static/Logo_white.png'
html_theme_options = {
    "sidebar_hide_name": True,
}
