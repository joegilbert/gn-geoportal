module Geoportal
	
	class Search
		
		attr_accessor :start, :end, :count, :hits, :query, :search_str, :url
		
		def initialize(params, url)
			
			@start = params['s'].to_i
			@start = 1 unless start > 0
			@count = params['c'].to_i
			@count = 5 unless count > 0
			@end = @start + @count - 1

			@query = Rack::Utils.escape(params['q'])
			
			# everything except q, s, and c
			gn_search_params = params.inject({}) do |acc,(k,v)|
				['q', 's', 'c'].include?(k) ? acc : acc.merge({k=>v})
			end
			
			# set some defaults...
			gn_search_params['dateTo'] = '2020' if gn_search_params['dateTo'].to_s.empty?
			gn_search_params['dateFrom'] = '0' if gn_search_params['dateFrom'].to_s.empty?
			@search_str = Rack::Utils.build_query(gn_search_params)

			@url = url
			
		end
		
		def find()

			search_url = @url + "/xml.search?any=" + @query + '&relation=overlaps&' + @search_str
			doc = Nokogiri::XML(open(search_url))
			
			return doc
			
		end
		
	end
	
	module Result
		
		def title
			xpath('.//gmd:title', 'gco' => 'http:// www.isotc211.org/2005/gco namespace', 'gmd' => 'http://www.isotc211.org/2005/gmd').first
		end
		
		def description
			xpath('.//gmd:keyword', 'gco' => 'http:// www.isotc211.org/2005/gco namespace', 'gmd' => 'http://www.isotc211.org/2005/gmd')
		end
		
		def map_link
			xpath('.//gmd:CI_OnlineResource/gmd:linkage/gmd:URL[contains(.,"wms")]', 'gco' => 'http:// www.isotc211.org/2005/gco namespace', 'gmd' => 'http://www.isotc211.org/2005/gmd').first
		end
		
		def layers
			xpath('.//gmd:onLine/gmd:CI_OnlineResource[contains(./gmd:protocol/gco:CharacterString,"WMS-1.1.1-http-get-capabilities")]/gmd:name/gco:CharacterString')
		end
		
		def catalog_link
			xpath('.//gmd:offLine//gmd:mediumNote/gco:CharacterString').first
		end
		
	end
	
	module Item
		
		def title
			xpath('.//gmd:title/gco:CharacterString').first.content
		end
		
		def categories
			xpath('.//gmd:topicCategory/gmd:MD_TopicCategoryCode')
		end
		
		def keywords
			xpath('.//gmd:keyword/gco:CharacterString')
		end
		
		def time_start
			xpath('.//gml:TimePeriod/gml:beginPosition').first
		end
		
		def time_end
			xpath('.//gml:TimePeriod/gml:endPosition').first
		end
		
		def north
			xpath('.//gmd:northBoundLatitude/gco:Decimal').first.content
		end
		
		def south
			xpath('.//gmd:southBoundLatitude/gco:Decimal').first.content
		end
		
		def east
			xpath('.//gmd:eastBoundLongitude/gco:Decimal').first.content
		end
		
		def west
			xpath('.//gmd:westBoundLongitude/gco:Decimal').first.content
		end
		
		def web_service
			xpath('.//gmd:onLine/gmd:CI_OnlineResource[contains(./gmd:protocol/gco:CharacterString,"get-map") or contains(./gmd:protocol/gco:CharacterString,"WFS")]')
		end
		

		def download
			xpath('.//gmd:onLine/gmd:CI_OnlineResource[contains(./gmd:protocol/gco:CharacterString,"download")]')
		end
		
		def layers
			xpath('.//gmd:onLine/gmd:CI_OnlineResource[contains(./gmd:protocol/gco:CharacterString,"WMS-1.1.1-http-get-capabilities")]/gmd:name/gco:CharacterString')
		end
		
		def abstract
			xpath('.//gmd:abstract/gco:CharacterString').first.content.gsub(/\*[ ]*\/\/[ ]*\*/,'<br/>').gsub(/\*as is\*/,'<strong>as is</strong>').gsub(/\*/,'<br/>&bull; ')
		end
		
		def contact
			xpath('.//gmd:pointOfContact')
		end
		
	end
	
	module Address
		
		def role
			xpath('.//gmd:role/gmd:CI_RoleCode/@codeListValue').first.content.gsub(/([A-Z])/,' \1').capitalize
		end
		
		def address_line
			xpath('.//gco:CharacterString[not(../../../gmd:CI_OnlineResource)]')
		end
		
		def address_link
			xpath('.//gmd:CI_OnlineResource')
		end
		
	end	 
	
	module Link
		
		def link_url
			xpath('./gmd:linkage/gmd:URL').first.content
		end
		
		def link_name
			xpath('./gmd:name/gco:CharacterString').first.content
		end
		
		def link_desc
			xpath('.//gmd:description/gco:CharacterString').first.content
		end
		
	end 
	
end