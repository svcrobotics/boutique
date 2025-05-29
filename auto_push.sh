#!/bin/bash

cd /home/victor/boutique

# Sauvegarde Git
git add storage
git commit -m "Sauvegarde automatique (boot)" --allow-empty
git push
