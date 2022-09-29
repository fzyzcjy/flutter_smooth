export_logo:
    /Applications/Inkscape.app/Contents/MacOS/inkscape --export-filename=doc/logo/logo.png doc/logo/logo.svg -w 1280 -h 480
    convert doc/logo/logo.png -background transparent -gravity center -extent 1280x640 doc/logo/logo_1280x640.png
