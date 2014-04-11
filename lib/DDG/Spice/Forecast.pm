package DDG::Spice::Forecast;

use Data::Dumper;

use DDG::Spice;
use Text::Trim;

name "Forecast";
description "Weather forecast";
source "Forecast";
primary_example_queries "weather";
secondary_example_queries "weather 12180";
topics "everyday", "travel";
code_url "https://github.com/duckduckgo/zeroclickinfo-spice/blob/master/lib/DDG/Spice/Forecast.pm";


my @triggers = ('forecast', 'forcast', 'weather', 'temp', 'temperature');
triggers startend => @triggers;

spice to => 'http://forecast.io/ddg?apikey={{ENV{DDG_SPICE_FORECAST_APIKEY}}}&q=$1&callback={{callback}}';

# cache DDG Rewrite for 24 hours and
# API responses with return code 200 for 30 minutes
spice is_cached => 1;
spice proxy_cache_valid => "200 30m";

my $no_location_qr = qr/\s+fore?cast|report|weather|temp(erature)\s+/;
my $weather_qr = qr/\s(?:(?:weather|temp(?:erature|))(?:\sfore?cast|\sreport|\stoday|\stomm?orr?ow|\sthis\sweek|))+/;

handle query_lc => sub {
    my $location = '';

    # Capture user defined location if it exists.
    if (/^(?:what(?:'s|\sis)\sthe\s|)$weather_qr(?:\sin\s|\sfor\s|\sat\s|)(.*)/) {
        $location = $1 unless ($1 =~ $no_location_qr);

    } elsif (/^(.*)\s$weather_qr/) {
        $location = $1 unless ($1 =~ $no_location_qr);
    }

    # 10/29/2013 russell double check for things we don't want
    $location = trim $location if $location;
    
    # bbc
    # shipping forecast, bbc forecast, bbc weather forecast etc.
    return if /(shipping\s+fore?cast)|((weather|fore?cast)\sbbc$)|(^bbc\s.*(weather|fore?cast))|(\s+bbc\s+)/;

    # has quotes
    return if /(%22)|\"/;

    # has financialish terms
    return if /financ(e|ial)|market|bond|treasury|pension|fund|t-?bill|stock|government|strateg(y|ies)|analytics|market|fore?cast(ing|or|er)/;
    return if /(gold|silver|oil|naturalgas|palladium|platinum|copper|lead|zinc|tin|aluminium|aluminum|nickel|cobalt|molybdenum|polypropylene|ethanol).*(fore?cast)/;

    # sports
    return if /football|golf|soccer|tennis|basketball|hockey|nba|ncaa|nfl|nhl/;

    # has other terms
    return if (/(^site\:)|http|(\.(org|com|net))/);

    # Don't cache generic queries due to
    # variations in the users location.
    if ($location) {
        return $location;
    } else {
        # Infer location if not explicitly in the query.
        $location = $loc->loc_str unless ($location);
        return $location, {is_cached => 0};
    }
};

1;
