Instructions for Conversion
===========================

If you have trouble following these instructions, please contact Bart Snapp at snapp@math.osu.edu, or Jim Fowler at fowler@math.osu.edu.

To start you'll need to add the package `ximera` in your latex document. This will probably require some editing of your macros or of the package itself. Next PDFLaTeX your document. Now run the following two scripts:

`ruby slice.rb sample.pdf`

and

`ruby extract.rb sample.pdf`

This should generate the documents: "tile#-#.png," "page#.png," and *.plist where the # designates a number and the * designates the name of your file. 

You'll need to drop the tiles and the html into the correct place.

Now the .js files need to be put into the Targets/Build phases area of XCode...

More to come...