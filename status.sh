#!/bin/bash
#
# Copyright (C) 2016, David Abián <da [at] davidabian.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

seconds_timeout=6

function print_ok {
    echo "<td class=\"status status_ok\"><div class=\"status_scrolling\">$1</div></td>"
}

function print_error {
    if [[ "n$1" == "n" ]]; then
        echo "<td class=\"status status_error\"><div class=\"status_scrolling\">Not reachable</div></td>"
    else
        echo "<td class=\"status status_error\"><div class=\"status_scrolling\">$1</div></td>"
    fi
}

function print_table_start {
    echo "<h2 id=\"$1\">$1</h2>"
    echo "<table>"
    echo "<tr>"
    echo -n "<th>webpage</th><th class=\"column_http\">HTTP&nbsp;details</th>"
    echo    "<th class=\"column_https\">HTTPS&nbsp;details</th>"
    echo "</tr>"
}

function print_table_end {
    echo "</table>"
}

function print_status {
    status=$(timeout ${seconds_timeout}s curl -s --head -- "$1")
    if [[ $? -eq 124 ]]; then
        status="Timeout (${seconds_timeout}&nbsp;s)"
    else
        status=$(echo "$status" | \
            sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g' | \
            sed ':a;N;$!ba;s/\n/<br>/g')
    fi
    echo "$status" | head -n 1 | grep "HTTP/1.[01] [23].." > /dev/null && \
        print_ok "$status" || print_error "$status"
}

function print_item {
    item=$1
    echo "<tr id=\"${item}\">"
    echo "<td class=\"item\"><a href=\"http://${item}/\" target=\"_blank\">${item}</a></td>"
    print_status "http://${item}/"
    print_status "https://${item}/"
    echo "</tr>"
}

echo "<!DOCTYPE html>"
echo "<html>"
echo "<head>"
echo "<title>Wikimedia availability</title>"
echo "<link rel=\"stylesheet\" type=\"text/css\" href=\"./status.css\">"
echo "</head>"
echo "<body>"
echo "<h1>Availability of non-WMF Wikimedia webpages</h1>"

chapters=(
    "wikimedia.at"
    "wikimedia.be"
    "wikimedia.ca"
    "wikimedia.ch"
    "wikimedia.cz"
    "wikimedia.de"
    "wikimedia.es"
    "blog.wikimedia.es"
    "wikimedia.fr"
    "wikimedia.hk"
    "wikimedia.hu"
    "wikimedia.in"
    "wikimedia.it"
    "wikimedia.mx"
    "wikimedia.nl"
    "wikimedia.or.id"
    "wikimedia.org.am"
    "wikimedia.org.ar"
    "wikimedia.org.au"
    "wikimedia.org.bd"
    "wikimedia.org.fi"
    "wikimedia.org.il"
    "wikimedia.org.ph"
    "wikimedia.org.uk"
    "wikimedia.org.ve"
    "wikimedia.org.za"
    "wikimedia.pt"
    "wikimedia.se"
    "wikimediachile.cl"
    "wikimediadc.org"
)
print_table_start "Wikimedia chapters"
for item in ${chapters[*]}
do
    print_item "$item"
done
print_table_end

user_groups=(
    "wikimedia.gr"
)
print_table_start "Wikimedia user groups"
for item in ${user_groups[*]}
do
    print_item "$item"
done
echo "</table>"

echo "</body>"
echo "</html>"

contests=(
    "wikilovesearth.org"
    "wikilovesmonuments.org"
    "wikilov.es"
)
print_table_start "Wikimedia contests"
for item in ${contests[*]}
do
    print_item "$item"
done
echo "</table>"

echo "</body>"
echo "</html>"
