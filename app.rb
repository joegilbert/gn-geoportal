require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'haml'

# run sinatra from the lib directory
require File.expand_path(File.dirname(__FILE__) + '/lib/sinatra/lib/sinatra')
# retrieve config information
require File.expand_path(File.dirname(__FILE__) + '/lib/config')
# Load classes and modules
require 'lib/geoportal.rb'

# set sinatra's variables
set :app_file, __FILE__
set :root, File.dirname(__FILE__)
set :views, "views"

# helpers for handlers and views
helpers do
	def gn_url(lang)
		options.host + options.port + "/geonetwork/srv/" + lang
	end
	def map_url(wms)
		options.host + "/geoview?wms=" + wms
	end
	def kml_url(layers)
		options.host + options.port + "/geoserver/wms/kml_reflect?layers=" + layers
	end
end

#
# CONTROLLER BLOCKS ->
#

# uses views/layout.haml as layout when rendering with the haml method

# display the main search interface with form and openlayers map
get '/' do
	@page_title = options.title
	haml :portal, :layout => !request.xhr?
	
end

# perform a search against GN's xml.search service and return a list of results
# possible search params are:
# q, s, c (these are NOT directly sent to the gn_url service)
# nb, sb, eb, wb, t, a, df, dt (these are sent directory to the gn_url service)
get '/search/?' do
	@page_title = options.title + " - Search"
	
	@search = Geoportal::Search.new(params, gn_url('en'))
	@doc = @search.find()
	
	@search.hits = @doc.xpath('.//metadata').length
	if(@search.hits < @search.end) 
		@search.end = @search.hits
	end
	if(@search.end == 0)
		@search.start = 0
	end
			
	@meta_url = gn_url('en') + "/xml.metadata.get?id="
	
	haml :search, :layout => !request.xhr?
	
end

# display a single item's metadata record
get '/item/:id/?' do
	@id = params[:id]
	@page_title = options.title + " - Item #{@id}"
	
	@meta_url = gn_url('en') + "/xml.metadata.get?id=" + @id
	@doc = Nokogiri::XML(open(@meta_url))
	@doc.extend Geoportal::Item
	
	haml :item, :layout => !request.xhr?
	
end