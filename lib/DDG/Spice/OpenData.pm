package DDG::Spice::OpenData;
# ABSTRACT: Returns information on datasets with published open data certificates

use DDG::Spice;

triggers any => 'open data';

spice to => 'https://certificates.theodi.org/datasets.json?search=$1';
spice wrap_jsonp_callback => 1;

handle remainder => sub {
    return $_ if $_;
    return;
};

1;