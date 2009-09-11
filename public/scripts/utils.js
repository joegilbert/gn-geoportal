$(document).ready(function() {
	$('#adv-link').click(function() {
		$('.adv').toggle('normal');
	});
	$('#geo-search').submit(function(){
		$('#search-container').hide();
		$('#results-container').show();
		load_str = '/search?q=' + escape($('#kw').val()) + '&s=1&c=5&northBL=' + $('#ur-lat').val() + '&southBL=' + $('#ll-lat').val() + '&eastBL=' + $('#ur-lon').val() + '&westBL=' + $('#ll-lon').val() + '&title=' + $('#ti').val() + '&abstract=' + $('#ab').val() + '&dateFrom=' + $('#dfrom').val() + '&dateTo=' + $('#dto').val();
		window.location = load_str;
		return false;
	});
    
  	var lon = 0;
	var lat = 0;
	var zoom = 1;
	var map;

	map = new OpenLayers.Map ("map", {
		controls:[
		new OpenLayers.Control.Navigation(),
		new OpenLayers.Control.PanZoomBar(),
		new OpenLayers.Control.Attribution()
		],
		maxExtent: new OpenLayers.Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34),
		maxResolution: 'auto',
		numZoomLevels: 20,
		units: 'm',
		projection: new OpenLayers.Projection("EPSG:900913"),
		displayProjection: new OpenLayers.Projection("EPSG:4326")
	});

	var osm = new OpenLayers.Layer.OSM("OSM");
	var mrk = new OpenLayers.Layer.Boxes('Bbox marker');
	var control = new OpenLayers.Control();
	OpenLayers.Util.extend(control, {
		draw: function () {
			// this Handler.Box will intercept the shift-mousedown
			// before Control.MouseDefault gets to see it
			this.box = new OpenLayers.Handler.Box( control,
				{"done": this.notice},
				{keyMask: OpenLayers.Handler.MOD_NONE});
			this.box.activate();
		},

		notice: function (bounds) {
			mrk.clearMarkers();
			var sw = map.getLonLatFromPixel(new OpenLayers.Pixel(bounds.left, bounds.bottom)); 
			var ne = map.getLonLatFromPixel(new OpenLayers.Pixel(bounds.right, bounds.top));
			var ll = sw.clone();
			ll.transform(new OpenLayers.Projection("EPSG:900913"), new OpenLayers.Projection("EPSG:4326"));
			var ur = ne.clone();
			ur.transform(new OpenLayers.Projection("EPSG:900913"), new OpenLayers.Projection("EPSG:4326"));
			$('#ll-lon').val(ll.lon.toFixed(4));
			$('#ll-lat').val(ll.lat.toFixed(4));
			$('#ur-lon').val(ur.lon.toFixed(4));
			$('#ur-lat').val(ur.lat.toFixed(4));
			var bounds = new OpenLayers.Bounds(sw.lon,sw.lat,ne.lon,ne.lat);
			var box = new OpenLayers.Marker.Box(bounds);
			mrk.addMarker(box);
		}
	});

    map.addLayers([osm, mrk]);
	map.addControl(control);
    map.setCenter(new OpenLayers.LonLat(lon, lat), zoom);
    map.addControl( new OpenLayers.Control.MousePosition() );
});