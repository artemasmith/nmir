function click_section(e){};
function add_section(e){};
function delete_section(e){};
function select_location(e){};


function set_hidden_multi(e){
    console.log('event-button '+e);
    cn = e.className;
    hid = e.getAttribute('hid');
    value = e.getAttribute('value');
    var current_value = $('#'+hid)[0].getAttribute('value');
    if (!cn.match('active')){
        rv = current_value + " " + value;
        $('#'+hid)[0].setAttribute('value',rv);
    }
    else {
        rv = current_value.replace(value, '');
        $('#'+hid)[0].setAttribute('value',rv);
    }
    console.log($('#'+hid)[0].value);
}

function set_hidden_one(e){
    console.log('we send in fuction ' + e);
    hid = e.getAttribute('hid');
    console.log('hid='+hid);
    value = e.getAttribute('value');
    console.log('value='+value);
    $('#' + hid)[0].setAttribute('value',value);

    console.log($('#' + hid)[0].value);
}

function click_region(e) {
    console.log('event-button '+e);
    cn= e.className;
    rg = e.getAttribute('region');
    var selected_regions = $('#region-select')[0].getAttribute('value');
    if (!cn.match('active')){
        rg = selected_regions + " " + rg;
        $('#region-select')[0].setAttribute('value',rg);
    }
    else {
        rg = selected_regions.replace(rg, '');
        $('#region-select')[0].setAttribute('value',rg);
    }
    console.log($('#region-select')[0].value);
}

//TODO: implement DRY on next refactoring!!!!!
function click_city(e){
    cn= e.className;
    city = e.getAttribute('city');
    var selected_cities = $('#city-select')[0].getAttribute('value');
    if (!cn.match('active')){
        city = selected_cities + " " + city;
        $('#city-select')[0].setAttribute('value', city);
    }
    else {
        city = selected_cities.replace(city, '');
        $('#city-select')[0].setAttribute('value', city);
    }
    console.log($('#city-select')[0].value);
}

function close_modal(e){
    console.log('button'+e);
    mv= e.getAttribute('mv');
    console.log('mv='+mv);
    $('#'+mv).modal('hide');
    var cities = $('.active.city');
    console.log('cities='+cities);
    var rescity='';
    for (i=0; i< cities.length; i++){
        rescity += cities[i].textContent + " ";
    }
    $('#city-select-button')[0].textContent = rescity;
}

function select_region(){
    var selected_regions = $('#region-select')[0].getAttribute('value');
    $.ajax({
        dataType: 'json',
        url: '/locations?parents=' + selected_regions,
        success: function(data) {
            console.log(data);
            $('#region-select-modal').modal('hide');
            var regions = '';
            //var result = JSON.parse(data);
            console.log(data['Тюменская область']);
            var resulthtml='';
            for(region in data){
                console.log('region'+region);
                resulthtml += "<span>" + region + "</span><p>";
                regions += region + " ";
                console.log(data[region][0]);
                cities = data[region];
                for (i=0; i< cities.length; i++){
                    console.log('city='+cities[i]);

                    resulthtml += '<span><button city="' + cities[i][1] + '" class="btn btn-default city" data-toggle="buttons" onclick="click_city(this);">' + cities[i][0] + '</button></span>';

                }
                resulthtml += '<p>'
            }
            console.log(resulthtml);
            $('#cities-list').html(resulthtml);

            $('#region-select-button')[0].textContent=regions;
        }
    })
}

function search_advertisment(e){
//Do required stuff for setting up search credentials (we are looking for .active elements)

    $('.super-form').trigger('submit.rails');
};
