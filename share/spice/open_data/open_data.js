(function (env) {
    "use strict";
    env.ddg_spice_open_data = function(api_result){

      if (api_result.error) {
          return Spice.failed('open_data');
      }
      
      Spice.add({
        id: 'open_data',
        name: 'Open Data',
        data: api_result.certificates,
        signal: 'high',
        meta: {
            itemType: 'Datasets',
            sourceUrl: 'http://certificates.theodi.org',
            sourceName: 'ODI Open Data Certificates'
        },
        normalize: function(item) {
            return {
                description: item.dataset.publisher,
                url: item.dataset.documentationUrl,
                icon: item.badges["image/png"],
                title: item.dataset.title,
            };
        },
        templates: {
            group: 'icon',
            detail: false,
            item_detail: false,
            options: {
                footer: Spice.open_data.footer
            }
        }
      });
    };
}(this));