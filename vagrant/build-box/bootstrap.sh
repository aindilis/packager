#!/bin/bash

apt-get update

sudo apt-get install -y emacs23-nox screen

sudo apt-get install -y build-essential fakeroot devscripts

echo "escape ^]^]" >> ~/.screenrc
echo "escape ^]^]" >> /root/.screenrc
