/**
 * The MarkerClusterer object.
 * @type {MarkerCluster}
 */
var mc = null;

/**
 * The Map object.
 * @type {google.maps.Map}
 */
var map = null;

/**
 * The MarkerManager object.
 * @type {MarkerManager}
 */
var mgr = null;

/**
 * The KmlLayer object.
 * @type {google.maps.KmlLayer}
 */
var kmlLayer = null;

/**
 * The FusionTablesLayer object.
 * @type {google.maps.FusionTablesLayer}
 */
var fusionLayer = null;

/**
 * KML layer display/hide flag.
 * @type {boolean}
 */
var showKmlLayer = false;

/**
 * Fusion Tables layer display/hide flag.
 * @type {boolean}
 */
var showFusionLayer = false;

/**
 * Fusion Tables layer heatmap flag.
 * @type {boolean}
 */
var showFusionLayerHeatmap = false;

/**
 * Marker Clusterer display/hide flag.
 * @type {boolean}
 */
var showMarketClusterer = false;

/**
 * Marker Manager display/hide flag.
 * @type {boolean}
 */
var showMarketManager = false;


/**
 * Toggles heatmap use on Fusion Tables layer.
 */
function toggleFusionHeatmap() {
  if (fusionLayer) {
    showFusionLayerHeatmap = !showFusionLayerHeatmap;
    fusionLayer.set('heatmap', showFusionLayerHeatmap);
  }
}


/**
 * Toggles Fusion Tables layer visibility.
 */
function toggleFusion() {
  if (!fusionLayer) {
    fusionLayer = new google.maps.FusionTablesLayer(232506, {
      suppressInfoWindows: false
    });
    showFusionLayerHeatmap = false;
    fusionLayer.set('heatmap', showFusionLayerHeatmap);
  }
  showFusionLayer = !showFusionLayer;
  var li = document.getElementById('fusion-hm-li');
  if (showFusionLayer) {
    fusionLayer.setMap(map);
    li.style.visibility = 'visible';
  } else {
    fusionLayer.setMap(null);
    li.style.visibility = 'hidden';
  }
}


/**
 * Toggles KML layer visibility.
 */
function toggleKmlLayer() {
  if (!kmlLayer) {
    var kmlUrl = window.location.href.substring(
        0, 1 + window.location.href.lastIndexOf('/')) + 'markers.kml';
    kmlLayer = new google.maps.KmlLayer(kmlUrl, {
      preserveViewport: true,
      suppressInfoWindows: false
    });
  }
  showKmlLayer = !showKmlLayer;
  if (showKmlLayer) {
    kmlLayer.setMap(map);
  } else {
    kmlLayer.setMap(null);
  }
}


/**
 * Toggles Marker Manager visibility.
 */
function toggleMarkerManager() {
  showMarketManager = !showMarketManager;
  if (mgr) {
    if (showMarketManager) {
      mgr.addMarkers(markers.countries, 0, 5);
      mgr.addMarkers(markers.places, 6, 11);
      mgr.addMarkers(markers.locations, 12);
      mgr.refresh();
    } else {
      mgr.clearMarkers();
      mgr.refresh();
    }
  } else {
    mgr = new MarkerManager(map, {trackMarkers: true, maxZoom: 15});
    google.maps.event.addListener(mgr, 'loaded', function() {
      mgr.addMarkers(markers.countries, 0, 5);
      mgr.addMarkers(markers.places, 6, 11);
      mgr.addMarkers(markers.locations, 12);
      mgr.refresh();
    });
  }
}


/**
 * Toggles Marker Clusterer visibility.
 */
function toggleMarkerClusterer() {
  showMarketClusterer = !showMarketClusterer;
  if (showMarketClusterer) {
    if (mc) {
      mc.addMarkers(markers.locations);
    } else {
      mc = new MarkerClusterer(map, markers.locations, {maxZoom: 19});
    }
  } else {
    mc.clearMarkers();
  }
}

function connectSingleDoublePhoto(map,lat1, lon1, lat2, lon2){
    var coordinates = [
      new google.maps.LatLng(lat1, lon1),
      new google.maps.LatLng(lat2, lon2)
    ];
    var path = new google.maps.Polyline({
      path: coordinates,
      geodesic: true,
      strokeColor: '#'+(Math.random()*0xFFFFFF<<0).toString(16),
      strokeOpacity: 1.0,
      strokeWeight: 2
    });

    path.setMap(map);
}


/**
 * Initializes the map and listeners.
 */
function initialize() {
  var MY_MAPTYPE_ID = 'custom_style';

  map = new google.maps.Map(document.getElementById('map'), {
    center: new google.maps.LatLng(38, 15),
    zoom: 2,
    panControl: false,
    zoomControl: true,
    scaleControl: false,
    streetViewControl: false,
    mapTypeControl: false,
    overviewMapControl: true,
    mapTypeId: MY_MAPTYPE_ID
  });

    var featureOpts = [
    {
      stylers: [
        { saturation:-100 },
        { lightness:-57 }
      ]
    },
    {
      elementType: 'labels',
      stylers: [
        { visibility: 'off' }
      ]
    },
    {
      featureType: 'water',
      stylers: [
        { saturation:-100 },
        { lightness:-57 }
      ]
    }
  ];



  var styledMapOptions = {
    name: 'Custom Style'
  };

  var customMapType = new google.maps.StyledMapType(featureOpts, styledMapOptions);

  map.mapTypes.set(MY_MAPTYPE_ID, customMapType);



  google.maps.event.addDomListener(document.getElementById('fusion-cb'),
      'click', toggleFusion);
  google.maps.event.addDomListener(document.getElementById('fusion-hm-cb'),
      'click', toggleFusionHeatmap);
  google.maps.event.addDomListener(document.getElementById('kml-cb'),
      'click', toggleKmlLayer);
  google.maps.event.addDomListener(document.getElementById('mc-cb'),
      'click', toggleMarkerClusterer);
  google.maps.event.addDomListener(document.getElementById('mgr-cb'),
      'click', toggleMarkerManager);

  // Prepares the marker object, creating a google.maps.Marker object for each
  // location, place and country


  if (markers) {
    for (var level in markers) {
      for (var i = 0; i < markers[level].length; i++) {
        var details = markers[level][i];
        var details2 = markers[level][i+1];

        markers[level][i] = new google.maps.Marker({
          title: details.level,
          position: new google.maps.LatLng(
              details.location[0], details.location[1]),
          clickable: true,
          draggable: false,
          flat: true
        });

        if(details.location && details2.location){
            //connectSingleDoublePhoto(map,details.location[0],details.location[1],details2.location[0],details2.location[1]);
        }
        //var infowindow = new google.maps.InfoWindow();
        //infowindow.setContent(details.name);
        //infowindow.open(map, markers[level][i]);
      }
    }
  }

  toggleMarkerClusterer();
}






google.maps.event.addDomListener(window, 'load', initialize);
