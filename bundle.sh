#!/bin/sh

rm -rf .bundle
rm -rf src/vendor/bundle
bundle install
bundle install --deployment --without development test --path src/vendor/bundle
