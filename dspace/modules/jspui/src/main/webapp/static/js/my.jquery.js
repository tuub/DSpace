// Testing Environment
baseUrl = location.protocol + '//' + location.host + '/' + location.href.split( '/' )[3] + '/';

jQuery.fn.extend({
    hasClasses: function( selector ) {
       var classNamesRegex = new RegExp("( " + selector.replace(/ +/g,"").replace(/,/g, " | ") + " )"),
           rclass = /[\n\t\r]/g,
           i = 0,
           l = this.length;
       for ( ; i < l; i++ ) {
           if ( this[i].nodeType === 1 && classNamesRegex.test((" " + this[i].className + " ").replace(rclass, " "))) {
               return true;
           }
       }
       return false;
   }
});

var headID = document.getElementsByTagName("head")[0];

var tooltipsterJS = document.createElement("script");
tooltipsterJS.type = "text/javascript";
tooltipsterJS.src = "static/js/vendor/tooltipster/js/jquery.tooltipster.js";

var tooltipsterCSS = document.createElement("link");
tooltipsterCSS.type = "text/css";
tooltipsterCSS.rel = "stylesheet";
tooltipsterCSS.src = "static/js/vendor/tooltipster/css/tooltipster.css";

var tablesorterJS = document.createElement("script");
tablesorterJS.type = "text/javascript";
tablesorterJS.src = "static/js/vendor/tablesorter/jquery.tablesorter.min.js";

var tablesorterCSS = document.createElement("link");
tablesorterCSS.type = "text/css";
tablesorterCSS.rel = "stylesheet";
tablesorterCSS.src = "static/js/vendor/tablesorter/themes/blue/style.css";

var easytreeJS = document.createElement("script");
easytreeJS.type = "text/javascript";
easytreeJS.src = "static/js/vendor/easytree/jquery.easytree.min.js";

var easytreeCSS = document.createElement("link");
easytreeCSS.type = "text/css";
easytreeCSS.rel = "stylesheet";
easytreeCSS.src = "static/js/vendor/easytree/skin-depositonce/ui.easytree.css";

+function ($) {

  'use strict';

  $( document ).ready(function() {

    /*
    headID.appendChild(tooltipsterJS);
    headID.appendChild(tablesorterJS);
    headID.appendChild(easytreeJS);
    headID.appendChild(tooltipsterCSS);
    headID.appendChild(tablesorterCSS);
    headID.appendChild(easytreeCSS);
    */

    /*
    |----------------------------------------------------------------------------
    |----------------------------------------------------------------------------
    | DESIGN DESIGN DESIGN DESIGN DESIGN DESIGN DESIGN DESIGN DESIGN DESIGN
    |----------------------------------------------------------------------------
    |----------------------------------------------------------------------------
    */

    /************************************************************************
    * Metadata Display First TD Fixed Width
    ************************************************************************/
    $('td.metadataFieldLabel').css('width', '15%');

    /************************************************************************
    * Extra Bottom Paddings for all tables
    ************************************************************************/
    //$('table tr').css('padding-bottom', '10px');

    /************************************************************************
    * Add <thead> wrapper to tables with <th>
    ************************************************************************/
    var tables = $('table');
    tables.each( function(){
        var thisTable = $(this);
        var theads = thisTable.find("thead");
        var theadrows =  thisTable.find("tr:has(th)");

        if (theads.length == 0)
        {
            theads = $('<thead></thead>').addClass('header').prependTo(thisTable);
        }
        theadrows.clone(true).appendTo( theads );
        theadrows.remove();
    });

    /************************************************************************
    * All H1s to H2s
    ************************************************************************/
    /*
    $('h1, h3').replaceWith(function(){
        return $("<h2 />").append( $(this).text() );
    });
    */

    /************************************************************************
    * Remove all Well-Container
    ************************************************************************/
    //$('.well').removeClass('well');

    /************************************************************************
    * Remove all paddings in nested containers
    ************************************************************************/
    //$('.container>.container').addClass('nopadding');


    /************************************************************************
    * Move Help Buttons beside to the right & hide (for now)
    ************************************************************************/
    //$('h1, h2').has('span.glyphicon-question-sign').children('a').wrap('<span class="pull-right"></span>');

    /************************************************************************
    * Hide Help Buttons (for now)
    ************************************************************************/
    $('h1, h2, .panel-heading').has('span.glyphicon-question-sign').find('span.glyphicon-question-sign').hide();

    /************************************************************************
    * Remove unneccessary classes and empty class attributes
    ************************************************************************/
    $('td, th').removeClass('evenRowEvenCol evenRowOddCol oddRowOddCol oddRowEvenCol');
    $('*[class=""]').removeAttr('class');

    /************************************************************************
    * Set default value for all panel-headings (instead of primary value)
    ************************************************************************/
    $('div.panel').filter('.panel-primary').removeClass('panel-primary').addClass('panel-default');
    $('.panel-info').removeClass('panel-info').addClass('panel-default');

    /************************************************************************
    * Remove "Help on Subject Categories" link in Submission Form
    ************************************************************************/
    $('div.help-block').children().find('a').remove();
    $('div.help-block').children().find('noscript').remove();

    /************************************************************************
    * Move "Subject Categories" selection link to preceding div.help-block
    ************************************************************************/
    var $controlledVocabularyLink = $('span.controlledVocabularyLink').parent();
    var $helpBlock = $('span.controlledVocabularyLink').parent().closest('div.row');
    //$controlledVocabularyLink.appendTo( $helpBlock );
    //console.log( $helpBlock ); // .appendTo('div.help-block')

    /************************************************************************
    * Adjust Facets to fit (except responsive boxes)
    ************************************************************************/
    $('.facetsBox').children().filter(function() { return this.className.match((/(^|\s)col-\S+/g)) }).css('padding','0');
    $('.facetsBox').children('.panel').removeClass('panel-success').addClass('panel-default');
    $('.facetsBox').removeClass('row panel').children('.facet').removeClass('col-md-12').addClass('panel panel-default');
    $('.facetsBox').find('span.facetName').replaceWith(function(){
        return $('<div class="panel-heading">').append($(this).contents());
    });

    /************************************************************************
    * Remove bottom copyright text from item view pages
    ************************************************************************/
    $('p.submitFormHelp.alert.alert-info').hide();

    /************************************************************************
    * Remove Handle from Item Display, show only DOI
    ************************************************************************/
    var handleLink = $('td.metadataFieldValue a').filter(function() {
        var link = $(this).attr('href');
        return link.match(/\.tu\-berlin\.de\/handle\//);
    });
    $(handleLink).next('br').remove();
    $(handleLink).remove();

    /************************************************************************
    * Adjust Admin Boxes and Action Boxes to fit
    ************************************************************************/
    var $adminPanelBox = $('div.panel-warning > div.panel-heading:contains("Admin")').parent();
    $adminPanelBox.removeClass('panel-warning').addClass('panel-default facets');
    $adminPanelBox.find('.panel-body > form').wrap('<ul class="list-group"></ul>').children('input.btn').removeClass('col-md-12 btn-default').addClass('btn-link').wrap('<li class="list-group-item"></li>');

    var $actionsPanelBox = $('div.panel-default > div.panel-heading:contains("Actions")').parent();
    $actionsPanelBox.addClass('facets');
    $actionsPanelBox.find('.panel-body > form').wrap('<ul class="list-group"></ul>').children('input.btn').removeClass('col-md-12 btn-default').addClass('btn-link').wrap('<li class="list-group-item"></li>');

    /************************************************************************
    * Adjust Language Code Labels
    ************************************************************************/
    if( $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Language:'; }).size() == 0 )
    {
        var $languageCode = $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Language Code:'; }).next();
        if( undefined != $languageCode.html() )
        {
            var languageCodeReplacer = "";
            if( $languageCode.html().indexOf("<br>") > -1)
            {
                var languageCodeParts = $languageCode.html().split('<br>');
            }
            else
            {
                var languageCodeParts = new Array( $languageCode.html() );
            }
            for( var i=0; i < languageCodeParts.length; i++ )
            {
                switch ( languageCodeParts[i] )
                {
                    case "de":
                        $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Language Code:'; }).text('Language:');
                        languageCodeReplacer += "German";
                        break;
                    case "en":
                        $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Language Code:'; }).text('Language:');
                        languageCodeReplacer += "English";
                        break;
                    case "fr":
                        $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Language Code:'; }).text('Language:');
                        languageCodeReplacer += "French";
                        break;
                    case "sp":
                        $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Language Code:'; }).text('Language:');
                        languageCodeReplacer += "Spanish";
                        break;
                    default:
                        languageCodeReplacer += $languageCode.html();
                };
                if( i < languageCodeParts.length-1 )
                {
                    languageCodeReplacer += '<br/>';
                }
            }

            $languageCode.html( languageCodeReplacer );
        };
    }
    else
    {
        $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Language Code:'; }).next().remove();
        $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Language Code:'; }).remove();
    };

    /************************************************************************
    * Adjust Type Version Labels (not used)
    ************************************************************************/
    var $typeVersion = $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Version of published item:'; }).next();
    if( $typeVersion )
    {
        var typeVersionReplacer = "";
        switch ( $typeVersion.text() )
        {
            case "draft":
                typeVersionReplacer = "Draft Version";
                break;
            case "submittedVersion":
                typeVersionReplacer = "Submitted Version";
                break;
            case "acceptedVersion":
                typeVersionReplacer = "Accepted Version";
                break;
            case "publishedVersion":
                typeVersionReplacer = "Published Version";
                break;
            case "updatedVersion":
                typeVersionReplacer = "Updated Version";
                break;
            default:
                typeVersionReplacer = "Unknown Version";
        };
        $typeVersion.text( typeVersionReplacer );
    };

    /************************************************************************
    * Adjust Abstract Display
    ************************************************************************/
    var $abstractField = $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Abstract:'; }).next();
    if( $abstractField.size() > 0 )
    {
        var abstractsHTML = $abstractField.html();
        if( abstractsHTML !== null )
        {
            abstractsHTML = abstractsHTML.split('<br>').join('<br/><br/>');
        }
        $abstractField.html( abstractsHTML );
    }

    /************************************************************************
    * Add URN Linkage
    ************************************************************************/
    $('td.metadataFieldValue a').filter( function() { return this.text.match(/urn/); } ).each( function(){
        $(this).attr( 'href', 'http://nbn-resolving.de/' + $(this).text() );
    });

    /************************************************************************
    * Add DOI Linkage
    ************************************************************************/
    $('td.metadataFieldValue').each( function(){
        var pattern = /^10\.[0-9]+\/[0-9a-zA-Z-]+/;

        if( pattern.test( $(this).text() ) ) {
            $(this).wrapInner( '<a href="https://dx.doi.org/' + $(this).text() + '" target="_blank"></a>');
        }
    });

    /************************************************************************
    * Adjust DDC Display (since Configuration doesn't work)
    ************************************************************************/
    var $ddcField = $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'DDC Class:'; }).next();
    if( $ddcField.length > 0 )
    {
        var ddcFieldEntries = $ddcField.html().split('<br>');

        var ddcLinks = Array();
        var ddcString = String();

        if( ddcFieldEntries.length > 0 )
        {
            ddcFieldEntries.forEach(function(ddcFieldEntry) {
                var ddcValue = ddcFieldEntry.split('::').slice(-1)[0];
                ddcLinks.push( ddcValue );
            });
        }
        ddcLinks.forEach(function(ddcLink) {
            ddcString += ddcLink + '<br/>';
        });
        $ddcField.html( ddcString );
    }

    /************************************************************************
    * Nicer CC URI Display
    ************************************************************************/
    var $ccLicenseUriField = $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Creative Commons License:'; }).next();
    var ccLicenseUri = $ccLicenseUriField.text();
    if( ccLicenseUri !== null) {
        if (ccLicenseUri.toLowerCase().indexOf("https://creativecommons.org") >= 0)
        {
            //TESTED ALSO WITH: ccLicenseUri = 'https://creativecommons.org/licenses/by-nc-sa/4.0/';
            //ccLicenseUri = 'https://creativecommons.org/licenses/by-nc-sa/4.0/';
            var ccLicenseInfo = ccLicenseUri.split("https://creativecommons.org/licenses/").join("");
            if( ccLicenseInfo.slice(-1) == '/') {
                ccLicenseInfo.slice(0, -1);
            }
            var ccLicenseString = 'Creative Commons ' + ccLicenseInfo.split('/').join(' ').toUpperCase();
            var ccLicenseImage = '<img src="https://i.creativecommons.org/l/' + ccLicenseInfo.split(' ').join('/') + '/88x31.png" alt="' + ccLicenseString + '" title="' + ccLicenseString + '" />';
            $ccLicenseUriField.html(ccLicenseImage).wrapInner(function() {
                return '<a href="' + ccLicenseUri + '" target="_blank"></a>';
            });
            $ccLicenseUriField.append( '&nbsp;&nbsp;&nbsp;<a href="' + ccLicenseUri + '" target="_blank">' + ccLicenseString + '</a>');
        };

		if (ccLicenseUri.toLowerCase().indexOf("https://creativecommons.org/publicdomain/") >= 0)
		{
			var ccLicenseInfo = ccLicenseUri.split("https://creativecommons.org/publicdomain/").join("");
			if( ccLicenseInfo.slice(-1) == '/') {
				ccLicenseInfo.slice(0, -1);
			}
			var ccLicenseString = 'Creative Commons ' + ccLicenseInfo.split('/').join(' ').toUpperCase();
			// Override Public Domain Mark
			if (ccLicenseString.toLowerCase().indexOf(" mark ") >= 0) {
				ccLicenseString = 'Public Domain Mark';
			}
			var ccLicenseImage = '<img src="https://i.creativecommons.org/l/' + ccLicenseInfo.split(' ').join('/') + '/88x31.png" alt="' + ccLicenseString + '" title="' + ccLicenseString + '" />';
			// Override Public Domain Mark
			if (ccLicenseImage.toLowerCase().indexOf("mark") >= 0) {
				ccLicenseImage = 'https://licensebuttons.net/p/88x31.png';
			}
			$ccLicenseUriField.html(ccLicenseImage).wrapInner(function() {
				return '<a href="' + ccLicenseUri + '" target="_blank"></a>';
			});
			$ccLicenseUriField.append( '&nbsp;&nbsp;&nbsp;<a href="' + ccLicenseUri + '" target="_blank">' + ccLicenseString + '</a>');

		}
    }


    var $ocLicenseUriField = $('td.metadataFieldLabel').filter(function() { return $.trim( $(this).text() ) == 'Open Content License:'; }).next();
    var ocLicenseUri = $ocLicenseUriField.text();

    if( ocLicenseUri !== null )
    {
        if( /creativecommons/i.test(ocLicenseUri) )
        {
            if (/https/i.test(ocLicenseUri))
            {
                var ocLicenseInfo = ocLicenseUri.split("https://creativecommons.org/licenses/").join("").slice(0, -1);
            }
            else
            {
                var ocLicenseInfo = ocLicenseUri.split("http://creativecommons.org/licenses/").join("").slice(0, -1);
            }

            var ocLicenseString = 'Creative Commons ' + ocLicenseInfo.split('/').join(' ').toUpperCase();
            var ocLicenseImage = '<img src="https://licensebuttons.net/l/' + ocLicenseInfo.split(' ').join('/') + '/88x31.png" alt="' + ocLicenseString + '" title="' + ocLicenseString + '" />';
            $ocLicenseUriField.html(ocLicenseImage).wrapInner(function() {
                return '<a href="' + ocLicenseUri + '" target="_blank"></a>';
            });
            $ocLicenseUriField.append( '&nbsp;&nbsp;&nbsp;<a href="' + ocLicenseUri + '" target="_blank">' + ocLicenseString + '</a>');
        }
        else
        {
            if( /http/i.test(ocLicenseUri) )
            {
                $ocLicenseUriField.html(ocLicenseUri).wrapInner(function() {
                    return '<a href="' + ocLicenseUri + '" target="_blank"></a>';
                });
            }
            else
            {
                $ocLicenseUriField.html(ocLicenseUri);
            }
        }
    };

    /************************************************************************
    * Button Colors based on values in their name/id attributes
    ************************************************************************/

    $('input.btn').not('.btn-link').removeClass (function (index, css) { return (css.match (/(^|\s)col-\S+/g) || []).join(' ') });
    $('input.btn-info').removeClass('btn-info').addClass('btn-default');

    // Success States
    //$('input.btn').not('.btn-link').filter( function() { return this.name.match(/submit/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-success');
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/resume/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-success');

    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/update/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-success');
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/upload/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-success');
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/next/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-success');
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/retry/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-success');
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/perform/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-success');
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/claim/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-success');
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/search/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-success');
    $('input.btn').not('.btn-link').filter( function() { return this.id.match(/main-query-submit/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-success');

    // Danger States
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/cancel/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-danger');
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/delete/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-danger');

    // Default States
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/view/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-default');
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/edit/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-default');
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/close/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-default');
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/own/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-default');
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/return/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-default');
    $('input.btn').not('.btn-link').filter( function() { return this.name.match(/clear/); } ).removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-default');

    // All Link Buttons To Default State
    $('a.btn').removeClass (function (index, css) { return (css.match (/(^|\s)btn-\S+/g) || []).join(' ') }).addClass('btn-default btn-xs').css('font-weight', 'normal');

    /************************************************************************
    * Smaller Buttons
    ************************************************************************/
    $('td .btn').addClass('btn-xs');
    $('.btn-sm').removeClass('btn-sm').addClass('btn-xs');
    $('#browse_navigation input.btn, #browse_controls input.btn, .discovery-search-form .btn').addClass('btn-xs');

    /************************************************************************
    * Group Edit Buttons Rearrangement FIXME! HACK!
    ************************************************************************/
    $('form[name=epersongroup] div.row').removeClass('container').css( 'margin-left', '0' ).css( 'margin-right', '0' );

    /************************************************************************
    * Center button groups
    ************************************************************************/
    $('input.btn').not('.btn-link').removeClass (function (index, css) { return (css.match (/(^|\s)col-\S+/g) || []).join(' ') });
    $('div.row').has('div.btn-group').find('div.btn-group')
    .removeClass('btn-group').removeClass('pull-right').addClass('text-center').removeClass(function (index, css) { return (css.match (/(^|\s)col-\S+/g) || []).join(' ') });

    /************************************************************************
    * Panel-Bodys to every panel
    ************************************************************************/
    $('div.panel-heading').next().filter(':not(.panel-body)').wrap('<div class="panel-body" />');

    /*
    |----------------------------------------------------------------------------
    |----------------------------------------------------------------------------
    | FEATURES FEATURES FEATURES FEATURES FEATURES FEATURES FEATURES FEATURES
    |----------------------------------------------------------------------------
    |----------------------------------------------------------------------------
    */

    /************************************************************************
    * On-Site Feedback Form via Tooltipster
    * IS DONE ON-SITE IN COMMUNITY-LIST.JSP SINCE WE NEED THE JSON DATA
    ************************************************************************/

    $("#feedback").click(function(e) {
        if( $(".tooltipster-base").css('display') == 'none' )
        {
            $(".tooltipster-base").show();
        }
        return false;
    }).tooltipster({
        theme: 'tooltipster-light',
        speed: 0,
        contentAsHTML : true,
        position : 'bottom-right',
        autoClose : false,
        trigger: 'click',
        interactive:true,
        multiple:true,
        content: 'Loading Feedback Form ...',
        functionBefore: function(origin, continueTooltip) {
            continueTooltip();
            $.ajax({
                type: 'GET',
                url: origin[0]['href'],
                success: function(data) {
                    origin.tooltipster('content', $(data)).data('ajax', 'cached');
                }
            });
        }
    });


    /************************************************************************
    * DataTables plugin (https://www.datatables.net)
    * Finds tables in document, adds a filter input to top.
    ************************************************************************/
    $('table.with-filter').has('thead th').each(function(){
        if( $(this).find('tr').length > 1)
        {
            $(this).DataTable({
                "bSort" : false,
                'paging': false,
                'info': false,
                'stateSave': true,
                'oLanguage': {
                    'sSearch': 'Filter this table: '
                },
                'columnDefs': [{
                    'targets': '_all',
                    'defaultContent': ''
                }]
            });
        }
    });

    $('div.dataTables_filter input').removeClass('input-sm').addClass('input-md');
    $('table.dataTable').css('width', '100%');

    $('div.panel-body:not(:has(table))').each(function(index){
        $(this).next().appendTo( $(this) );
    });

    $('div.panel:not(:has(div.panel-body))').each(function(index){
        var children = $(this).children().filter(':not(div.panel-heading)');
        children.wrap('<div class="panel-body" />');
    });

    /************************************************************************
    * Select Picker Plugin (https://silviomoreto.github.io/bootstrap-select/)
    ************************************************************************/
    $('select.selectpicker').selectpicker();

    /************************************************************************
    * Community List via EasyTree
    * IS DONE ON-SITE IN COMMUNITY-LIST.JSP SINCE WE NEED THE JSON DATA
    ************************************************************************/
    /*
    $('#communityTree').easytree( {
        data: community_data,
        allowActivate: false,
        enableDnd: false,
        disableIcons: false,
        ordering: 'ordered ASC',
        slidingTime: 100,
        minOpenLevels: 0
    });
    */

    /************************************************************************
    * Show Statistics on-site the Ajax way
    * FIXME!
    ************************************************************************/
    /*
    $('#show-statistics').on('click',function(e){
        e.preventDefault();

        $.ajax({
            type: "GET",
            url: $(this).attr('href'),
            success: function(data) {
                $('#statistics').html( data );
            }
        });

    });
    */





    });

}(jQuery);
