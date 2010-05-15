NoSQL trends
============

NoSQL trends is a web site that graphs the popularity of NoSQL databases in
function of the number of their tweets.

**Keywords**: Ruby, Eventmachine, Twitter Stream, OAuth, MongoDB, map/Reduce,
Bayes Classification, Thin, Mustache, Git, and more :-)


TODO
----

* show THE graph
* twitter widget
* nginx vhost
* use the tweets from Mongo from the training
* complete the NoSQL databases list
* moderation interface


Install
-------

    # aptitude install ruby rubygems mongodb
    # gem install rake eventmachine thin json_pure
    # gem install twitter-stream classifier mustache
    # gem install bson_ext em-mongo oauth em-http-request

Adding the good index in MongoDB:

    $ mongo trends
    > db.tweets.ensureIndex( {created_at: 1} )

See also
--------

* [Git repository](http://github.com/nono/NoSQL-trends)
* [Twitter account](http://twitter.com/nosqltrends)


Copyright
---------

The code is licensed as GNU AGPLv3. See the LICENSE file for the full license.

Copyright (c) 2010 Bruno Michel <brmichel@free.fr>
