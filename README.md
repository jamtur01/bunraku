Bunraku
=======

Description
-----------

A Puppet report handler and simple Sinatra dashboard

Requirements
------------

* `rest-client`
* `json`
* `puppet`
* `redis`
* `sinatra`

Installation & Usage
-------------------

1.  Install the required gems

        $ sudo gem install rest-client json redis sinatra

2.  Install a Redis server.

3.  Install bunraku-report as a module in your Puppet master's module
    path.

4.  Enable pluginsync and reports on your master and clients in `puppet.conf`

        [master]
        report = true
        reports = bunraku
        pluginsync = true
        [agent]
        report = true
        pluginsync = true

5.  Run the Puppet client and sync the report as a plugin

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
