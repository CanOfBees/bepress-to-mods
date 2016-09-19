## bepress-to-mods ##
### ~ A Metadata Transformation ~ ###

This is a repository for converting the BePress-specific metadata (available in their quarterly TARs) to MODS XML that meets the requirements of [the data dictionaries](https://wiki.lib.utk.edu/display/DLP/2016+Migration+Data+Dictionaries) on the UTK Digital Initiatives wiki.

### What it does ###

#### sample-data ####
Grab one or both of the TAR archives attached to [TRAC-128](https://jira.lib.utk.edu/browse/TRAC-128). For privacy reasons, those files will not be stored in this repository. After unpacking the archive(s) into `sample-data/`, you're ready for the next step.

#### applying the transform ####
**NOTE:** this is a preliminary transform, still under development. Applying it vs an entire bepress data dump may not be a very good idea. 

Here are two possible ways of applying this transform: A) using oXygen or B) using Saxon from the command line.

##### A. Using oXygen's project functionality. #####
 
1. This repository includes an oXygen project file. After starting oXygen, select the **Project** menu > **open project** > select *bepress-to-mods.xpr*
2. ...
3. ...

----

##### B. Using Saxon from the command line #####

1. if you don't already have an XSLT 2.0 processor available on your computer, consider grabbing one of the FOSS versions of [Saxon from sourceforge](http://saxon.sourceforge.net).

    * [Saxon-B](https://sourceforge.net/projects/saxon/files/Saxon-B/9.1.0.8/saxonb9-1-0-8j.zip/download) \[direct download\]
    * [Saxon-HE](https://sourceforge.net/projects/saxon/files/Saxon-HE/9.7/saxonHE9-7-0-1J.zip/download) \[direct download\]

2. after installing your processor, navigate to wherever you cloned this repository

    1. if you're using a downloaded Saxon and you're on Windows, I'm afraid that I lack sufficient familiarity with your platform to provide steps for testing this. :( sorry. 
    2. if you're using Mac or a *nix system there are a few options:
        1. something like `$ java -jar /path/to/where/the/Saxon/download/landed/saxon9he.jar -it:main -xsl:empty-element-test.xsl`
        2. or if you installed saxon from a package manager system `$ saxon -it:main -xsl:stylesheet.xsl`

**note:** you'll need Java for both of those downloads. Alternately you can use oXygen to test this transform (you'll still need Java).