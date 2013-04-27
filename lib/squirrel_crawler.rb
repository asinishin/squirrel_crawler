require 'rubygems'
require 'bundler/setup'

require 'lego'
require 'lego_k'

module SquirrelCrawler

  class Worker

    def go
      FileUtils.rm_rf(Dir.glob(LegoK::BASE_PHOTOS + '*')) # Cleanup all previous photos
 
      Lego::Api.login

      last_listing_id = Lego::Api.last_id('kj')

      puts "Starting from: " + last_listing_id

      page = LegoK::Api.first_page
      loop do
	new_listings = LegoK::Api.detect_new_listings(page, last_listing_id)

	new_listings.each do |listing_id|
	  listing_page = LegoK::Api.load_listing_page(page, listing_id)

	  listing = LegoK::Api.parse_listing(listing_page, listing_id)
	  next unless LegoK::Api.listing_filter(listing)

          address = LegoK::Api.parse_address(listing_page)
	  next unless LegoK::Api.address_filter(address)

	  LegoK::Api.load_photos(listing_id)

	  result_listing = Lego::Api.upload_listing(listing, address)
	  if result_listing
	    Dir.glob('photos/*') do |fname|
	      Lego::Api.upload_photo(result_listing, fname)
	    end
	  end
	  puts "Processed listing: " + listing_id
	end

	page = LegoK::Api.next_page(page)
	if page.nil?
	  break
	else
	  puts "New page!"
	end
      end

      Lego::Api.logout
    end

  end

end

SquirrelCrawler::Worker.new.go
