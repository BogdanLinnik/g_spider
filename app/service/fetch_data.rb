# FetchData.new.call

class FetchData
  attr_reader :index, :pages

  def initialize
    @index = 0
    @pages = []
  end

  def call
    Spidr.site('https://geologie.com/') do |spider|
      spider.every_html_page do |page|
        page_obj = {
          url: page.url,
          title: page.title
        }
        puts "index #{index} page.url #{page.url}, page.title #{page.title}"

        page_obj[:meta] = page.search('//meta').reduce({}) do |hash, meta|
          attributes = meta.attributes

          attributes.keys.each do |key|
            if %w[name http-equiv property itemprop].include?(key)
              hash[attributes[key].value] = attributes['content'].value
            elsif key == 'content'
              next
            else
              hash[key] = attributes[key].value
            end
          end

          hash
        end

        1.upto(6) do |i|
          page_obj["h#{i}_content"] = fetch_tags_content(page, "h#{i}")
        end

        page_obj[:images] = page.search("img").map do |img|
          {
            src: img['src'] || img['data-src'],
            alt: img['alt']
          }
        end

        @pages << page_obj

        @index += 1

      end
    end

    puts "#########################################################"

    pages
    # Spidr.site('https://geologie.com/') do |spider|
    #  spider.every_html_page do |page|
    #    puts "index #{index} meta #{page.meta}"
    #    @index += 1
    #  end
    # end
  end

  private

  def fetch_tags_content(page, tag)
    page.search(tag).reduce([]) do |reducer, item|
      text_content = item.text.strip

      reducer += text_content.split("\n").map(&:strip)

      reducer
    end
  end
end