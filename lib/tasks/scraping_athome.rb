town_urls = [
            ["chiyoda", "https://www.athome.co.jp/chintai/tokyo/chiyoda-city/list"],
            #  ["chuo",    "https://www.athome.co.jp/chintai/tokyo/chuo-city/list/"],
            # ["minato",  "https://www.athome.co.jp/chintai/tokyo/minato-city/list/"],
            # ["shinjuku","https://www.athome.co.jp/chintai/tokyo/shinjuku-city/list/"],
            # ["bunkyo",  "https://www.athome.co.jp/chintai/tokyo/bunkyo-city/list/"],
            # ["shibuya", "https://www.athome.co.jp/chintai/tokyo/shibuya-city/list/"],
            # ["taito",   "https://www.athome.co.jp/chintai/tokyo/taito-city/list/"],
            # ["sumida",  "https://www.athome.co.jp/chintai/tokyo/sumida-city/list/"],
            # ["koto",    "https://www.athome.co.jp/chintai/tokyo/koto-city/list/"],
            # ["shinagawa","https://www.athome.co.jp/chintai/tokyo/shinagawa-city/list/"],
            # ["meguro",  "https://www.athome.co.jp/chintai/tokyo/meguro-city/list/"],
            # ["ota",     "https://www.athome.co.jp/chintai/tokyo/ota-city/list/"],
            # ["setagaya","https://www.athome.co.jp/chintai/tokyo/setagaya-city/list/"],
            # ["nakano",  "https://www.athome.co.jp/chintai/tokyo/nakano-city/list/"],
            # ["suginami","https://www.athome.co.jp/chintai/tokyo/suginami-city/list/"],
            # ["toshima", "https://www.athome.co.jp/chintai/tokyo/toshima-city/list/"],
            # ["kita",    "https://www.athome.co.jp/chintai/tokyo/kita-city/list/"],
            # ["arakawa", "https://www.athome.co.jp/chintai/tokyo/arakawa-city/list/"],
            # ["itabashi","https://www.athome.co.jp/chintai/tokyo/itabashi-city/list/"],
            # ["nerima",  "https://www.athome.co.jp/chintai/tokyo/nerima-city/list/"],
            # ["adachi",  "https://www.athome.co.jp/chintai/tokyo/adachi-city/list/"],
            # ["katushika", "https://www.athome.co.jp/chintai/tokyo/katsushika-city/list/"],
            # ["edogawa",   "https://www.athome.co.jp/chintai/tokyo/edogawa-city/list/"]
            ]

# main
town_urls.each do |town_url|
  MyJobJob.at_home_scrape(town_url)
end
