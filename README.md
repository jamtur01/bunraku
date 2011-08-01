Bunraku
=======

Description
-----------

A Puppet report handler and simple Sinatra status panel

Requirements
------------

* `json`
* `puppet`
* `redis`
* `sinatra`

Installation & Usage
-------------------

1.  Install the required gems on the server

        $ sudo gem install json redis sinatra

2.  Install a Redis server. It assumes Redis is running on the default
    localhost on port 6379. You can override this with the
    `--redis-server` and `--redis-port` command line options.

3.  Run the Bunraku server:

        $ bin/bunraku-server

    This will run bunraku-server from the in-built Sinatra 
    webserver. The bunraku-server directory also contains a `config.ru`
    file you can use with `rackup` if required.

4.  Install bunraku-report as a module in your Puppet master's module
    path.  You will also need to install the `rest-client` gem on this
    host.

5.  Update the `status_url` variable in the `bunraku.yaml` file
    with the URL for your Bunraku dashboard and copy the file to 
    `/etc/puppet/`. An example file is included.

6.  Enable pluginsync and reports on your master and clients in `puppet.conf`

        [master]
        report = true
        reports = bunraku
        pluginsync = true
        [agent]
        report = true
        pluginsync = true

7.  Run the Puppet client and sync the report as a plugin

8.  Browse to the Bunraku server at http://example.com:4567

Author
------

James Turnbull <james@lovedthanlost.net>

License
-------

    Author:: James Turnbull (<james@lovedthanlost.net>)
    Copyright:: Copyright (c) 2011 James Turnbull
    License:: Apache License, Version 2.0

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
