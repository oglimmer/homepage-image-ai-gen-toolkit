#!/bin/bash

set -eu

docker stop image_pick && docker rm image_pick || true
docker run --name image_pick -d --rm -v $PWD/tmp_select:/usr/share/nginx/html/images -v $PWD/view.html:/usr/share/nginx/html/index.html -v $PWD/default.conf:/etc/nginx/conf.d/default.conf -p 8888:80 nginx


for dir in */; do
    echo "$dir"
    if [ $dir != "tmp_select/" ]; then
        if [ "$(ls -1 "${dir}" | wc -l)" -ne 1 ]; then

            cp ${dir}* tmp_select/

            open http://localhost:8888

            echo "pick a number 1 to 4"
            read -r pick
            
            for i in {1..4}; do
                if [ "$i" != "$pick" ]; then
                    rm -rf "${dir}${i}.png"
                fi
            done

        fi
    fi
done

docker stop image_pick
rm -rf tmp_select
