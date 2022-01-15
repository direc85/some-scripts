# The Random Collection

Here you can find some scripts I use myself. The scripts are best considered beta quality - read them through before blindly running them. They work for me, but your milage may vary. If you find something worth mentioning or fixing, please drop me an issue or a pull request!

## Sailfish Screenshot Converter

Sailfish saves its screenshots in PNG format, which is not that well supported on Android apps - or at least Sailfish-to-Android sharing is troublesome. I decided to write a script that converts the PNG files to JPG format. [ImageMagick](https://imagemagick.org/script/convert.php) is used for this, it is available e.g. in [Sailfish Chum](https://github.com/sailfishos-chum/main). To further speed things up, conversion processes are run in parallel, one by core.

At some point in time, Sailfish started to have localized screenshot names, e.g. `Näyttökuva_20220114_001.png` in Finnish. No wonder my scripts looking for `Screenshot_YYYYMMDD_NNN.png` didn't work anymore! Time to turn two problems into three by getting regex involved! After a bit of trial and error, the JPG names are all renamed to start with `Screenshot` instead of the localized string.

Tracker3 seems to pick up the new images just fine, so no service manipulation necessary!

The order of the files in the gallery was wrong, and that was fixed by taking note of the original file creation time and transferring that into the new file as well. I considered updating exif data, but that quickly turned into a mess - mostly because installing Perl just for this wasn't justified, and [jhead](https://www.sentex.ca/~mwandel/jhead/) isn't packaged for Sailfish. (You *can* install [the CentOS package](https://centos.pkgs.org/7/epel-aarch64/jhead-3.03-4.el7.aarch64.rpm.html) with a bit of brute force, and it seems to work, but it's highly not recommened.)

The screenshots now appeared twice in the gallery. To fix that, source PNG files are removed after a successful conversion - but not the ones taken today. Sailfish doesn't keep note of the last saved screenshot filename, but checks the PNG files in the folder instead. to determine the next filename. Oh well, let's just not delete the screenshot file if it was taken today. To get rid of the double pictures just run the script again tomorrow!

The script works on my desktop computer running Manjaro and on my Sony Xperia 10 II running Sailfish 4.3.0.12

Happy hacking!
-- Matti
