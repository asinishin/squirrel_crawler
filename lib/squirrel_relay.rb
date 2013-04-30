require 'rubygems'
require 'bundler/setup'

require 'lego'

module SquirrelRelay

  class Worker

    def go
      FileUtils.rm_rf(Dir.glob(LegoK::BASE_PHOTOS + '*')) # Cleanup all previous photos
 
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

        result_listing = @receiver.upload_listing(listing[:listing], address[:address])
	if result_listing
	  listing[:photos].each do |photo|
	    @receiver.upload_photo(result_listing, "photos/" + photo[:file])
	  end

	  @receiver.upload_features_and_cautions(
	    result_listing,
	    {
	      indoor_features:  listing[:indoor_features],
	      outdoor_features: listing[:outdoor_features],
	      indoor_cautions:  listing[:indoor_cautions],
	      outdoor_cautions: listing[:outdoor_cautions]
	    }
	  )
	end

	puts "Processed listing: " + listing[:listing][:soucre_id]
      end

      @receiver.logout
      @relay.logout
    end

  end

end

SquirrelRelay::Worker.new.go
