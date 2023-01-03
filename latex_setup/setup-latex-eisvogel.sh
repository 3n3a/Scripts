# Ubuntu
# Install needes Packages: sudo apt-get install texlive-xetex texlive-fonts-recommended texlive-fonts-extra

# Download the template for linux
mkdir /usr/share/pandoc/data/templates/eisvogel
curl -fsSL -o /usr/share/pandoc/data/templates/eisvogel/eisvogel.latex https://raw.githubusercontent.com/Wandmalfarbe/pandoc-latex-template/master/eisvogel.tex

# Command to use with Markdown
# pandoc --template=eisvogel/eisvogel.latex README.md --pdf-engine=xelatex --toc -o Zusammenfassung_M105.pdf --listings
