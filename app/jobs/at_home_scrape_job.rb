require 'bundler/setup'
require 'capybara/poltergeist'

class AtHomeScrapeJob < ApplicationJob
  queue_as :default

  def perform(url_input)
    # Do something later

    #  state_name = url_input[0] # set state name
      url = url_input[1]        # set url for each initial page
      # flg: 0 for init , 1 when next link exists
      next_link_flg = 0
      links = Link.where(quote_company_id: 2)
      all_urls = []       # to check existing links for skipping

      Bundler.require

      Capybara.register_driver :poltergeist do |app|
        Capybara::Poltergeist::Driver.new(app, {:js_errors => false, :timeout => 1000 })
      end
      session = Capybara::Session.new(:poltergeist)

      session.driver.headers = {
          'User-Agent' => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2564.97 Safari/537.36"
      }

      links.each do |link|
        all_urls << link.url
      end

      dbg = 0

      # get data
      while next_link_flg >= 0
          #try open until no error
          res = nil
          page = nil
          fail_count = 0
          while res == nil and fail_count <= 4
              begin
                  if next_link_flg == 0
                    puts "new page"
                    session.visit(url)
                    session.find("#build_display").click
                    # wait 2 second so that the page layout changes for class=p-property__room--detailbox
                    # if not found any object above try again
                    sleep(5)
                  else
                    # puts "session click"
                    session.click_link('>')
                    session.click_link('>')
                    sleep(5)
                    dbg += 1
                  end
                  page = Nokogiri::HTML.parse(session.html)
                  res = page.search(".p-property__room--detailbox")
              rescue
                # puts "stacked main"
                sleep(5 + fail_count * 5)
                fail_count += 1
              end
          end
          next_link_flg = -1
          break if res.nil?

          contents = page.search(".maincontents .p-result__main .p-property")
          contents.each do |content|
            detail_contents = content.search(".p-property__room--detailbox")
            detail_contents.each do |detail_content|
              GC.start
              detail_url_raw = detail_content.at(".p-property__room--detail-information").at('a')[:href]
              detail_url = "https://www.athome.co.jp" + detail_url_raw.split("?")[0]
              # puts detail_url
              if all_urls.include?(detail_url)
                # puts "Same url present"
                next
              end
              # in case parking space is recorded
              info_row = detail_content.search(".p-property__room--information-list li")
              floor = info_row[0].inner_text
              if floor.include?('階')
                floor = floor.delete('階')
              else
                #delete last two figures indicating room number
                floor = floor[0...-2]
              end
              if floor.to_i == 0 #the input is sometimes 全角. Skip them
                # puts "skip floor number is not good"
                next
              end
              rent = info_row.at(".p-property__information-rent").inner_text.delete('万円').to_f
              admin_fee = info_row[2].inner_text.delete!(",").to_i
              # in some cases info_row.at(".p-property__floor") returns nil
              unless info_row.at(".p-property__floor")
                # puts "floor flan does not exist"
                next
              end
              floor_plan = info_row.at(".p-property__floor").inner_text.split()[0].to_s
              surface = info_row[5].inner_text.delete!("m²").to_f

              name = content.at('.p-property__information h2').inner_text
              address = "東京都" + content.at('.p-property__information').search('dl')[0].at('strong').inner_text.to_s
              address.slice!("丁目")
              temp = content.at('.p-property__information').search('dl')[2].at('dd').inner_text.split()

              story = temp[1].split('階')[0].delete('地上').to_i
              if story == 0 #the input is sometimes 全角. Skip them
                # puts "story is not correct"
                next
              end
              age = temp[3].split('年')[0].delete('(築').to_i if temp[3]
              age = 0 unless temp[3]

              # sometimes link is updated on the same appartment. just update url
              # rent and surface are defined as two digit decimal
              # the input sometime has three digit which leads to nil returne
              # round the input to two digit number
              # sometimes age is between +- 1
              age_minus = age - 1
              age_plus = age + 1
              appartments = Appartment.where(address: address, age: age_minus..age_plus, story: story,
                floor: floor, rent: rent.round(2), admin_fee: admin_fee, floor_plan: floor_plan,
                surface: surface.round(2))
              if appartments[0]
                link = appartments[0].links.find_or_initialize_by(
                    quote_company_id: 2
                )
                link.url = detail_url
                puts dbg, detail_url
                link.save!
              else
              #Quote company id = 2 (at home)
                appartment = Appartment.create(name: name, address: address, age: age, story: story, floor: floor, \
                  rent: rent, admin_fee: admin_fee, \
                  floor_plan: floor_plan, surface: surface)
                link = appartment.links.create(url: detail_url, quote_company_id: 2)
                puts dbg, detail_url
                # go to each page
                sub_agent = Mechanize.new
                sub_agent.user_agent_alias = 'Windows Mozilla'

                #access detailed link for getting additional info
                #update Appartment class that is created
                #if failed 4 times goto next page
                res1 = nil
                fail_count1 = 0
                while res1 == nil and fail_count1 <= 3
                    begin
                        res1 = sub_agent.get(link.url)
                    rescue
                      # puts "stacked detail"
                      sleep(3 + fail_count1 * 5)
                      fail_count1 += 1
                    end
                end
                next if res1 == nil

                shiki = res1.search("#item-detai_basic dl")[1].at(".cell02").inner_text
                reikin = res1.search("#item-detai_basic dl")[1].at(".cell04").inner_text
                shiki_costs = shiki.split('/')
                initial_cost = zen_to_val(shiki_costs[0], rent) + "/" + \
                               zen_to_val(reikin, rent) + "/" + \
                              zen_to_val(shiki_costs[1], rent) + "/-"

                station = res1.search("#item-detai_basic dl")[2].at("dd").inner_text.split('（電車ルート案内）')
                station1 = station[0].gsub(/(\t\n\r)/,"").strip if station[0]
                station2 = station[1].gsub(/(\t\n\r)/,"").strip if station[1]
                station3 = station[2].gsub(/(\t\n\r)/,"").strip if station[2]
                appartment.update(station1: station1, station2: station2, station3: station3,
                                  initial_cost: initial_cost)
                sleep(1)


              end
            end
          end

          # get link to next page
          rel_url_list = page.search(".p-result__main .c-paging__pagenavi li a")
          rel_url_list.each do |rel_url|
            if rel_url.inner_text == ">"
              next_link_flg = 1
              # print rel_url[:href]
            end
          end

          return if next_link_flg != 1
          sleep(2)
      end
  end

  def zen_to_val(str, rent)
    case str
    when "なし" then
      return "-"
    when "1ヶ月" then
      return (1 * rent).to_s + "万円"
    when "2ヶ月" then
      return (2 * rent).to_s + "万円"
    when "3ヶ月" then
      return (3 * rent).to_s + "万円"
    when "4ヶ月" then
      return (4 * rent).to_s + "万円"
    when "5ヶ月" then
      return (5 * rent).to_s + "万円"
    when "6ヶ月" then
      return (6 * rent).to_s + "万円"
    else
      return "-"
    end
  end

end
