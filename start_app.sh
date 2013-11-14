#i/bin/sh

erl -pa ebin deps/*/ebin -boot start_sasl -s myapp_app

