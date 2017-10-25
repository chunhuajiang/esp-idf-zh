#!/bin/sh

[ -f '.REQUIREMENT_FLAG' ] || sudo pip install -r requirements.txt && touch .REQUIREMENT_FLAG
make html 
gnome-open _build/html/index.html

