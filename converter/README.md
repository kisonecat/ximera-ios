# How to use the converter

mupdf is included as a git submodule; if you have cloned the repository, you should

> cd mupdf
>
> make

to be sure that you've created `mupdf/build/debug/pdfdraw` which is
used to rasterize the PDF.

Running `ruby slice.rb sample.pdf` produces a collection of tiles,
which can then be used in a content viewers found under `readers`.
For the time being, `slice.rb` expects `pdftk` and `imagemagick` and
`pngcrush` to be installed.
