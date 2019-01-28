### chibug.org

This is the repository for the website of
[ChiBUG: The Chicago Area BSD Users Group](https://chibug.org/).

## Adding events

To add a new event, just create a file in `_posts` named `YYYY-mm-dd-title.md`.

The `chibug.org` website will be automatically rebuilt within a minute or two.

## Testing changes

If you are making extensive changes to the output and want to verify them in a
browser before committing, you can setup a Jekyll environment with:

	chibug.org$ bundle install
	chibug.org$ bundle exec jekyll serve

And then visit
[http://127.0.0.1:4000/](http://127.0.0.1:4000/).

Note that changes to `_config.yml` require a restart of the local webserver.
