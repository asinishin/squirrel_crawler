require 'rubygems'
require 'bundler/setup'

require 'lego'
require 'lego_k'
require 'logger'

module SquirrelCrawler

  class Worker

    def go
      log = Logger.new(STDOUT)
      log.level = Logger::INFO
    
      FileUtils.rm_rf(Dir.glob(LegoK::BASE_PHOTOS + '*')) # Cleanup all previous photos
 
      @receiver = LegoReceiver::Api.instance
      @receiver.login

      last_listing_id = @receiver.last_id('kj')

      log.info("Starting from: " + last_listing_id)

      @source = LegoK::Api.instance
      page = @source.first_page
      loop do
	new_listings = @source.detect_new_listings(page, last_listing_id)

	new_listings.each do |listing_id|
	  listing_page = @source.load_listing_page(page, listing_id)

	  listing = @source.parse_listing(listing_page, listing_id)
	  next unless @source.listing_filter(listing)

          address = @source.parse_address(listing_page)
	  next unless @source.address_filter(address)

	  @source.load_photos(listing_id)

	  result_listing = @receiver.upload_listing(listing, address)
	  if result_listing
	    Dir.glob("photos/p#{listing_id}*.jpg") do |fname|
	      @receiver.upload_photo(result_listing, fname)
	    end
	  end
	  log.info("Processed listing: " + listing_id)
	end

	page = @source.next_page(page)
	if page.nil?
	  break
	else
	  log.info("New page!")
	end
      end
      
      @receiver.logout
      log.info("Crawling complete!")
    end

  end

end

SquirrelCrawler::Worker.new.go
