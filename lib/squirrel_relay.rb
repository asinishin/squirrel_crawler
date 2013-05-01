require 'rubygems'
require 'bundler/setup'

require 'lego'

module SquirrelRelay

  class Worker

    def go
      log = Logger.new(STDOUT)
      log.level = Logger::INFO
    
      FileUtils.rm_rf(Dir.glob(Lego::BASE_PHOTOS + '*')) # Cleanup all previous photos
 
      @receiver = LegoReceiver::Api.instance
      @receiver.login

      @relay = LegoRelay::Api.instance
      @relay.login

      loop do
        listing = @relay.load_listing('kj')

	if listing.nil?
	  break
	end
 
        @relay.load_photos(listing[:photos])

        result_listing = @receiver.upload_listing(listing[:listing], listing[:address])
	if result_listing
	  listing[:photos].each do |photo|
	    @receiver.upload_photo(result_listing, Lego::BASE_PHOTOS + photo[:file])
	  end

	  is_indoor = listing[:listing][:space_type_id] == 1
          if is_indoor
	    fts = listing[:indoor_features]
	    cts = listing[:indoor_cautions]
	  else
	    fts = listing[:outdoor_features]
	    cts = listing[:outdoor_cautions]
	  end

	  @receiver.upload_features_and_cautions(result_listing, is_indoor, fts, cts)
	end

        @relay.change_owner(listing[:listing][:id])
	log.info("Processed listing: " + listing[:listing][:source_id])
      end

      @receiver.logout
      @relay.logout
      log.info("Relay complete!")
    end

  end

end

SquirrelRelay::Worker.new.go
