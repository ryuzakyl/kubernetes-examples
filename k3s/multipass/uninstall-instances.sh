#!/usr/bin/env bash

echo "Deleting instances ...";
multipass delete --all

echo "Purging ...";
multipass purge
