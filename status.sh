#!/bin/bash
#
#  Copyright (C) 2016, David Abián <da [at] davidabian.com>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#  Source: <https://github.com/davidabian/wm-status>

seconds_timeout=12

declare -A emails=(
    #
    #  Include here the email address to which to send a
    #  warning concerning your webpage.
    #  Add '' strings to prevent spam: 'use''r@gm''ail.com'
    #
    ['wikilov.es']='davi''dabian@wik''imedia.es'
    ['wikimedia.es']='davi''dabian@wik''imedia.es'
    ['blog.wikimedia.es']='davi''dabian@wik''imedia.es'
)
chapters=(
    #
    #  Include here your Wikimedia webpage(s).
    #
    'wikimedia.at'
    'wikimedia.be'
    'wikimedia.ca'
    'wikimedia.ch'
    'wikimedia.cz'
    'wikimedia.de'
    'wikimedia.es'
    'blog.wikimedia.es'
    'wikimedia.fr'
    'wikimedia.hk'
    'wikimedia.hu'
    'wikimedia.in'
    'wikimedia.it'
    'wikimedia.mx'
    'wikimedia.nl'
    'wikimedia.or.id'
    'wikimedia.org.am'
    'wikimedia.org.ar'
    'wikimedia.org.au'
    'wikimedia.org.bd'
    'wikimedia.org.fi'
    'wikimedia.org.il'
    'wikimedia.org.ph'
    'wikimedia.org.uk'
    'wikimedia.org.ve'
    'wikimedia.org.za'
    'wikimedia.pt'
    'wikimedia.se'
    'wikimediachile.cl'
    'wikimediadc.org'
)
thematic_orgs=(
    #
    #  Include here your Wikimedia webpage(s).
    #
    'wikimedia.cat'
)
user_groups=(
    #
    #  Include here your Wikimedia webpage(s).
    #
    'wikimedia.gr'
    'blog.wikimedia.gr'
)
contests=(
    #
    #  Include here your Wikimedia webpage(s).
    #
    'wikilovesearth.org'
    'wikilovesmonuments.org'
    'wikilov.es'
)


##############################################################################
#                                  FUNCTIONS                                 
##############################################################################

function print_ok {
    echo "<td class=\"status status_ok\"><div class=\"status_scrolling\">$1</div></td>"
    return 0
}

function print_error {
    if [[ "n$1" == "n" ]]; then
        echo "<td class=\"status status_error\"><div class=\"status_scrolling\">Not reachable</div></td>"
    else
        echo "<td class=\"status status_error\"><div class=\"status_scrolling\">$1</div></td>"
    fi
    return -1
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
    echo '</table>'
}

function print_status {
    status=$(timeout $((seconds_timeout*4))s curl -s --head \
        --user-agent "Checking availability status of Wikimedia websites" \
        --referer "https://tools.wmflabs.org/status/" \
        --location \
        --retry 5 \
        --max-time $seconds_timeout \
        -- "$1")
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

function process_item {
    item=$1
    email_address=$2
    echo "<tr id=\"${item}\">"
    echo "<td class=\"item\"><a href=\"http://${item}/\" target=\"_blank\">${item}</a></td>"
    print_status "http://${item}/" || \
        if [[ "n$email_address" != "n" ]]; then
            echo -e "Subject: WARNING: $item is not reachable\r\n\r\n" \
                    "Hi,\r\n\r\n" \
                    "We've detected that http://${item}/ could be down right now.\r\n" \
                    "Please, check out.\r\n\r\n" \
                    "Regards,\r\n" \
                    "your friendly Wikimedia status checker\r\n\r\n" \
                    "-- \r\n" \
                    "https://tools.wmflabs.org/status/\r\n" \
                    "Checking the availability status of Wikimedia webpages\r\n" \
                    "not hosted by the Wikimedia Foundation, Inc.\r\n" | \
                    /usr/sbin/exim -odf -i "${email_address}"
        fi
    print_status "https://${item}/"
    echo "</tr>"
}


##############################################################################
#                                     MAIN                                   
##############################################################################

echo '<!DOCTYPE html>'
echo '<html>'
echo '<head>'
echo '<meta charset="UTF-8">'
echo '<title>Wikimedia availability</title>'
echo '<link rel="stylesheet" type="text/css" href="./status.css">'
echo '</head>'
echo '<body>'
echo '<div class="related_links">'
echo 'a tool by <a href="https://davidabian.com/">David&nbsp;Abián</a> | '
echo '<a href="https://github.com/davidabian/wm-status">source&nbsp;code</a> - '
echo '<a href="https://meta.wikimedia.org/wiki/User_talk:Abi%C3%A1n">contact</a> - '
echo '<a href="https://phabricator.wikimedia.org/T140884">origin</a> - '
echo '<a href="https://tools.wmflabs.org/?list">more&nbsp;tools</a>'
echo '</div>'
echo '<h1>Availability&nbsp;status of Wikimedia&nbsp;webpages not&nbsp;hosted' \
     'by&nbsp;the&nbsp;WMF</h1>'
echo '<p>To check out the current performance and availability status of the' \
     'websites hosted by the Wikimedia&nbsp;Foundation,&nbsp;Inc., including' \
     'Wikipedia and its sister&nbsp;projects, see' \
     '<a href="https://status.wikimedia.org/">status.wikimedia.org</a>.</p>'

print_table_start "Wikimedia chapters"
for item in ${chapters[*]}
do process_item "$item" "${emails[$item]}"
done
print_table_end

print_table_start 'Wikimedia thematic organizations'
for item in ${thematic_orgs[*]}
do process_item "$item" "${emails[$item]}"
done
print_table_end

print_table_start 'Wikimedia user groups'
for item in ${user_groups[*]}
do process_item "$item" "${emails[$item]}"
done
print_table_end

print_table_start 'Wikimedia contests'
for item in ${contests[*]}
do process_item "$item" "${emails[$item]}"
done
print_table_end

echo '</body>'
echo '</html>'
