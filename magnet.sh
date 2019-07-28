#!/bin/bash

fqdn="yts.lt"
encoded="1080p"

search () {
	echo "recherche de l'ID du film"
	ID=`curl -s --request GET "https://$fqdn/api/v2/list_movies.json?limit=50" | jq '.data.movies[] | select(.title | test("'$1'"))' | grep -oP '(?<="id": )[^,]*'`
	echo "> $ID"
}

magnet () {
	echo "récupération du hash"
	TORRENT_HASH=`curl -s --request GET https://$fqdn/api/v2/movie_details.json?movie_id=$1 | jq '.data[]' | jq '.torrents[] | select(.quality | test("1080p"))' | grep -oP '(?<="hash": ")[^"]*'`
	echo "> $TORRENT_HASH"
	echo "récupération du titre"
	TITLE=`curl -s --request GET https://$fqdn/api/v2/movie_details.json?movie_id=$1 | jq '.data[]' | grep -oP '(?<="title": ")[^"]*'`
	echo "> $TITLE"
	echo "récupération de l'url"
	URL=`curl -s --request GET https://$fqdn/api/v2/movie_details.json?movie_id=$1 | jq '.data[]' | grep -oP '(?<="url": ")[^"]*' | head -1`
	echo "> $URL"
	echo "génération du magnet"
	MAGNET="magnet:?xt=urn:btih:$TORRENT_HASH&dn=$URL+$encoded+$1+$TITLE&tr=udp://open.demonii.com:1337/announce&tr=udp://tracker.openbittorrent.com:80&tr=udp://tracker.coppersurfer.tk:6969&tr=udp://glotorrents.pw:6969/announce&tr=udp://tracker.opentrackr.org:1337/announce&tr=udp://torrent.gresille.org:80/announce&tr=udp://p4p.arenabg.com:1337&tr=udp://tracker.leechers-paradise.org:6969"
	echo $MAGNET
}

search $@
magnet $ID

#EOF
