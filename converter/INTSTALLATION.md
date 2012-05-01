How to Install and Use the XiMeRa Converter on Mac OS 10.7
==========================================================

You'll need to install the following:
* Ruby 
* Pngcrush 
* MuPDF

Installing Ruby
---------------

You will need Ruby 1.9. Snow Leopard and Lion ship with Ruby 1.8.7,
but this is an old version and we'll need at least 1.9.3. We won't be
updating the system-installed Ruby. That way, you'll be able to switch
back and forth between these Ruby versions if you like.  

1. RVM compiles Ruby versions from source code, and to do that it uses
   the GCC compiler. Check to see if you have GCC installed by opening
   a Terminal session and typing (if you are viewing this as a plain
   txt file, you see the code inside of backtick quotes ` )

   `gcc --version`

   If you see a version number, then you're all set. If not, then you
   need to install GCC.

2. Next, to install RVM from its GitHub repository (the recommended
   way), you need a working version of the git version control system.
   Check to see if you already have git installed by typing the
   following:

   `git --version` 

   If you see a version number, then you're good to go. If the git
   command isn't found, then download the latest version of the
   graphical Git installer from the git-osx-installer downloads page.

   http://code.google.com/p/git-osx-installer/

   Once it has finished downloading, simply double-click the .dmg file
   to start the installation process.

3. With that out of the way, install RVM by going back to your
   Terminal prompt and typing (or copying and pasting) the following:

   `bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)`

   Be careful: there are two less-than signs in this command, with a
   space between them.

4. When the RVM installation is complete (it's fairly quick), reload
   your Terminal shell environment by typing

   `source ~/.bash_profile`

   This knits RVM into your environment and causes RVM to be loaded
   into any new Terminal sessions.

5. Close your Terminal session and open a new session. Then confirm
   that RVM is being loaded properly by typing
 
   `type rvm | head -1` 

   You should see the following: 

   `rvm is a function`

6. Now that you have RVM installed, you're ready to install Ruby
   1.9.3. To do that, type

   `rvm install 1.9.3`

   If you get an error and you have Xcode 4.2 installed, you may have
   to use

   `rvm install 1.9.3 --with-gcc=clang`

   This will download, compile, and install Ruby 1.9.3 into a
   directory managed by RVM (it's under the ~/.rvm directory).  When
   the installation is done and you're back at a command prompt, set
   Ruby 1.9.3 as the current Ruby version in your Terminal session by
   typing
 
   `rvm use 1.9.3` 

7. Then verify that Ruby 1.9.3 is the current Ruby version by typing 

   `ruby -v` 

   You should see something like 

   `ruby 1.9.3 (2012-02-16 revision 34643) [x86_64-darwin11.3.0]`

8. Now set Ruby 1.9.3 as the default version to be used whenever you
   open any new Terminal sessions by typing

   `rvm --default 1.9.3` 

9. Finally, although not required, you'll likely want to generate the Ruby core    documentation by typing 

   `rvm docs generate` 

   This takes a little while to complete, but in the end you'll have
   all the Ruby documentation at your fingertips.

   You can now easily switch between Ruby versions. For example, if
   you ever want to go back to the system-installed version of Ruby
   (1.8.7), simply type

   `rvm system`

   And to switch back to Ruby 1.9.3, type 

   `rvm 1.9.3`

   Alternatively, you can switch back to the default version (1.9.3)
   by typing rvm default And when a new version of Ruby comes along,
   you can easily install it alongside your existing versions.


Installing Pngcrush
-------------------

1. Download pngcrush: 

   http://sourceforge.net/projects/pmt/files/pngcrush/1.7.20

2. Extract the source code

3. While in the pngcrush-1.7.2 folder, run these commands to compile it.

   `make` 

   `sudo mv pngcrush /user/local/bin`

   The make command compiles the code. Next line move the executable
   to /usr/local/bin. It does not matter where you move the compiled
   executable, but we recommend that you put it in a place within your
   environment’s path.

   Note: where to put the pngcrush folder : After downloading and
   unzipping the pngcrush, rename the folder as pngcrush.  It should
   be put inside the ximera/converter directory.


Installing MuPDF
----------------

In order to install mupdf you will need several third party libraries:
freetype2, jbig2dec, libjpeg, openjpeg, and zlib. There is a package
(mupdf-thirdparty.zip) that you can unzip in the mupdf source tree if
you don't have them installed on your system.

Download: 

http://code.google.com/p/mupdf/downloads/list?q=source

Download both the source and thirdparty file. The directory mupdf
should be put inside ximera/converter and thirdparty should be inside
ximera/converter/mupdf

While in the mupdf folder, run these commands to compile it.

`make` 

If you get an error then perhaps the configuration file for MuPDF has
misidentified the architecture of the computer. You can fix this by
making the changes describe below. The changes to the makeconfig file
are underlined. If you are working with a 32bit Mac, then

`CFLAGS`
and 

`LDFLAGS`

should be set to -m32:

You can find makeconfig file inside the mupdf folder with the name makerule

```
# Mac OS X build depends on some thirdparty libs
ifeq "$(OS)" "Darwin"
SYS_FREETYPE_INC := -I/usr/X11R6/include/freetype2
CFLAGS += -I/usr/X11R6/include
LDFLAGS += -L/usr/X11R6/lib
RANLIB_CMD = ranlib $@
X11_LIBS := -lX11 -lXext
#ifeq "$(arch)" "amd64"
CFLAGS += -m64
LDFLAGS += -m64
#else
#CFLAGS += -m32
#LDFLAGS += -m32
#endif
endif
```

At this point you should be ready to run extract.rb and slice.rb.




